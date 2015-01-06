// -------------------------------------------------------
// GrowlController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Commit.h"
#import "Defaults.h"
#import "GrowlController.h"
#import "Repository.h"
#import "NotificationControllerClickHandler.h"

static NSString *CommitReceivedGrowl = @"Commit received";
static NSString *RepositoryUpdateFailedGrowl = @"Repository update failed";
NSString *OtherMessageGrowl = @"Other message";


@implementation GrowlController

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

- (void) showNotificationWithCommit: (Commit *) commit {
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

- (void) showNotificationWithCommitGroup: (NSArray *) commits includesAllCommits: (BOOL) includesAll {
  BOOL sticky = [GitifierDefaults boolForKey: StickyNotificationsKey];
  NSArray *authorNames = [commits valueForKeyPath: @"@distinctUnionOfObjects.authorName"];
  NSString *authorList = [authorNames componentsJoinedByString: @", "];
  unsigned long count = commits.count;
  NSString *message = includesAll ? PSFormat(@"%lu commits received", count) : PSFormat(@"… and %lu other commits", count);

  [GrowlApplicationBridge notifyWithTitle: message
                              description: PSFormat(@"Author%@: %@", (authorNames.count > 1) ? @"s" : @"", authorList)
                         notificationName: CommitReceivedGrowl
                                 iconData: [self growlIcon]
                                 priority: 0
                                 isSticky: sticky
                             clickContext: nil];
}

- (void) showNotificationWithCommitGroupIncludingAllCommits: (NSArray *) commits {
  [self showNotificationWithCommitGroup: commits includesAllCommits: YES];
}

- (void) showNotificationWithCommitGroupIncludingSomeCommits: (NSArray *) commits {
  [self showNotificationWithCommitGroup: commits includesAllCommits: NO];
}

- (void) showNotificationWithTitle: (NSString *) title message: (NSString *) message type: (NSString *) type {
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

  NotificationControllerClickHandler *handler = [NotificationControllerClickHandler new];
  handler.repositoryListController = self.repositoryListController;
  [handler handleClickWithDictionary: clickContext];
}

@end
