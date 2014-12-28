// -------------------------------------------------------
// AboutPanelController.m
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "AboutPanelController.h"

static NSString *ProjectPageURL = @"http://github.com/psionides/gitifier";
static NSString *IssueTrackerURL = @"http://github.com/psionides/gitifier/issues";
static NSString *TipsAndTricksPageURL = @"https://github.com/psionides/gitifier/wiki/Tips-%26-tricks";

@implementation AboutPanelController

- (id) init {
  return [super initWithNibName: @"AboutPreferencesPanel" bundle: nil];
}

- (void) awakeFromNib {
  NSURL *file = [[NSBundle mainBundle] URLForResource: @"Credits" withExtension: @"html"];
  NSString *html = [NSString stringWithContentsOfURL: file encoding: NSUTF8StringEncoding error: nil];
  [self.creditsList.mainFrame loadHTMLString: html baseURL: nil];
}

- (NSString *) identifier {
  return @"About";
}

- (NSImage *) toolbarItemImage {
  return [NSImage imageNamed: @"about_icon.png"];
}

- (NSString *) toolbarItemLabel {
  return @"About";
}

- (NSString *) versionString {
  return PSFormat(@"Gitifier %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]);
}

- (void) openPage: (NSString *) url {
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: url]];
}

- (IBAction) openProjectWebsite: (id) sender {
  [self openPage: [sender title]];
}

- (IBAction) openGitHubPage: (id) sender {
  [self openPage: ProjectPageURL];
}

- (IBAction) openIssueTrackerPage: (id) sender {
  [self openPage: IssueTrackerURL];
}

- (IBAction) openTipsAndTricksPage: (id) sender {
  [self openPage: TipsAndTricksPageURL];
}

@end
