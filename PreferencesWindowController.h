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
}

@property IBOutlet RepositoryListController *repositoryListController;
@property IBOutlet NSTextField *monitorIntervalField;

- (IBAction) showPreferences: (id) sender;
- (IBAction) removeRepositories: (id) sender;

@end
