#import "NotificationControllerFactory.h"
#import "GrowlController.h"
#import "NotificationCenterController.h"

@implementation NotificationControllerFactory

+ (id<NotificationController>) sharedController {
  static id<NotificationController> instance = nil;
  if (!instance) {
    if ([self isUseNotificationCenter]) {
      instance = [[NotificationCenterController alloc] init];
    } else {
      instance = [[GrowlController alloc] init];
    }
  }
  return instance;
}

+ (BOOL) isUseNotificationCenter {
  return ![GrowlController growlDetected];
}

@end
