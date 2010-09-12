// -------------------------------------------------------
// GitifierAppDelegate.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "GitifierAppDelegate.h"

@implementation GitifierAppDelegate

@synthesize preferencesWindow, statusBarMenu;

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
  [self createStatusBarItem];
}

- (void) createStatusBarItem {
  statusBarItem = [[[NSStatusBar systemStatusBar] statusItemWithLength: NSSquareStatusItemLength] retain];
  if (!statusBarItem) {
    NSRunAlertPanel(@"Error", @"Gitifier menu could not be created :(", @"That's a shame", nil, nil);
    [NSApp terminate: self];
  }

  statusBarItem.image = [NSImage imageNamed: @"menu_icon.png"];
  statusBarItem.highlightMode = YES;
  statusBarItem.menu = statusBarMenu;
}

- (IBAction) showPreferences: (id) sender {
  // TODO: fix cmd+w
  [preferencesWindow makeKeyAndOrderFront: self];
}

@end
