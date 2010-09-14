// -------------------------------------------------------
// GitifierAppDelegate.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "GitifierAppDelegate.h"
#import "Repository.h"

@implementation GitifierAppDelegate

@synthesize preferencesWindow, statusBarMenu, addRepositoryWindow, newRepositoryUrl, repositoryListController;

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
  // TODO: focus on add
  [preferencesWindow makeKeyAndOrderFront: self];
}

- (IBAction) showAddRepositorySheet: (id) sender {
  newRepositoryUrl.stringValue = @"";
  [NSApp beginSheet: addRepositoryWindow
     modalForWindow: preferencesWindow
      modalDelegate: self
     didEndSelector: nil
        contextInfo: nil];
}

- (IBAction) addRepository: (id) sender {
  Repository *repository = [[Repository alloc] initWithUrl: newRepositoryUrl.stringValue];
  [repositoryListController addObject: repository];
  [repositoryListController setSelectionIndex: NSNotFound];
  [self hideAddRepositorySheet: self];
}

- (IBAction) hideAddRepositorySheet: (id) sender {
  [NSApp endSheet: addRepositoryWindow];
  [addRepositoryWindow orderOut: self];
}

@end
