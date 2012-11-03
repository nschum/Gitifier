// -------------------------------------------------------
// GitifierAppDelegate.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@class Monitor;
@class PreferencesWindowController;
@class RepositoryListController;
@class StatusBarController;

@interface GitifierAppDelegate : NSObject <NSApplicationDelegate>

@property (strong, readonly) NSString *userEmail;
@property (strong, readonly) NSMutableArray *repositoryList;
@property /*(weak)*/ IBOutlet Monitor *monitor;
@property /*(weak)*/ IBOutlet StatusBarController *statusBarController;
@property /*(weak)*/ IBOutlet PreferencesWindowController *preferencesWindowController;
@property /*(weak)*/ IBOutlet RepositoryListController *repositoryListController;

- (IBAction) showPreferences: (id) sender;
- (IBAction) quit: (id) sender;
- (IBAction) checkNow: (id) sender;

@end
