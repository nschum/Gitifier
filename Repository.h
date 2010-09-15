// -------------------------------------------------------
// Repository.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface Repository : NSObject {}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) id delegate;

// public
- (id) initWithUrl: (NSString *) anUrl;
- (void) clone;

// private
- (BOOL) isProperUrl: (NSString *) url;
- (NSString *) prepareCloneDirectory;
- (void) notifyDelegateWithSelector: (SEL) selector;

@end
