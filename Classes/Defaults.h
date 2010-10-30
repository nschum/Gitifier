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
#define STICKY_NOTIFICATIONS_KEY @"stickyNotifications"
#define SHOW_DIFF_WINDOW_KEY @"showDiffWindow"
#define OPEN_DIFF_IN_BROWSER_KEY @"openDiffInBrowser"
#define KEEP_WINDOWS_ON_TOP_KEY @"keepWindowsOnTop"

extern NSDictionary *defaultPreferenceValues;

@interface Defaults {}

+ (void) registerDefaults;

@end
