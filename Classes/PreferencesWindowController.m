// -------------------------------------------------------
// PreferencesWindowController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Defaults.h"
#import "Git.h"
#import "GitifierAppDelegate.h"
#import "PreferencesWindowController.h"
#import "RepositoryListController.h"
#import "Utils.h"

@implementation PreferencesWindowController

@synthesize repositoryListController, monitorIntervalField, ignoreOwnEmailsField, chooseGitPathButton,
  generalPreferencesView, repositoriesPreferencesView, aboutPreferencesView, websiteLabel;

- (id) gitClass {
  return [Git class];
}

- (id) init {
  return [super initWithWindowNibName: @"Preferences"];
}

- (void) awakeFromNib {
  numberFormatter = [[NSNumberFormatter alloc] init];
  numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

  [self linkifyButton: websiteLabel];
  [self updateUserEmailText: [[NSApp delegate] userEmail]];
  PSObserve(nil, UserEmailChangedNotification, userEmailChanged:);

  // 10.6 has significantly different API for this dialog, and I'm too lazy to code both versions
  if (![NSOpenPanel instancesRespondToSelector: @selector(setShowsHiddenFiles:)]) {
    [chooseGitPathButton removeFromSuperview];
  }
}

- (void) linkifyButton: (NSButton *) label {
  NSString *url = label.title;
  NSDictionary *linkAttributes = PSDict(
    [NSColor blueColor], NSForegroundColorAttributeName,
    [NSCursor pointingHandCursor], NSCursorAttributeName
  );
  NSAttributedString *link = [[NSAttributedString alloc] initWithString: url attributes: linkAttributes];
  websiteLabel.attributedTitle = link;
}

- (IBAction) openProjectWebsite: (id) sender {
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: [sender title]]];
}

- (void) setupToolbar {
  [self addView: generalPreferencesView
          label: @"General"
          image: [NSImage imageNamed: @"NSPreferencesGeneral"]];
  [self addView: repositoriesPreferencesView
          label: @"Repositories"
          image: [NSImage imageNamed: @"NSNetwork"]];
  [self addView: aboutPreferencesView
          label: @"About"
          image: [NSImage imageNamed: @"icon_app_32.png"]];
  [self setCrossFade: NO];
}

- (IBAction) removeRepositories: (id) sender {
  [repositoryListController removeSelectedRepositories];
}

- (void) showWindow: (id) sender {
  if (!self.window || !self.window.isVisible) {
    [super showWindow: sender];
  }
}

- (IBAction) openGitExecutableDialog: (id) sender {
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  panel.title = @"Select Git executable";
  panel.directoryURL = [NSURL fileURLWithPath: NSOpenStepRootDirectory()];
  panel.delegate = self;
  panel.canChooseFiles = YES;
  panel.canChooseDirectories = NO;
  panel.resolvesAliases = NO;
  panel.allowsMultipleSelection = NO;
  panel.canCreateDirectories = NO;
  panel.showsHiddenFiles = YES;
  panel.treatsFilePackagesAsDirectories = NO;

  NSInteger result = [panel runModal];

  if (result == NSFileHandlingPanelOKButton) {
    NSURL *url = [[panel URLs] objectAtIndex: 0];
    [Git setGitExecutable: url.path];
  }
}

- (BOOL) panel: (NSOpenPanel *) panel shouldEnableURL: (NSURL *) url {
  BOOL isFileURL = [url isFileURL];

  NSNumber *directoryAttribute;
  BOOL hasDirectoryAttribute = [url getResourceValue: &directoryAttribute forKey: NSURLIsDirectoryKey error: nil];
  BOOL isDirectory = [directoryAttribute boolValue];

  NSNumber *packageAttribute;
  BOOL hasPackageAttribute = [url getResourceValue: &packageAttribute forKey: NSURLIsPackageKey error: nil];
  BOOL isPackage = [packageAttribute boolValue];

  if (!isFileURL || !hasDirectoryAttribute || !hasPackageAttribute || isPackage) {
    return NO;
  } else if (isDirectory) {
    return YES;
  } else {
    return [[url lastPathComponent] isEqual: @"git"];
  }
}

- (void) userEmailChanged: (NSNotification *) notification {
  NSString *email = [notification.userInfo objectForKey: @"email"];
  [self updateUserEmailText: email];
}

- (void) updateUserEmailText: (NSString *) email {
  if (email) {
    ignoreOwnEmailsField.title = PSFormat(@"Ignore my own commits (%@)", email);
  } else {
    ignoreOwnEmailsField.title = @"Ignore my own commits";
  }
}

- (BOOL) control: (NSControl *) field didFailToFormatString: (NSString *) string errorDescription: (NSString *) error {
  if (field == monitorIntervalField) {
    NSNumber *number = [numberFormatter numberFromString: string];
    if (number) {
      NSNumberFormatter *formatter = (NSNumberFormatter *) [field formatter];
      NSInteger value = [number integerValue];
      NSInteger min = [formatter.minimum integerValue];
      NSInteger max = [formatter.maximum integerValue];
      if (value < min) {
        monitorIntervalField.integerValue = min;
      } else if (value > max) {
        monitorIntervalField.integerValue = max;
      } else {
        monitorIntervalField.integerValue = value;
      }
    } else {
      monitorIntervalField.integerValue = [GitifierDefaults integerForKey: MONITOR_INTERVAL_KEY];
    }
    return YES;
  }

  return NO;
}

@end
