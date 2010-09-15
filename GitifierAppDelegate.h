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

@property (nonatomic, retain) IBOutlet NSWindow *preferencesWindow;
@property (nonatomic, retain) IBOutlet NSWindow *addRepositoryWindow;
@property (nonatomic, retain) IBOutlet NSMenu *statusBarMenu;
@property (nonatomic, retain) IBOutlet NSTextField *newRepositoryUrl;
@property (nonatomic, retain) IBOutlet NSArrayController *repositoryListController;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *spinner;

// public
- (IBAction) showPreferences: (id) sender;
- (IBAction) showAddRepositorySheet: (id) sender;
- (IBAction) addRepository: (id) sender;
- (IBAction) hideAddRepositorySheet: (id) sender;

// private
- (void) createStatusBarItem;

@end
