// -------------------------------------------------------
// NewRepositoryDialogController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "NewRepositoryDialogController.h"
#import "Repository.h"
#import "RepositoryListController.h"

@implementation NewRepositoryDialogController

@synthesize repositoryListController, newRepositoryUrl, label, spinner, addButton, cancelButton;

- (void) awakeFromNib {
  labelText = label.stringValue;
}

- (IBAction) showNewRepositorySheet: (id) sender {
  [newRepositoryUrl setStringValue: @""];
  [NSApp beginSheet: [self window]
     modalForWindow: [sender window]
      modalDelegate: nil
     didEndSelector: nil
        contextInfo: nil];
}

- (IBAction) addRepository: (id) sender {
  NSString *url = newRepositoryUrl.stringValue;
  if ([url isEqual: @""]) {
    return;
  }

  NSArray *existing = [[repositoryListController repositoryList] valueForKeyPath: @"url"];
  if ([existing indexOfObject: url] != NSNotFound) {
    [self.window psShowAlertSheetWithTitle: @"This URL is already on the list."
                                   message: @"Try to find something more interesting to monitor..."];
    return;
  }

  editedRepository = [[Repository alloc] initWithUrl: url];
  if (!editedRepository) {
    [self.window psShowAlertSheetWithTitle: @"This URL is invalid or not supported."
                 message: @"Try a URL that starts with git://, ssh://, http(s)://, ftp(s):// or rsync://."];
    return;
  }

  [self lockDialog];
  [editedRepository setDelegate: self];
  [editedRepository clone];
  [self setupSlowCloneTimer];
}

- (IBAction) cancelAddingRepository: (id) sender {
  if (editedRepository) {
    [editedRepository cancelCommands];
    [self unlockDialog];
  } else {
    [self hideNewRepositorySheet];
  }
}

- (void) lockDialog {
  [spinner startAnimation: self];
  [addButton psDisable];
  [newRepositoryUrl psDisable];
}

- (void) unlockDialog {
  [spinner stopAnimation: self];
  [addButton psEnable];
  [newRepositoryUrl psEnable];
  [self hideSlowCloneWarning];
  [slowCloneTimer invalidate];
  slowCloneTimer = nil;
  editedRepository = nil;
}

- (void) hideNewRepositorySheet {
  [NSApp endSheet: self.window];
  [self.window orderOut: self];
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
  [repositoryListController addRepository: repository];
  [self hideNewRepositorySheet];
  [self unlockDialog];
}

- (void) repositoryCouldNotBeCloned: (Repository *) repository {
  [self unlockDialog];
  [self.window psShowAlertSheetWithTitle: @"Repository could not be cloned."
                                 message: @"Make sure you have entered a correct URL."];
  // TODO: fix enter
}

@end
