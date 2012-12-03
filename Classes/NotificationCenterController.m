#import "NotificationCenterController.h"

#import "Commit.h"
#import "Repository.h"
#import "PSMacros.h"
#import "RepositoryListController.h"
#import "NotificationControllerClickHandler.h"

@interface NotificationCenterController () <NSUserNotificationCenterDelegate>
@end

@implementation NotificationCenterController

+ (BOOL) notificationCenterDetected {
  return NSClassFromString(@"NSUserNotification") != nil;
}

- (id) init {
  self = [super init];
  if (self) {
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
  }
  return self;
}

- (void) showNotificationWithCommit: (Commit *) commit {
  NSDictionary *commitData = @{@"commit": [commit toDictionary], @"repository": commit.repository.url};
  [self showNotificationWithTitle:commit.repository.name
                         subtitle:commit.authorName
                          message:commit.subject
                             info:commitData];
}

- (void) showNotificationWithCommitGroup: (NSArray *) commits includesAllCommits: (BOOL) includesAll {
  NSArray *authorNames = [commits valueForKeyPath: @"@distinctUnionOfObjects.authorName"];
  NSString *authorList = [authorNames componentsJoinedByString: @", "];
  NSString *message = includesAll ? @"%d commits received" : @"… and %d other commits";

  [self showNotificationWithTitle:PSFormat(message, commits.count)
                         subtitle:nil
                          message:PSFormat(@"Author%@: %@", (authorNames.count > 1) ? @"s" : @"", authorList)
                             info:nil];
}

- (void) showNotificationWithCommitGroupIncludingAllCommits: (NSArray *) commits {
  [self showNotificationWithCommitGroup: commits includesAllCommits: YES];
}

- (void) showNotificationWithCommitGroupIncludingSomeCommits: (NSArray *) commits {
  [self showNotificationWithCommitGroup: commits includesAllCommits: NO];
}

- (void) showNotificationWithError: (NSString *) message repository: (Repository *) repository {
  NSString *title;
  if (repository) {
    NSLog(@"Error in %@: %@", repository.name, message);
    title = PSFormat(@"Error in %@", repository.name);
  } else {
    NSLog(@"Error: %@", message);
    title = @"Error";
  }

  [self showNotificationWithTitle: title subtitle: nil message: message info: nil];
}

- (void) showNotificationWithTitle: (NSString *) title message: (NSString *) message type: (NSString *) type {
  [self showNotificationWithTitle: title subtitle: nil message: message info: nil];
}

- (void) showNotificationWithTitle: (NSString *) title subtitle: (NSString *) subtitle message: (NSString *) message info: (NSDictionary *) info {

  NSUserNotification *notification = [[NSUserNotification alloc] init];
  notification.title = title;
  notification.subtitle = subtitle;
  notification.informativeText = message;
  notification.userInfo = info;
  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification {

  NotificationControllerClickHandler *handler = [NotificationControllerClickHandler new];
  handler.repositoryListController = self.repositoryListController;
  [handler handleClickWithDictionary: notification.userInfo];
}

@end
