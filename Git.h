// -------------------------------------------------------
// Git.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface Git : NSObject {
  NSTask *currentTask;
  NSPipe *output;
  BOOL cancelled;
}

@property (copy) NSString *path;
@property id delegate;

// public
- (id) initWithDirectory: (NSString *) path;
- (void) runCommand: (NSString *) command withArguments: (NSArray *) arguments;
- (void) cancelCommands;

// private
- (void) notifyDelegateWithSelector: (SEL) selector command: (NSString *) command;

@end
