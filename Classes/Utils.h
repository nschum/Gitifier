// -------------------------------------------------------
// Utils.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

#define UserEmailChangedNotification @"UserEmailChangedNotification"

@interface NSString (Gitifier)
- (NSString *) MD5Hash;
@end
