// -------------------------------------------------------
// GrowlController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>

@class Commit;
@class Repository;
@class RepositoryListController;

extern NSString *OtherMessageGrowl;

@interface GrowlController : NSObject <GrowlApplicationBridgeDelegate> {
  RepositoryListController *repositoryListController;
}

@property RepositoryListController *repositoryListController;

// public
+ (GrowlController *) sharedController;
- (void) showGrowlWithCommit: (Commit *) commit repository: (Repository *) repository;
- (void) showGrowlWithError: (NSString *) message repository: (Repository *) repository;
- (void) showGrowlWithTitle: (NSString *) title message: (NSString *) message type: (NSString *) type;

// private
- (NSData *) growlIcon;

@end
