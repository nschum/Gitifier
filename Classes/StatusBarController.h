// -------------------------------------------------------
// StatusBarController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface StatusBarController : NSObject {
  NSStatusItem *statusBarItem;
  NSMenu *statusBarMenu;
}

@property (assign) IBOutlet NSMenu *statusBarMenu;

// public
- (void) createStatusBarItem;

@end
