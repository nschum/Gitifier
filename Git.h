// -------------------------------------------------------
// Git.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface Git : NSObject {
  NSPipe *output;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) id delegate;

// public
- (id) initWithDirectory: (NSString *) path;
- (void) runCommand: (NSString *) command withArguments: (NSArray *) arguments;

// private
- (void) notifyDelegateWithSelector: (SEL) selector command: (NSString *) command;

@end
