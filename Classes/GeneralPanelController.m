// -------------------------------------------------------
// GeneralPanelController.m
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Defaults.h"
#import "GeneralPanelController.h"
#import "Git.h"
#import "GitifierAppDelegate.h"

#define IGNORE_MY_COMMITS_TEXT @"Ignore my own commits"

@implementation GeneralPanelController

@synthesize monitorIntervalField, ignoreOwnEmailsField, chooseGitPathButton;

- (id) init {
  return [super initWithNibName: @"GeneralPreferencesPanel" bundle: nil];
}

- (void) awakeFromNib {
  numberFormatter = [[NSNumberFormatter alloc] init];
  numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

  [self updateUserEmailText: [[NSApp delegate] userEmail]];
  PSObserve(nil, UserEmailChangedNotification, userEmailChanged:);
}

- (id) gitClass {
  return [Git class];
}

- (NSString *) toolbarItemIdentifier {
  return @"General";
}

- (NSImage *) toolbarItemImage {
  return [NSImage imageNamed: NSImageNamePreferencesGeneral];
}

- (NSString *) toolbarItemLabel {
  return @"General";
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
    NSURL *url = [[panel URLs] psFirstObject];
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
    NSString *title = PSFormat(@"%@ (%@)", IGNORE_MY_COMMITS_TEXT, email);
    NSInteger labelLength = IGNORE_MY_COMMITS_TEXT.length;
    NSRange labelRange = NSMakeRange(0, labelLength);
    NSRange emailRange = NSMakeRange(labelLength, title.length - labelLength);
    
    NSFont *standardFont = [NSFont systemFontOfSize: 13.0];
    NSFont *smallerFont = [NSFont systemFontOfSize: 11.0];
    NSColor *gray = [NSColor colorWithCalibratedWhite: 0.5 alpha: 1.0];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString: title];
    [text addAttribute: NSFontAttributeName value: standardFont range: labelRange];
    [text addAttribute: NSFontAttributeName value: smallerFont range: emailRange];
    [text addAttribute: NSForegroundColorAttributeName value: gray range: emailRange];
    ignoreOwnEmailsField.attributedTitle = text;
  } else {
    ignoreOwnEmailsField.title = IGNORE_MY_COMMITS_TEXT;
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
