// -------------------------------------------------------
// PreferencesWindowController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "AboutPanelController.h"
#import "GeneralPanelController.h"
#import "NotificationsPanelController.h"
#import "PreferencesWindowController.h"
#import "RepositoriesPanelController.h"

@implementation PreferencesWindowController

- (id) init {
  NSViewController *generalPanel = [[GeneralPanelController alloc] init];
  NSViewController *notificationsPanel = [[NotificationsPanelController alloc] init];
  NSViewController *repositoriesPanel = [[RepositoriesPanelController alloc] init];
  NSViewController *aboutPanel = [[AboutPanelController alloc] init];
  NSArray *controllers = @[generalPanel, notificationsPanel, repositoriesPanel, aboutPanel];

  return [super initWithViewControllers: controllers title: @"Preferences"];
}

- (void) windowDidLoad {
  [super windowDidLoad];
  [[self.window standardWindowButton: NSWindowMiniaturizeButton] setEnabled: YES];
}

@end
