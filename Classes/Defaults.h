// -------------------------------------------------------
// Defaults.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#define GitifierDefaults [NSUserDefaults standardUserDefaults]

#define MONITOR_INTERVAL_KEY @"monitorInterval"
#define REPOSITORY_LIST_KEY @"repositoryList"

extern NSDictionary *defaultPreferenceValues;

@interface Defaults {}

+ (void) registerDefaults;

@end
