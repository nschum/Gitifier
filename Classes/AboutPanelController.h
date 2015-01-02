// -------------------------------------------------------
// AboutPanelController.h
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Webkit/WebKit.h>
#import "MASPreferencesViewController.h"

@interface AboutPanelController : NSViewController <MASPreferencesViewController>

@property /*(weak)*/ IBOutlet NSButton *websiteLabel;
@property /*(weak)*/ IBOutlet WebView *creditsList;
@property (nonatomic, copy, readonly) NSString *versionString;

- (IBAction) openProjectWebsite: (id) sender;
- (IBAction) openGitHubPage: (id) sender;
- (IBAction) openIssueTrackerPage: (id) sender;
- (IBAction) openTipsAndTricksPage: (id) sender;

@end
