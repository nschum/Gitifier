// -------------------------------------------------------
// GrowlController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>

#define CommitReceivedGrowl @"Commit received"
#define RepositoryUpdateFailedGrowl @"Repository update failed"
#define OtherMessageGrowl @"Other message"

@class Commit;
@class Repository;
@class RepositoryListController;

@interface GrowlController : NSObject <GrowlApplicationBridgeDelegate> {
  RepositoryListController *repositoryListController;
}

@property RepositoryListController *repositoryListController;

// public
+ (GrowlController *) sharedController;
- (void) checkGrowlAvailability;
- (void) showGrowlWithCommit: (Commit *) commit repository: (Repository *) repository;
- (void) showGrowlWithError: (NSString *) message repository: (Repository *) repository;
- (void) showGrowlWithTitle: (NSString *) title message: (NSString *) message type: (NSString *) type;

// private
- (void) openGrowlPreferences;
- (NSData *) growlIcon;

@end
