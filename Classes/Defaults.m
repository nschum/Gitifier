// -------------------------------------------------------
// Defaults.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Defaults.h"

NSDictionary *defaultPreferenceValues;

@implementation Defaults

+ (void) initialize {
  NSNumber *yes = [NSNumber numberWithBool: YES];
  NSNumber *no = [NSNumber numberWithBool: NO];
  defaultPreferenceValues = PSDict(
    PSInt(5), MONITOR_INTERVAL_KEY,
    yes, IGNORE_MERGES_KEY,
    yes, IGNORE_OWN_COMMITS,
    no, STICKY_NOTIFICATIONS_KEY,
    yes, SHOW_DIFF_WINDOW_KEY,
    no, OPEN_DIFF_IN_BROWSER_KEY,
    yes, KEEP_WINDOWS_ON_TOP_KEY
  );
}

+ (void) registerDefaults {
  [GitifierDefaults registerDefaults: defaultPreferenceValues];
}

@end
