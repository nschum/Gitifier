#import "NotificationController.h"

/** Implementation of the NotificationController protocol for OS X notification center. */
@interface NotificationCenterController : NSObject<NotificationController>

@property RepositoryListController *repositoryListController;

@end
