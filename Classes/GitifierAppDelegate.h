// -------------------------------------------------------
// GitifierAppDelegate.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>

@class Monitor;
@class PreferencesWindowController;
@class RepositoryListController;
@class StatusBarController;

@interface GitifierAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate> {
  NSString *userEmail;
  NSMutableArray *repositoryList;
  Monitor *monitor;
  StatusBarController *statusBarController;
  PreferencesWindowController *preferencesWindowController;
  RepositoryListController *repositoryListController;
}

@property (readonly) NSString *userEmail;
@property (assign) NSMutableArray *repositoryList;
@property IBOutlet Monitor *monitor;
@property IBOutlet StatusBarController *statusBarController;
@property IBOutlet PreferencesWindowController *preferencesWindowController;
@property IBOutlet RepositoryListController *repositoryListController;

- (IBAction) showPreferences: (id) sender;
- (IBAction) quit: (id) sender;
- (void) showGrowlWithError: (NSString *) message;

// private
- (void) openGrowlPreferences;
- (void) updateUserEmail;
- (void) loadGitPath;
- (void) findGitPath;
- (void) validateGitPath;
- (NSData *) growlIcon;

@end
