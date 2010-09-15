// -------------------------------------------------------
// GitifierAppDelegate.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class Repository;

@interface GitifierAppDelegate : NSObject <NSApplicationDelegate> {
  NSStatusItem *statusBarItem;
  Repository *editedRepository;
}

@property (assign) IBOutlet NSMenu *statusBarMenu;
@property IBOutlet NSWindow *preferencesWindow;
@property IBOutlet NSWindow *addRepositoryWindow;
@property IBOutlet NSTextField *newRepositoryUrl;
@property IBOutlet NSArrayController *repositoryListController;
@property IBOutlet NSProgressIndicator *spinner;
@property IBOutlet NSButton *cancelButton;
@property IBOutlet NSButton *addButton;

// public
- (IBAction) showPreferences: (id) sender;
- (IBAction) showAddRepositorySheet: (id) sender;
- (IBAction) addRepository: (id) sender;
- (IBAction) cancelAddingRepository: (id) sender;

// private
- (void) createStatusBarItem;
- (void) lockAddRepositoryDialog;
- (void) unlockAddRepositoryDialog;
- (void) hideAddRepositorySheet;

@end
