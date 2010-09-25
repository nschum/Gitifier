// -------------------------------------------------------
// PreferencesWindowController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"

@class RepositoryListController;

@interface PreferencesWindowController : DBPrefsWindowController <NSOpenSavePanelDelegate> {
  NSNumberFormatter *numberFormatter;
  RepositoryListController *repositoryListController;
  NSTextField *monitorIntervalField;
  NSButton *ignoreOwnEmailsField;
  NSButton *chooseGitPathButton;
  NSView *generalPreferencesView;
  NSView *repositoriesPreferencesView;
  NSView *aboutPreferencesView;
  NSButton *websiteLabel;
}

@property IBOutlet RepositoryListController *repositoryListController;
@property IBOutlet NSTextField *monitorIntervalField;
@property IBOutlet NSButton *ignoreOwnEmailsField;
@property IBOutlet NSButton *chooseGitPathButton;
@property IBOutlet NSView *generalPreferencesView;
@property IBOutlet NSView *repositoriesPreferencesView;
@property IBOutlet NSView *aboutPreferencesView;
@property IBOutlet NSButton *websiteLabel;
@property (readonly) id gitClass;

// public
- (IBAction) removeRepositories: (id) sender;
- (IBAction) openGitExecutableDialog: (id) sender;
- (IBAction) openProjectWebsite: (id) sender;

// private
- (void) linkifyButton: (NSButton *) label;
- (void) updateUserEmailText: (NSString *) email;

@end
