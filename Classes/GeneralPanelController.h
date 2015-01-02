// -------------------------------------------------------
// GeneralPanelController.h
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "MASPreferencesViewController.h"

@interface GeneralPanelController : NSViewController <MASPreferencesViewController, NSOpenSavePanelDelegate>

@property /*(weak)*/ IBOutlet NSTextField *monitorIntervalField;
@property /*(weak)*/ IBOutlet NSButton *chooseGitPathButton;
@property (nonatomic, strong, readonly) id gitClass;

- (IBAction) openGitExecutableDialog: (id) sender;

@end
