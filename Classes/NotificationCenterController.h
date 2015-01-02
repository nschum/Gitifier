#import "NotificationController.h"

/** Implementation of the NotificationCenter protocol for Mountain Lion's notification center. */
@interface NotificationCenterController : NSObject<NotificationController>

@property RepositoryListController *repositoryListController;

+ (BOOL) notificationCenterDetected;

@end
