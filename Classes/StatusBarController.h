// -------------------------------------------------------
// StatusBarController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface StatusBarController : NSObject {
  NSStatusItem *statusBarItem;
}

@property (assign) IBOutlet NSMenu *statusBarMenu;

// public
- (void) createStatusBarItem;

@end
