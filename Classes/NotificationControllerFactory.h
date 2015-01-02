@protocol NotificationController;

@interface NotificationControllerFactory : NSObject

+ (id<NotificationController>) sharedController;

@end
