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

@synthesize repositoryListController;

+ (GrowlController *) sharedController {
  static GrowlController *instance = nil;
  if (!instance) {
    instance = [[GrowlController alloc] init];
  }
  return instance;
}

- (id) init {
  self = [super init];
  if (self) {
    [GrowlApplicationBridge setGrowlDelegate: self];
  }
  return self;
}

- (void) showGrowlWithCommit: (Commit *) commit repository: (Repository *) repository {
  BOOL sticky = [GitifierDefaults boolForKey: StickyNotificationsKey];
  NSDictionary *commitData = PSHash(@"commit", [commit toDictionary], @"repository", repository.url);

  [GrowlApplicationBridge notifyWithTitle: PSFormat(@"%@ – %@", repository.name, commit.authorName)
                              description: commit.subject
                         notificationName: CommitReceivedGrowl
                                 iconData: [self growlIcon]
                                 priority: 0
                                 isSticky: sticky
                             clickContext: commitData];
}

- (void) showGrowlWithCommitGroup: (NSArray *) commits
               includesAllCommits: (BOOL) includesAll
                       repository: (Repository *) repository {
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
  BOOL shouldShowDiffs = [GitifierDefaults boolForKey: ShowDiffWindowKey];
  BOOL shouldOpenInBrowser = [GitifierDefaults boolForKey: OpenDiffInBrowserKey];
  
  if (clickContext && shouldShowDiffs) {
    NSString *url = [clickContext objectForKey: @"repository"];
    NSDictionary *commitHash = [clickContext objectForKey: @"commit"];
    Repository *repository = [repositoryListController findByUrl: url];
    Commit *commit = [Commit commitFromDictionary: commitHash];
    NSURL *webUrl = [repository webUrlForCommit: commit];
    
    if (repository) {
      if (webUrl && shouldOpenInBrowser) {
        [[NSWorkspace sharedWorkspace] openURL: webUrl];
      } else {
        CommitWindowController *window = [[CommitWindowController alloc] initWithRepository: repository commit: commit];
        [window showWindow: self];
        [NSApp activateIgnoringOtherApps: YES];
      }
    }
  }
}

@end
