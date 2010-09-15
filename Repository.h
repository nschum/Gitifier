// -------------------------------------------------------
// Repository.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class Git;

@interface Repository : NSObject {
  Git *git;
}

@property (copy) NSString *url;
@property id delegate;

// public
- (id) initWithUrl: (NSString *) anUrl;
- (void) clone;
- (void) cancelCommands;

// private
- (Git *) git;
- (BOOL) isProperUrl: (NSString *) url;
- (NSString *) prepareCloneDirectory;
- (void) notifyDelegateWithSelector: (SEL) selector;

@end
