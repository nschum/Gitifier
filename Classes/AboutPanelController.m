// -------------------------------------------------------
// AboutPanelController.m
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "AboutPanelController.h"

@implementation AboutPanelController

@synthesize websiteLabel;

- (id) init {
  return [super initWithNibName: @"AboutPreferencesPanel" bundle: nil];
}

- (NSString *) toolbarItemIdentifier {
  return @"About";
}

- (NSImage *) toolbarItemImage {
  return [NSImage imageNamed: @"icon_app_32.png"];
}

- (NSString *) toolbarItemLabel {
  return @"About";
}

- (NSString *) versionString {
  return PSFormat(@"Gitifier %@", [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"]);
}

- (void) openPage: (NSString *) url {
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: url]];
}

- (IBAction) openProjectWebsite: (id) sender {
  [self openPage: [sender title]];
}

- (IBAction) openGitHubPage: (id) sender {
  [self openPage: @"http://github.com/psionides/gitifier"];
}

- (IBAction) openIssueTrackerPage: (id) sender {
  [self openPage: @"http://github.com/psionides/gitifier/issues"];
}

- (IBAction) openTipsAndTricksPage: (id) sender {
  [self openPage: @"https://github.com/psionides/gitifier/wiki/Tips-%26-tricks"];
}

@end
