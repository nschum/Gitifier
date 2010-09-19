// -------------------------------------------------------
// StatusBarController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "StatusBarController.h"

@implementation StatusBarController

@synthesize statusBarMenu;

- (void) createStatusBarItem {
  statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSSquareStatusItemLength];
  if (!statusBarItem) {
    NSRunAlertPanel(@"Error", @"Gitifier menu could not be created :(", @"That's a shame", nil, nil);
    [NSApp terminate: self];
  }

  statusBarItem.image = [NSImage imageNamed: @"menu_icon.png"];
  statusBarItem.highlightMode = YES;
  statusBarItem.menu = statusBarMenu;
}

@end
