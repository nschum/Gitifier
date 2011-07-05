// -------------------------------------------------------
// PreferencesWindowController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "AboutPanelController.h"
#import "GeneralPanelController.h"
#import "PreferencesWindowController.h"
#import "RepositoriesPanelController.h"

@implementation PreferencesWindowController

- (id) init {
  NSViewController *generalPanelController = [[GeneralPanelController alloc] init];
  NSViewController *repositoriesPanelController = [[RepositoriesPanelController alloc] init];
  NSViewController *aboutPanelController = [[AboutPanelController alloc] init];
  NSArray *controllers = PSArray(generalPanelController, repositoriesPanelController, aboutPanelController);

  return [super initWithViewControllers: controllers title: @"Preferences"];
}

@end
