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
  defaultPreferenceValues = PSDict(
    PSInt(5),    MONITOR_INTERVAL_KEY,
    PSBool(YES), IGNORE_MERGES_KEY,
    PSBool(YES), IGNORE_OWN_COMMITS,
    PSBool(NO),  STICKY_NOTIFICATIONS_KEY,
    PSBool(YES), SHOW_DIFF_WINDOW_KEY,
    PSBool(NO),  OPEN_DIFF_IN_BROWSER_KEY,
    PSBool(YES), KEEP_WINDOWS_ON_TOP_KEY
  );
}

+ (void) registerDefaults {
  [GitifierDefaults registerDefaults: defaultPreferenceValues];
}

@end
