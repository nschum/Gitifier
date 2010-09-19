// -------------------------------------------------------
// NewRepositoryDialogController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class Repository;
@class RepositoryListController;

@interface NewRepositoryDialogController : NSWindowController {
  NSTimer *slowCloneTimer;
  NSString *labelText;
  Repository *editedRepository;
}

@property IBOutlet RepositoryListController *repositoryListController;
@property IBOutlet NSTextField *newRepositoryUrl;
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

@end
