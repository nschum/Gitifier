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

@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSMenu *statusBarMenu;

// private
- (void) createStatusBarItem;

@end
