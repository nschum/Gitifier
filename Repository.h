// -------------------------------------------------------
// Repository.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface Repository : NSObject {}

@property (copy) NSString *url;
@property id delegate;

// public
- (id) initWithUrl: (NSString *) anUrl;
- (void) clone;

// private
- (BOOL) isProperUrl: (NSString *) url;
- (NSString *) prepareCloneDirectory;
- (void) notifyDelegateWithSelector: (SEL) selector;

@end
