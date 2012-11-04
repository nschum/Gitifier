// -------------------------------------------------------
// Utils.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#define ObserveDefaults(setting) [[NSUserDefaultsController sharedUserDefaultsController] \
  addObserver: self forKeyPath: PSFormat(@"values.%@", setting) options: 0 context: nil]

extern NSString *UserEmailChangedNotification;
extern NSString *GitExecutableSetNotification;

@interface NSString (Gitifier)
- (BOOL) isMatchedByRegex: (NSRegularExpression *) regex;
- (NSArray *) arrayOfCaptureComponentsMatchedByRegex: (NSRegularExpression *) regex;
- (NSArray *) componentsMatchedByRegex: (NSRegularExpression *) regex;
- (NSString *) lastKeyPathElement;
- (NSString *) MD5Hash;
@end

@interface NSWindow (Gitifier)
@property BOOL keepOnTop;
@end
