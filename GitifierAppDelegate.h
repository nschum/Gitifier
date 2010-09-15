// -------------------------------------------------------
// GitifierAppDelegate.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface GitifierAppDelegate : NSObject <NSApplicationDelegate> {
  NSStatusItem *statusBarItem;
}

@property (assign) IBOutlet NSMenu *statusBarMenu;
@property IBOutlet NSWindow *preferencesWindow;
@property IBOutlet NSWindow *addRepositoryWindow;
@property IBOutlet NSTextField *newRepositoryUrl;
@property IBOutlet NSArrayController *repositoryListController;
@property IBOutlet NSProgressIndicator *spinner;

// public
- (IBAction) showPreferences: (id) sender;
- (IBAction) showAddRepositorySheet: (id) sender;
- (IBAction) addRepository: (id) sender;
- (IBAction) hideAddRepositorySheet: (id) sender;

// private
- (void) createStatusBarItem;

@end
