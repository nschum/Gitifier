// -------------------------------------------------------
// NewRepositoryDialogController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@class Repository;
@class RepositoryListController;

@interface NewRepositoryDialogController : NSWindowController {
  NSTimer *slowCloneTimer;
  NSString *labelText;
  Repository *editedRepository;
  RepositoryListController *repositoryListController;
  NSTextField *repositoryUrlField;
  NSProgressIndicator *spinner;
  NSButton *cancelButton;
  NSButton *addButton;
  NSTextField *label;
  BOOL waitingForSlowClone;
}

@property IBOutlet RepositoryListController *repositoryListController;
@property IBOutlet NSTextField *repositoryUrlField;
@property IBOutlet NSProgressIndicator *spinner;
@property IBOutlet NSButton *cancelButton;
@property IBOutlet NSButton *addButton;
@property IBOutlet NSTextField *label;

// public
- (IBAction) showNewRepositorySheet: (id) sender;
- (IBAction) addRepository: (id) sender;
- (IBAction) cancelAddingRepository: (id) sender;

// private
- (void) lockDialog;
- (void) unlockDialog;
- (void) setupSlowCloneTimer;
- (void) showSlowCloneWarning;
- (void) hideSlowCloneWarning;
- (void) hideNewRepositorySheet;
- (void) showAlertWithTitle: (NSString *) title message: (NSString *) message;

@end
