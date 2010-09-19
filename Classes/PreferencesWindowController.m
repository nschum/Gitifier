// -------------------------------------------------------
// PreferencesWindowController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Defaults.h"
#import "PreferencesWindowController.h"
#import "RepositoryListController.h"

@implementation PreferencesWindowController

@synthesize repositoryListController, monitorIntervalField;

- (void) awakeFromNib {
  if (!self.window) {
    [NSBundle loadNibNamed: @"Preferences" owner: self];
    numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
  }
}

- (IBAction) showPreferences: (id) sender {
  [NSApp activateIgnoringOtherApps: YES];
  [self showWindow: self];
}

- (IBAction) removeRepositories: (id) sender {
  [repositoryListController removeSelectedRepositories];
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
