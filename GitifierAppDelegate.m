// -------------------------------------------------------
// GitifierAppDelegate.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "GitifierAppDelegate.h"
#import "Repository.h"

@implementation GitifierAppDelegate

@synthesize preferencesWindow, statusBarMenu, addRepositoryWindow, newRepositoryUrl, repositoryListController,
  spinner, addButton, cancelButton;

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

- (IBAction) showAddRepositorySheet: (id) sender {
  newRepositoryUrl.stringValue = @"";
  [NSApp beginSheet: addRepositoryWindow
     modalForWindow: preferencesWindow
      modalDelegate: nil
     didEndSelector: nil
        contextInfo: nil];
}

- (IBAction) addRepository: (id) sender {
  editedRepository = [[Repository alloc] initWithUrl: newRepositoryUrl.stringValue];
  if (editedRepository) {
    [self lockAddRepositoryDialog];
    [editedRepository setDelegate: self];
    [editedRepository clone];
  } else {
    [addRepositoryWindow psShowAlertSheetWithTitle: @"This URL is invalid or not supported."
                                           message: @"Try a URL that starts with git://, ssh://, http(s)://, "
                                                    @"ftp(s):// or rsync://."];
  }
}

- (IBAction) cancelAddingRepository: (id) sender {
  if (editedRepository) {
    [editedRepository cancelCommands];
    [self unlockAddRepositoryDialog];
  } else {
    [self hideAddRepositorySheet];
  }
}

- (void) lockAddRepositoryDialog {
  [spinner startAnimation: self];
  [addButton psDisable];
  [newRepositoryUrl psDisable];
}

- (void) unlockAddRepositoryDialog {
  [spinner stopAnimation: self];
  [addButton psEnable];
  [newRepositoryUrl psEnable];
  editedRepository = nil;
}

- (void) repositoryWasCloned: (Repository *) repository {
  [repositoryListController addObject: repository];
  [repositoryListController setSelectionIndex: NSNotFound];
  [self hideAddRepositorySheet];
  [self unlockAddRepositoryDialog];
}

- (void) repositoryCouldNotBeCloned: (Repository *) repository {
  [self unlockAddRepositoryDialog];
  [addRepositoryWindow psShowAlertSheetWithTitle: @"Repository could not be cloned."
                                         message: @"Make sure you have entered a correct URL."];
  // TODO: fix enter
}

- (void) hideAddRepositorySheet {
  [NSApp endSheet: addRepositoryWindow];
  [addRepositoryWindow orderOut: self];
}

@end
