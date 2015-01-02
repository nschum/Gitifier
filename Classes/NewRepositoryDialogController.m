// -------------------------------------------------------
// NewRepositoryDialogController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "GrowlController.h"
#import "NewRepositoryDialogController.h"
#import "Repository.h"
#import "RepositoryListController.h"
#import "NotificationControllerFactory.h"

@implementation NewRepositoryDialogController {
  NSTimer *slowCloneTimer;
  NSString *labelText;
  Repository *editedRepository;
  BOOL waitingForSlowClone;
}

- (void) awakeFromNib {
  labelText = self.label.stringValue;
  waitingForSlowClone = NO;
}

- (IBAction) showNewRepositorySheet: (id) sender {
  [self.repositoryUrlField setStringValue: @""];
  [NSApp beginSheet: [self window]
     modalForWindow: [sender window]
      modalDelegate: nil
     didEndSelector: nil
        contextInfo: nil];
}

- (IBAction) addRepository: (id) sender {
  NSString *url = [self.repositoryUrlField.stringValue psTrimmedString];
  if ([url isEqual: @""]) {
    return;
  }

  NSArray *existing = [self.repositoryListController.repositoryList valueForKeyPath: @"url"];
  if ([existing indexOfObject: url] != NSNotFound) {
    [self showAlertWithTitle: @"This URL is already on the list."
                     message: @"Try to find something more interesting to monitor..."];
    return;
  }

  editedRepository = [[Repository alloc] initWithUrl: url];
  if (!editedRepository) {
    [self showAlertWithTitle: @"This doesn't look like a git URL."
                     message: @"Please enter a proper git repository address."];
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

- (void) showAlertWithTitle: (NSString *) title message: (NSString *) message {
  NSAlert *alertWindow = [[NSAlert alloc] init];
  [alertWindow addButtonWithTitle: @"OK"];
  [alertWindow setMessageText: title];
  [alertWindow setInformativeText: message];
  [alertWindow beginSheetModalForWindow: self.window
                          modalDelegate: self
                         didEndSelector: @selector(modalWasClosed:)
                            contextInfo: nil];
  [NSApp runModalForWindow: self.window];
}

- (void) modalWasClosed: (NSAlert *) alert {
  [NSApp stopModal];
  [self.repositoryUrlField becomeFirstResponder];
}

- (void) lockDialog {
  [self.spinner startAnimation: self];
  [self.addButton psDisable];
  [self.repositoryUrlField psDisable];
}

- (void) unlockDialog {
  [self.spinner stopAnimation: self];
  [self.addButton psEnable];
  [self.repositoryUrlField psEnable];
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
  waitingForSlowClone = YES;
  self.label.stringValue = @"Please be patient - I'm cloning the repository...";
  self.label.textColor = [NSColor textColor];
}

- (void) hideSlowCloneWarning {
  waitingForSlowClone = NO;
  self.label.stringValue = labelText;
  self.label.textColor = [NSColor disabledControlTextColor];
}

- (void) repositoryWasCloned: (Repository *) repository {
  [self.repositoryListController addRepository: repository];
  [self hideNewRepositorySheet];

  if (waitingForSlowClone) {
    id<NotificationController>growl = [NotificationControllerFactory sharedController];
    [growl showNotificationWithTitle: @"Repository cloned"
                             message: PSFormat(@"Repository at %@ has been successfully added to Gitifier.", repository.url) type: OtherMessageGrowl];
  }

  [self unlockDialog];
}

- (void) repositoryCouldNotBeCloned: (Repository *) repository {
  [self unlockDialog];
  [self showAlertWithTitle: @"Repository could not be cloned."
                   message: @"Make sure you have entered a correct URL."];
}

@end
