// -------------------------------------------------------
// GitifierAppDelegate.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Growl/GrowlApplicationBridge.h>
#import "Commit.h"
#import "GitifierAppDelegate.h"
#import "Repository.h"

@implementation GitifierAppDelegate

@synthesize preferencesWindow, statusBarMenu, addRepositoryWindow, newRepositoryUrl, repositoryListController,
  spinner, addButton, cancelButton, label, monitor;

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
  id nullDelegate = @"";
  [GrowlApplicationBridge setGrowlDelegate: nullDelegate];
  [self createStatusBarItem];
  [monitor startMonitoring];
}

- (void) awakeFromNib {
  labelText = label.stringValue;
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
  NSString *url = newRepositoryUrl.stringValue;
  NSArray *existing = [[self repositoryList] valueForKeyPath: @"url"];
  if ([existing indexOfObject: url] == NSNotFound) {
    editedRepository = [[Repository alloc] initWithUrl: url];
    if (editedRepository) {
      [self lockAddRepositoryDialog];
      [editedRepository setDelegate: self];
      [editedRepository clone];
      [self setupSlowCloneTimer];
    } else {
      [addRepositoryWindow psShowAlertSheetWithTitle: @"This URL is invalid or not supported."
                           message: @"Try a URL that starts with git://, ssh://, http(s)://, ftp(s):// or rsync://."];
    }
  } else {
    [addRepositoryWindow psShowAlertSheetWithTitle: @"This URL is already on the list."
                                           message: @"Try to find something more interesting to monitor..."];
  }
}

- (NSArray *) repositoryList {
  return [repositoryListController arrangedObjects];
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
  [self hideSlowCloneWarning];
  [slowCloneTimer invalidate];
  slowCloneTimer = nil;
  editedRepository = nil;
}

- (void) setupSlowCloneTimer {
  slowCloneTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0
                                                    target: self
                                                  selector: @selector(showSlowCloneWarning)
                                                  userInfo: nil
                                                   repeats: NO];
}

- (void) showSlowCloneWarning {
  label.stringValue = @"Please be patient - I'm cloning the repository...";
  label.textColor = [NSColor textColor];
}

- (void) hideSlowCloneWarning {
  label.stringValue = labelText;
  label.textColor = [NSColor disabledControlTextColor];
}

- (void) repositoryWasCloned: (Repository *) repository {
  [repository setDelegate: self];
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

- (void) commitsReceived: (NSArray *) commits inRepository: (Repository *) repository {
  for (Commit *commit in [commits reverseObjectEnumerator]) {
    [GrowlApplicationBridge notifyWithTitle: PSFormat(@"%@ – %@", commit.author, repository.name)
                                description: commit.subject
                           notificationName: @"Commit received"
                                   iconData: nil
                                   priority: 0
                                   isSticky: NO
                               clickContext: nil];
  }
}

- (void) hideAddRepositorySheet {
  [NSApp endSheet: addRepositoryWindow];
  [addRepositoryWindow orderOut: self];
}

@end
