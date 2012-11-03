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
@property IBOutlet Monitor *monitor;
@property IBOutlet StatusBarController *statusBarController;
@property IBOutlet PreferencesWindowController *preferencesWindowController;
@property IBOutlet RepositoryListController *repositoryListController;

// public
- (IBAction) showPreferences: (id) sender;
- (IBAction) quit: (id) sender;
- (IBAction) checkNow: (id) sender;

// private
- (void) askAboutStats;
- (void) updateUserEmail;
- (void) loadGitPath;
- (void) findGitPath;
- (void) validateGitPath;

@end
