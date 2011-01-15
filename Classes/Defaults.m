// -------------------------------------------------------
// Defaults.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Defaults.h"

NSDictionary *defaultPreferenceValues;

@implementation Defaults

+ (void) initialize {
  defaultPreferenceValues = PSHash(
    MONITOR_INTERVAL_KEY,      PSInt(5),
    IGNORE_MERGES_KEY,         PSBool(YES),
    IGNORE_OWN_COMMITS,        PSBool(YES),
    STICKY_NOTIFICATIONS_KEY,  PSBool(NO),
    SHOW_DIFF_WINDOW_KEY,      PSBool(YES),
    OPEN_DIFF_IN_BROWSER_KEY,  PSBool(NO),
    KEEP_WINDOWS_ON_TOP_KEY,   PSBool(YES)
  );
}

+ (void) registerDefaults {
  [GitifierDefaults registerDefaults: defaultPreferenceValues];
}

@end
