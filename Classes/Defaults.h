// -------------------------------------------------------
// Defaults.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#define GitifierDefaults [NSUserDefaults standardUserDefaults]

extern NSString *MonitorIntervalKey;
extern NSString *RepositoryListKey;
extern NSString *IgnoreMergesKey;
extern NSString *IgnoreOwnCommitsKey;
extern NSString *GitExecutableKey;
extern NSString *StickyNotificationsKey;
extern NSString *ShowDiffWindowKey;
extern NSString *OpenDiffInBrowserKey;
extern NSString *KeepWindowsOnTopKey;
extern NSString *AskedAboutProfileInfoKey;

@interface Defaults

+ (void) registerDefaults;

@end
