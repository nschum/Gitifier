// -------------------------------------------------------
// GrowlController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "NotificationController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation-deprecated-sync"
#pragma clang diagnostic ignored "-Wdocumentation"
#import <Growl/GrowlApplicationBridge.h>
#pragma clang diagnostic pop

@class Commit;
@class Repository;
@class RepositoryListController;

extern NSString *OtherMessageGrowl;

@interface GrowlController : NSObject <GrowlApplicationBridgeDelegate, NotificationController>

@property RepositoryListController *repositoryListController;

+ (BOOL) growlDetected;

@end
