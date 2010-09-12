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
@property (nonatomic, retain) IBOutlet NSMenu *statusBarMenu;

// public
- (IBAction) showPreferences: (id) sender;

// private
- (void) createStatusBarItem;

@end
