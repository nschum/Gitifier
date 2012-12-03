#import "NotificationCenterController.h"

#import "Commit.h"
#import "Repository.h"
#import "PSMacros.h"

@implementation NotificationCenterController

+ (BOOL) notificationCenterDetected {
  return NSClassFromString(@"NSUserNotification") != nil;
}

- (void) showNotificationWithCommit: (Commit *) commit {
  [self showNotificationWithTitle:commit.repository.name
                         subtitle:commit.authorName
                          message:commit.subject];
}

- (void) showNotificationWithCommitGroup: (NSArray *) commits includesAllCommits: (BOOL) includesAll {
  NSArray *authorNames = [commits valueForKeyPath: @"@distinctUnionOfObjects.authorName"];
  NSString *authorList = [authorNames componentsJoinedByString: @", "];
  NSString *message = includesAll ? @"%d commits received" : @"… and %d other commits";

  [self showNotificationWithTitle:PSFormat(message, commits.count)
                         subtitle:nil
                          message:PSFormat(@"Author%@: %@", (authorNames.count > 1) ? @"s" : @"", authorList)];
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

  [self showNotificationWithTitle: title subtitle: nil message: message];
}

- (void) showNotificationWithTitle: (NSString *) title message: (NSString *) message type: (NSString *) type {
  [self showNotificationWithTitle: title
                         subtitle: nil
                          message: message];
}

- (void) showNotificationWithTitle: (NSString *) title
                          subtitle: (NSString *) subtitle
                           message: (NSString *) message {

  NSUserNotification *notification = [[NSUserNotification alloc] init];
  notification.title = title;
  notification.subtitle = subtitle;
  notification.informativeText = message;
  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end
