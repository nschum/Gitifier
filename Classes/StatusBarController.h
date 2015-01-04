// -------------------------------------------------------
// StatusBarController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@interface StatusBarController : NSObject

@property (nonatomic, assign) BOOL showError;
@property (weak) IBOutlet NSMenu *statusBarMenu;

- (void) createStatusBarItem;
- (void) updateRecentCommitsList: (NSArray *) newCommits;

@end
