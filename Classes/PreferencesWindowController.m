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

@interface MASPreferencesWindowController (Private)
- (NSArray *) toolbarItemIdentifiers;
- (void) toolbarItemDidClick: (id) sender;
- (void) updateViewControllerWithAnimation: (BOOL) animate;
@end

@implementation PreferencesWindowController

- (id) init {
  NSViewController *generalPanel = [[GeneralPanelController alloc] init];
  NSViewController *notificationsPanel = [[NotificationsPanelController alloc] init];
  NSViewController *repositoriesPanel = [[RepositoriesPanelController alloc] init];
  NSViewController *aboutPanel = [[AboutPanelController alloc] init];
  NSArray *controllers = PSArray(generalPanel, notificationsPanel, repositoriesPanel, aboutPanel);

  return [super initWithViewControllers: controllers title: @"Preferences"];
}

- (void) windowDidLoad {
  [[self.window standardWindowButton: NSWindowZoomButton] setEnabled: NO];
}

- (void) setContentView: (NSView *) view {
  [super setContentView: view];
  self.window.showsResizeIndicator = [self.window.toolbar.selectedItemIdentifier isEqual: @"Repositories"];
}

- (void) showWindow: (id) sender {
  [self toolbarItemDidClick: sender];
  [super showWindow: sender];
}

- (void) updateViewControllerWithAnimation: (BOOL) animate {
  NSArray *identifiers = [self toolbarItemIdentifiers];
  NSString *itemIdentifier = self.window.toolbar.selectedItemIdentifier;
  NSUInteger controllerIndex = [identifiers indexOfObject: itemIdentifier];

  if (controllerIndex != NSNotFound) {
    NSViewController *controller = [self.viewControllers objectAtIndex: controllerIndex];
    if ([controller isKindOfClass: [NotificationsPanelController class]]) {
      NotificationsPanelController *npc = (NotificationsPanelController *) controller;
      [npc view];
      [npc updateGrowlInfoPanel];
    }

    [super updateViewControllerWithAnimation: animate];
  }
}

@end
