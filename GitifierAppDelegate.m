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
#import "Repository.h"
#import "RepositoryListController.h"
#import "StatusBarController.h"

@implementation GitifierAppDelegate

@synthesize monitor, statusBarController, repositoryListController, repositoryList;

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
  repositoryList = [NSMutableArray array];
  [Defaults registerDefaults];
  [GrowlApplicationBridge setGrowlDelegate: (id) @""];
  [self updateUserEmail];
  [repositoryListController loadRepositories];
  [statusBarController createStatusBarItem];
  [monitor startMonitoring];
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
  for (Commit *commit in [commits reverseObjectEnumerator]) {
    if (![commit.authorEmail isEqual: userEmail]) {
      [GrowlApplicationBridge notifyWithTitle: PSFormat(@"%@ – %@", commit.authorName, repository.name)
                                  description: commit.subject
                             notificationName: @"Commit received"
                                     iconData: nil
                                     priority: 0
                                     isSticky: NO
                                 clickContext: nil];
    }
  }
}

@end
