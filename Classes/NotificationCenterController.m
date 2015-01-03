#import "NotificationCenterController.h"

#import "Commit.h"
#import "Repository.h"
#import "PSMacros.h"
#import "RepositoryListController.h"
#import "NotificationControllerClickHandler.h"

@interface NotificationCenterController () <NSUserNotificationCenterDelegate>
@end

@implementation NotificationCenterController

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
  unsigned long count = commits.count;
  NSString *message = includesAll ? PSFormat(@"%lud commits received", count) : PSFormat(@"… and %lud other commits", count);

  [self showNotificationWithTitle:((Commit *)commits[0]).repository.name
                         subtitle:authorList
                          message:message
                             info:nil];
}

- (void) showNotificationWithCommitGroupIncludingAllCommits: (NSArray *) commits {
  [self showNotificationWithCommitGroup: commits includesAllCommits: YES];
}

- (void) showNotificationWithCommitGroupIncludingSomeCommits: (NSArray *) commits {
  [self showNotificationWithCommitGroup: commits includesAllCommits: NO];
}

- (void) showNotificationWithError: (NSString *) message repository: (Repository *) repository {
  if (repository) {
    NSLog(@"Error in %@: %@", repository.name, message);
  } else {
    NSLog(@"Error: %@", message);
  }

  [self showNotificationWithTitle: @"Error" subtitle: repository.name message: message info: nil];
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

  [center removeDeliveredNotification: notification];
}

@end
