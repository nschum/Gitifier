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
    PSInt(5), MONITOR_INTERVAL_KEY
  );
}

+ (void) registerDefaults {
  [GitifierDefaults registerDefaults: defaultPreferenceValues];
}

@end
