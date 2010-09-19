// -------------------------------------------------------
// GitifierAppDelegate.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class Monitor;
@class RepositoryListController;
@class StatusBarController;

@interface GitifierAppDelegate : NSObject <NSApplicationDelegate> {
  NSString *userEmail;
}

@property (assign) NSMutableArray *repositoryList;
@property IBOutlet Monitor *monitor;
@property IBOutlet StatusBarController *statusBarController;
@property IBOutlet RepositoryListController *repositoryListController;

// private
- (void) updateUserEmail;

@end
