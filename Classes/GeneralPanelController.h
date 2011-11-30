// -------------------------------------------------------
// GeneralPanelController.h
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "MASPreferencesViewController.h"

@interface GeneralPanelController : NSViewController <MASPreferencesViewController, NSOpenSavePanelDelegate> {
  NSNumberFormatter *numberFormatter;
  NSTextField *monitorIntervalField;
  NSButton *chooseGitPathButton;
  NSButton *ignoreOwnEmailsField;
}

@property IBOutlet NSTextField *monitorIntervalField;
@property IBOutlet NSButton *chooseGitPathButton;
@property IBOutlet NSButton *ignoreOwnEmailsField;
@property (readonly) id gitClass;

// @public
- (IBAction) openGitExecutableDialog: (id) sender;

// @private
- (void) updateUserEmailText: (NSString *) email;

@end
