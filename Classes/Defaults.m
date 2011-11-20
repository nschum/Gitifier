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

static NSDictionary *defaultPreferenceValues;

@implementation Defaults

+ (void) initialize {
  defaultPreferenceValues = PSHash(
    MonitorIntervalKey,          PSInt(5),
    IgnoreMergesKey,             PSBool(YES),
    IgnoreOwnCommitsKey,         PSBool(YES),
    StickyNotificationsKey,      PSBool(NO),
    ShowDiffWindowKey,           PSBool(YES),
    OpenDiffInBrowserKey,        PSBool(NO),
    KeepWindowsOnTopKey,         PSBool(YES),
    NotificationLimitEnabledKey, PSBool(YES),
    NotificationLimitValueKey,   PSInt(15)
  );
}

+ (void) registerDefaults {
  [GitifierDefaults registerDefaults: defaultPreferenceValues];
}

@end
