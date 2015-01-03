// -------------------------------------------------------
// NewRepositoryDialogController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@class Repository;
@class RepositoryListController;

@interface NewRepositoryDialogController : NSWindowController

@property (weak) IBOutlet RepositoryListController *repositoryListController;
@property (weak) IBOutlet NSTextField *repositoryUrlField;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSTextField *label;

- (IBAction) showNewRepositorySheet: (id) sender;
- (IBAction) addRepository: (id) sender;
- (IBAction) cancelAddingRepository: (id) sender;

@end
