// -------------------------------------------------------
// GitifierAppDelegate.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "GitifierAppDelegate.h"
#import "Repository.h"

@implementation GitifierAppDelegate

@synthesize preferencesWindow, statusBarMenu, addRepositoryWindow, newRepositoryUrl, repositoryListController, spinner;

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
      modalDelegate: nil
     didEndSelector: nil
        contextInfo: nil];
}

- (IBAction) addRepository: (id) sender {
  Repository *repository = [[Repository alloc] initWithUrl: newRepositoryUrl.stringValue];
  if (repository) {
    [repository setDelegate: self];
    [repository clone];
    [spinner startAnimation: self];
  } else {
    [addRepositoryWindow psShowAlertSheetWithTitle: @"This URL is invalid or not supported."
                                           message: @"Try a URL that starts with git://, ssh://, http(s)://, "
                                                    @"ftp(s):// or rsync://."];
  }
}

- (void) repositoryWasCloned: (Repository *) repository {
  [repositoryListController addObject: repository];
  [repositoryListController setSelectionIndex: NSNotFound];
  [spinner stopAnimation: self];
  [self hideAddRepositorySheet: self];
}

- (void) repositoryCouldNotBeCloned: (Repository *) repository {
  [spinner stopAnimation: self];
  [addRepositoryWindow psShowAlertSheetWithTitle: @"Repository could not be cloned."
                                         message: @"Make sure you have entered a correct URL."];
  // TODO: fix enter
}

- (IBAction) hideAddRepositorySheet: (id) sender {
  [NSApp endSheet: addRepositoryWindow];
  [addRepositoryWindow orderOut: self];
}

@end
