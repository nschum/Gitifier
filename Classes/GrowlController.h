// -------------------------------------------------------
// GrowlController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>

#define CommitReceivedGrowl @"Commit received"
#define RepositoryUpdateFailedGrowl @"Repository update failed"

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
- (void) showGrowlWithError: (NSString *) message repository: (Repository *) repository;
- (void) showGrowlWithCommit: (Commit *) commit repository: (Repository *) repository;

// private
- (void) openGrowlPreferences;
- (NSData *) growlIcon;

@end
