// -------------------------------------------------------
// PreferencesWindowController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "PreferencesWindowController.h"
#import "RepositoryListController.h"

@implementation PreferencesWindowController

@synthesize repositoryListController;

- (void) awakeFromNib {
  if (!self.window) {
    [NSBundle loadNibNamed: @"Preferences" owner: self];
  }
}

- (IBAction) showPreferences: (id) sender {
  // TODO: fix cmd+w
  [NSApp activateIgnoringOtherApps: YES];
  [self showWindow: self];
}

- (IBAction) removeRepositories: (id) sender {
  [repositoryListController removeSelectedRepositories];
}

@end
