#import "NotificationControllerFactory.h"
#import "GrowlController.h"

@implementation NotificationControllerFactory

+ (id<NotificationController>) sharedController {
  static GrowlController *instance = nil;
  if (!instance) {
    instance = [[GrowlController alloc] init];
  }
  return instance;
}

@end
