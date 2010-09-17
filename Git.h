// -------------------------------------------------------
// Git.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface Git : NSObject {
  NSTask *currentTask;
  BOOL cancelled;
  id delegate;
}

// public
- (id) initWithDelegate: (id) aDelegate;
- (void) runCommand: (NSString *) command inPath: (NSString *) path;
- (void) runCommand: (NSString *) command withArguments: (NSArray *) arguments inPath: (NSString *) path;
- (void) cancelCommands;

// private
- (void) notifyDelegateWithSelector: (SEL) selector command: (NSString *) command output: (NSString *) output;

@end
