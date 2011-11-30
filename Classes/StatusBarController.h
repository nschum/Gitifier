// -------------------------------------------------------
// StatusBarController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@interface StatusBarController : NSObject {
  NSStatusItem *statusBarItem;
  NSMenu *statusBarMenu;
  NSArray *recentCommits;
}

@property (assign) IBOutlet NSMenu *statusBarMenu;

// public
- (void) createStatusBarItem;
- (void) updateRecentCommitsList: (NSArray *) newCommits;

// private
- (void) updateRecentCommitsSection;

@end
