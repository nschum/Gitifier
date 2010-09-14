// -------------------------------------------------------
// Repository.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface Repository : NSObject {}

@property (nonatomic, copy) NSString *url;

// public
- (id) initWithUrl: (NSString *) anUrl;

// private
- (BOOL) isProperUrl: (NSString *) url;

@end
