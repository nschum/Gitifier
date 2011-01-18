// -------------------------------------------------------
// ImportRepositoryDialogController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "UAGithubEngine.h"

@class Repository;
@class RepositoryListController;

@interface ImportRepositoryDialogController : NSWindowController {
  NSTextField *usernameField;
  NSSecureTextField *passwordField;
  NSButton *importBUtton;
  NSButton *cancelButton;
  UAGithubEngine *githubEngine;
  Repository *editedRepository;
  RepositoryListController *repositoryListController;
  NSProgressIndicator *spinner;
}

@property IBOutlet RepositoryListController *repositoryListController;
@property IBOutlet NSTextField *usernameField;
@property IBOutlet NSSecureTextField *passwordField;
@property IBOutlet NSButton *importButton;
@property IBOutlet NSButton *cancelButton;
@property IBOutlet NSProgressIndicator *spinner;

// public
- (IBAction) showImportRepositorySheet: (id) sender;
- (IBAction) importRepositories: (id) sender;
- (IBAction) cancelImportingRepositories: (id) sender;

// private
- (void) hideImportRepositoriesSheet;
- (void) showAlertWithTitle: (NSString *) title message: (NSString *) message;
- (void) lockDialog;
- (void) unlockDialog;
@end
