// -------------------------------------------------------
// NewRepositoryDialogController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@class Repository;
@class RepositoryListController;

@interface NewRepositoryDialogController : NSWindowController

@property IBOutlet RepositoryListController *repositoryListController;
@property IBOutlet NSTextField *repositoryUrlField;
@property IBOutlet NSProgressIndicator *spinner;
@property IBOutlet NSButton *cancelButton;
@property IBOutlet NSButton *addButton;
@property IBOutlet NSTextField *label;

- (IBAction) showNewRepositorySheet: (id) sender;
- (IBAction) addRepository: (id) sender;
- (IBAction) cancelAddingRepository: (id) sender;

@end
