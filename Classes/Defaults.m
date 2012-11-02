// -------------------------------------------------------
// Defaults.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Defaults.h"

NSString *MonitorIntervalKey          = @"monitorInterval";
NSString *RepositoryListKey           = @"repositoryList";
NSString *IgnoreMergesKey             = @"ignoreMerges";
NSString *IgnoreOwnCommitsKey         = @"ignoreOwnCommits";
NSString *GitExecutableKey            = @"gitExecutable";
NSString *StickyNotificationsKey      = @"stickyNotifications";
NSString *ShowDiffWindowKey           = @"showDiffWindow";
NSString *OpenDiffInBrowserKey        = @"openDiffInBrowser";
NSString *KeepWindowsOnTopKey         = @"keepWindowsOnTop";
NSString *AskedAboutProfileInfoKey    = @"askedAboutProfileInfo";
NSString *NotificationLimitEnabledKey = @"notificationLimitEnabled";
NSString *NotificationLimitValueKey   = @"notificationLimitValue";
NSString *RecentCommitsListLengthKey  = @"recentCommitsListLength";

static NSDictionary *defaultPreferenceValues;

@implementation Defaults

+ (void) initialize {
  defaultPreferenceValues = @{
    MonitorIntervalKey: @5,
    IgnoreMergesKey: @YES,
    IgnoreOwnCommitsKey: @YES,
    StickyNotificationsKey: @NO,
    ShowDiffWindowKey: @YES,
    OpenDiffInBrowserKey: @NO,
    KeepWindowsOnTopKey: @YES,
    NotificationLimitEnabledKey: @YES,
    NotificationLimitValueKey: @15,
    RecentCommitsListLengthKey: @5
  };
}

+ (void) registerDefaults {
  [GitifierDefaults registerDefaults: defaultPreferenceValues];
}

@end
