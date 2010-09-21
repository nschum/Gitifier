// -------------------------------------------------------
// PreferencesWindowController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class RepositoryListController;

@interface PreferencesWindowController : NSWindowController <NSOpenSavePanelDelegate> {
  NSNumberFormatter *numberFormatter;
  RepositoryListController *repositoryListController;
  NSTextField *monitorIntervalField;
  NSButton *ignoreOwnEmailsField;
  NSButton *chooseGitPathButton;
}

@property IBOutlet RepositoryListController *repositoryListController;
@property IBOutlet NSTextField *monitorIntervalField;
@property IBOutlet NSButton *ignoreOwnEmailsField;
@property IBOutlet NSButton *chooseGitPathButton;
@property (readonly) id gitClass;

- (IBAction) showPreferences: (id) sender;
- (IBAction) removeRepositories: (id) sender;
- (IBAction) openGitExecutableDialog: (id) sender;
- (void) updateUserEmailText: (NSString *) email;

@end
