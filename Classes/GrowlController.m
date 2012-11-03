// -------------------------------------------------------
// GrowlController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Commit.h"
#import "CommitWindowController.h"
#import "Defaults.h"
#import "GrowlController.h"
#import "Repository.h"
#import "RepositoryListController.h"

NSString *CommitReceivedGrowl         = @"Commit received";
NSString *RepositoryUpdateFailedGrowl = @"Repository update failed";
NSString *OtherMessageGrowl           = @"Other message";


@implementation GrowlController

+ (GrowlController *) sharedController {
  static GrowlController *instance = nil;
  if (!instance) {
    instance = [[GrowlController alloc] init];
  }
  return instance;
}

+ (BOOL) growlDetected {
  return [GrowlApplicationBridge isGrowlRunning];
}

- (id) init {
  self = [super init];
  if (self) {
    [GrowlApplicationBridge setGrowlDelegate: self];
  }
  return self;
}

- (void) showGrowlWithCommit: (Commit *) commit {
  BOOL sticky = [GitifierDefaults boolForKey: StickyNotificationsKey];
  NSDictionary *commitData = @{@"commit": [commit toDictionary], @"repository": commit.repository.url};

  [GrowlApplicationBridge notifyWithTitle: PSFormat(@"%@ – %@", commit.repository.name, commit.authorName)
                              description: commit.subject
                         notificationName: CommitReceivedGrowl
                                 iconData: [self growlIcon]
                                 priority: 0
                                 isSticky: sticky
                             clickContext: commitData];
}

- (void) showGrowlWithCommitGroup: (NSArray *) commits includesAllCommits: (BOOL) includesAll {
  BOOL sticky = [GitifierDefaults boolForKey: StickyNotificationsKey];
  NSArray *authorNames = [commits valueForKeyPath: @"@distinctUnionOfObjects.authorName"];
  NSString *authorList = [authorNames componentsJoinedByString: @", "];
  NSString *message = includesAll ? @"%d commits received" : @"… and %d other commits";

  [GrowlApplicationBridge notifyWithTitle: PSFormat(message, commits.count)
                              description: PSFormat(@"Author%@: %@", (authorNames.count > 1) ? @"s" : @"", authorList)
                         notificationName: CommitReceivedGrowl
                                 iconData: [self growlIcon]
                                 priority: 0
                                 isSticky: sticky
                             clickContext: nil];
}

- (void) showGrowlWithCommitGroupIncludingAllCommits: (NSArray *) commits {
  [self showGrowlWithCommitGroup: commits includesAllCommits: YES];
}

- (void) showGrowlWithCommitGroupIncludingSomeCommits: (NSArray *) commits {
  [self showGrowlWithCommitGroup: commits includesAllCommits: NO];
}

- (void) showGrowlWithError: (NSString *) message repository: (Repository *) repository {
  NSString *title;
  if (repository) {
    NSLog(@"Error in %@: %@", repository.name, message);
    title = PSFormat(@"Error in %@", repository.name);
  } else {
    NSLog(@"Error: %@", message);
    title = @"Error";
  }

  [self showGrowlWithTitle: title message: message type: RepositoryUpdateFailedGrowl];
}

- (void) showGrowlWithTitle: (NSString *) title message: (NSString *) message type: (NSString *) type {
  [GrowlApplicationBridge notifyWithTitle: title
                              description: message
                         notificationName: type
                                 iconData: [self growlIcon]
                                 priority: 0
                                 isSticky: NO
                             clickContext: nil];
}

- (NSData *) growlIcon {
  static NSData *icon = nil;
  if (!icon) {
    icon = [[NSImage imageNamed: @"icon_app_32.png"] TIFFRepresentation];
  }
  return icon;
}

- (void) growlNotificationWasClicked: (id) clickContext {
  // temporary fix for a bug in Growl 1.3
  // see http://code.google.com/p/growl/issues/detail?id=377
  id date = clickContext[@"commit"][@"date"];
  if ([date isKindOfClass: [NSString class]]) return;

  BOOL shouldShowDiffs = [GitifierDefaults boolForKey: ShowDiffWindowKey];
  BOOL shouldOpenInBrowser = [GitifierDefaults boolForKey: OpenDiffInBrowserKey];
  
  if (clickContext && shouldShowDiffs) {
    NSString *url = clickContext[@"repository"];
    NSDictionary *commitHash = clickContext[@"commit"];
    Repository *repository = [self.repositoryListController findByUrl: url];

    if (repository) {
      Commit *commit = [Commit commitFromDictionary: commitHash];
      commit.repository = repository;
      NSURL *webUrl = [repository webUrlForCommit: commit];

      if (webUrl && shouldOpenInBrowser) {
        [[NSWorkspace sharedWorkspace] openURL: webUrl];
      } else {
        [[[CommitWindowController alloc] initWithCommit: commit] show];
      }
    }
  }
}

@end
