// -------------------------------------------------------
// Defaults.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#define GitifierDefaults [NSUserDefaults standardUserDefaults]

#define MONITOR_INTERVAL_KEY @"monitorInterval"
#define REPOSITORY_LIST_KEY @"repositoryList"
#define IGNORE_MERGES_KEY @"ignoreMerges"
#define IGNORE_OWN_COMMITS @"ignoreOwnCommits"
#define GIT_EXECUTABLE_KEY @"gitExecutable"

extern NSDictionary *defaultPreferenceValues;

@interface Defaults {}

+ (void) registerDefaults;

@end
