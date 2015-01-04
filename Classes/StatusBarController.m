// -------------------------------------------------------
// StatusBarController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Commit.h"
#import "CommitWindowController.h"
#import "Defaults.h"
#import "StatusBarController.h"
#import "NSImage+GitifierTint.h"

static NSUInteger RecentCommitsTitleLimit = 50;

@implementation StatusBarController {
  NSStatusItem *statusBarItem;
  NSArray *recentCommits;
  NSImage *icon;
}

- (id) init {
  self = [super init];
  if (self) {
    recentCommits = @[];
    [self createIcon];
  }
  return self;
}

- (void) createIcon {
  icon = [NSImage imageNamed: @"icon_menu"];
  icon.template = YES;
}

- (void) createStatusBarItem {
  statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSSquareStatusItemLength];

  if (!statusBarItem) {
    NSRunAlertPanel(@"Error", @"Gitifier menu could not be created :(", @"That's a shame", nil, nil);
    [NSApp terminate: self];
  }

  [statusBarItem setImage: icon];
  [statusBarItem setHighlightMode: YES];
  [statusBarItem setMenu: self.statusBarMenu];
}

- (void)setShowError:(BOOL)showError {
  _showError = showError;
  statusBarItem.image = _showError ? [icon gitifier_imageWithOverlayColor:[NSColor redColor]] : icon;
}

- (void) updateRecentCommitsList: (NSArray *) newCommits {
  NSUInteger limit = [GitifierDefaults integerForKey: RecentCommitsListLengthKey];

  recentCommits = [newCommits arrayByAddingObjectsFromArray: recentCommits];
  recentCommits = [recentCommits subarrayWithRange: NSMakeRange(0, MIN(recentCommits.count, limit))];

  [self updateRecentCommitsSection];
}

- (void) updateRecentCommitsSection {
  NSMenu *menu = statusBarItem.menu;

  while ([[menu itemAtIndex: 0] representedObject]) {
    [menu removeItemAtIndex: 0];
  }

  if (![[menu itemAtIndex: 0] isSeparatorItem]) {
    [menu insertItem: [NSMenuItem separatorItem] atIndex: 0];
  }

  for (NSUInteger i = 0; i < recentCommits.count; i++) {
    Commit *commit = recentCommits[i];

    NSString *title = commit.subject;
    if (title.length > RecentCommitsTitleLimit) {
      title = [[title substringToIndex: RecentCommitsTitleLimit - 1] stringByAppendingString: @"…"];
    }

    SEL action = @selector(commitEntryClickedInMenu:);
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: title action: action keyEquivalent: @""];
    [item setRepresentedObject: commit];
    [item setTarget: self];
    [menu insertItem: item atIndex: i];
  }
}

- (void) commitEntryClickedInMenu: (id) sender {
  Commit *commit = [sender representedObject];

  if (commit) {
    [[[CommitWindowController alloc] initWithCommit: commit] show];
  }
}

@end
