// -------------------------------------------------------
// StatusBarController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
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

  statusBarItem.image = [NSImage imageNamed: @"icon_menu.png"];
  statusBarItem.alternateImage = [NSImage imageNamed: @"icon_menu_inverted.png"];
  statusBarItem.highlightMode = YES;
  statusBarItem.menu = statusBarMenu;
}

@end
