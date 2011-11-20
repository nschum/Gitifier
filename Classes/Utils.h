// -------------------------------------------------------
// Utils.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

#define ObserveDefaults(setting) [[NSUserDefaultsController sharedUserDefaultsController] \
  addObserver: self forKeyPath: PSFormat(@"values.%@", setting) options: 0 context: nil]

extern NSString *UserEmailChangedNotification;
extern NSString *GitExecutableSetNotification;

@interface NSString (Gitifier)
- (NSString *) MD5Hash;
- (NSString *) lastKeyPathElement;
@end

@interface NSWindow (Gitifier)
@property BOOL keepOnTop;
@end
