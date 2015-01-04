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
  NSMenuItem *errorMenuItem;
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

#pragma mark - errors

- (void) setErrors:(NSDictionary *)errors {
  _errors = [errors copy];
  if (_errors.count > 0) {
    statusBarItem.image = [icon gitifier_imageWithOverlayColor:[NSColor redColor]];
    [self updateErrorsSection];
  } else {
    statusBarItem.image = icon;
    [self removeErrorsSection];
  }
}

- (void) updateErrorsSection {
  NSMenu *menu = self.statusBarMenu;
  if (menu.itemArray[0] != errorMenuItem) {
    errorMenuItem = [NSMenuItem new];
    errorMenuItem.title = @"Errors";
    [menu insertItem:errorMenuItem atIndex:0];
    [menu insertItem: [NSMenuItem separatorItem] atIndex: 1];
  }
  NSMenu *errorMenu = [NSMenu new];
  for (NSString *repository in _errors) {
    NSError *error = _errors[repository];
    NSMenuItem *menuItem = [NSMenuItem new];
    menuItem.title = repository;
    menuItem.representedObject = error;
    menuItem.toolTip = [self toolTipForError:error];
    menuItem.target = self;
    menuItem.action = @selector(showError:);
    [errorMenu addItem:menuItem];
  }
  errorMenuItem.submenu = errorMenu;
}

- (NSString *)toolTipForError: (NSError *)error {
  NSString *url = error.userInfo[NSFilePathErrorKey];
  NSObject *description = error.userInfo[NSLocalizedDescriptionKey];
  NSString *reason = error.userInfo[NSLocalizedFailureReasonErrorKey];
  return [NSString stringWithFormat:@"%@\n\n%@\n\n%@", url, description, reason];
}

- (void) removeErrorsSection {
  NSMenu *menu = self.statusBarMenu;
  if (menu.itemArray[0] == errorMenuItem) {
    [menu removeItemAtIndex:1];
    [menu removeItemAtIndex:0];
  }
}

- (void) showError: (NSMenuItem *)sender {
  NSError *error = sender.representedObject;
  NSAlert *alert = [NSAlert new];
  NSString *url = error.userInfo[NSFilePathErrorKey];
  NSObject *description = error.userInfo[NSLocalizedDescriptionKey];
  alert.messageText = [NSString stringWithFormat:@"%@: %@", url, description];
  alert.informativeText = error.userInfo[NSLocalizedFailureReasonErrorKey];
  [alert runModal];
};

#pragma mark - recent commits

- (void) updateRecentCommitsList: (NSArray *) newCommits {
  NSUInteger limit = [GitifierDefaults integerForKey: RecentCommitsListLengthKey];

  recentCommits = [newCommits arrayByAddingObjectsFromArray: recentCommits];
  recentCommits = [recentCommits subarrayWithRange: NSMakeRange(0, MIN(recentCommits.count, limit))];

  [self updateRecentCommitsSection];
}

- (void) updateRecentCommitsSection {
  NSMenu *menu = statusBarItem.menu;

  NSInteger commitIndex = menu.itemArray[0] == errorMenuItem ? 2 : 0;

  while ([[[menu itemAtIndex:commitIndex] representedObject] isKindOfClass:[Commit class]]) {
    [menu removeItemAtIndex: commitIndex];
  }

  if (![[menu itemAtIndex: commitIndex] isSeparatorItem]) {
    [menu insertItem: [NSMenuItem separatorItem] atIndex: commitIndex];
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
    [menu insertItem: item atIndex: i + commitIndex];
  }
}

- (void) commitEntryClickedInMenu: (id) sender {
  Commit *commit = [sender representedObject];

  if (commit) {
    [[[CommitWindowController alloc] initWithCommit: commit] show];
  }
}

@end
