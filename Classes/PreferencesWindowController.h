// -------------------------------------------------------
// PreferencesWindowController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class RepositoryListController;

@interface PreferencesWindowController : NSWindowController {
  NSNumberFormatter *numberFormatter;
  RepositoryListController *repositoryListController;
  NSTextField *monitorIntervalField;
  NSButton *ignoreOwnEmailsField;
}

@property IBOutlet RepositoryListController *repositoryListController;
@property IBOutlet NSTextField *monitorIntervalField;
@property IBOutlet NSButton *ignoreOwnEmailsField;

- (IBAction) showPreferences: (id) sender;
- (IBAction) removeRepositories: (id) sender;
- (void) updateUserEmailText: (NSString *) email;

@end
