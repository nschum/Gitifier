// -------------------------------------------------------
// GrowlController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Growl/GrowlApplicationBridge.h>
#import "NotificationController.h"

@class Commit;
@class Repository;
@class RepositoryListController;

extern NSString *OtherMessageGrowl;

@interface GrowlController : NSObject <GrowlApplicationBridgeDelegate, NotificationController>

@property RepositoryListController *repositoryListController;

+ (BOOL) growlDetected;

@end
