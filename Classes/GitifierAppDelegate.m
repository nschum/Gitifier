// -------------------------------------------------------
// GitifierAppDelegate.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Growl/GrowlApplicationBridge.h>

#import "Commit.h"
#import "Defaults.h"
#import "Git.h"
#import "GitifierAppDelegate.h"
#import "PreferencesWindowController.h"
#import "Repository.h"
#import "RepositoryListController.h"
#import "StatusBarController.h"

@implementation GitifierAppDelegate

@synthesize monitor, preferencesWindowController, statusBarController, repositoryListController, repositoryList;

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
  repositoryList = [NSMutableArray array];
  [Defaults registerDefaults];
  [GrowlApplicationBridge setGrowlDelegate: (id) @""];
  [self updateUserEmail];
  [repositoryListController loadRepositories];
  [statusBarController createStatusBarItem];
  [monitor startMonitoring];

  if ([[repositoryListController repositoryList] count] == 0) {
    [preferencesWindowController showPreferences: self];
  }
}

- (void) applicationWillTerminate: (NSNotification *) notification {
  [repositoryListController saveRepositories];
}

- (void) updateUserEmail {
  Git *git = [[Git alloc] initWithDelegate: self];
  [git runCommand: @"config" withArguments: PSArray(@"user.email") inPath: NSHomeDirectory()];
}

- (void) commandCompleted: (NSString *) command output: (NSString *) output {
  if ([command isEqual: @"config"] && output && output.length > 0) {
    userEmail = [output psTrimmedString];
  }
}

- (void) commitsReceived: (NSArray *) commits inRepository: (Repository *) repository {
  BOOL ignoreMerges = [GitifierDefaults boolForKey: IGNORE_MERGES_KEY];
  for (Commit *commit in [commits reverseObjectEnumerator]) {
    if (ignoreMerges && [commit isMergeCommit]) {
      return;
    }
    if ([commit.authorEmail isEqual: userEmail]) {
      return;
    }
    [GrowlApplicationBridge notifyWithTitle: PSFormat(@"%@ – %@", commit.authorName, repository.name)
                                description: commit.subject
                           notificationName: @"Commit received"
                                   iconData: nil
                                   priority: 0
                                   isSticky: NO
                               clickContext: nil];
  }
}

@end
