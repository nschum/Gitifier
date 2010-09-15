// -------------------------------------------------------
// Git.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Git.h"

@implementation Git

@synthesize path, delegate;

- (id) initWithDirectory: (NSString *) aPath {
  self = [super init];
  if (self) {
    path = aPath;
    output = [NSPipe pipe];
  }
  return self;
}

- (void) runCommand: (NSString *) command withArguments: (NSArray *) arguments {
  NSTask *task = [[NSTask alloc] init];
  task.arguments = [[NSArray arrayWithObject: command] arrayByAddingObjectsFromArray: arguments];
  task.currentDirectoryPath = path;
  task.launchPath = @"/usr/local/git/bin/git"; // TODO find git automatically
  task.standardOutput = output;
  task.standardError = output;

  // this should work in the same thread without waitUntilExit, but it doesn't. oh well.
  [NSThread detachNewThreadSelector: @selector(executeTask:) toTarget: self withObject: task];
}

- (void) executeTask: (NSTask *) task {
  [task launch];
  [task waitUntilExit];

  NSInteger status = [task terminationStatus];
  NSString *command = [[task arguments] objectAtIndex: 0];

  if (status == 0) {
    [self notifyDelegateWithSelector: @selector(commandCompleted:) command: command];
  } else {
    [self notifyDelegateWithSelector: @selector(commandFailed:) command: command];
  }
}

- (void) notifyDelegateWithSelector: (SEL) selector command: (NSString *) command {
  if ([delegate respondsToSelector: selector]) {
    [delegate performSelector: selector withObject: command];
  }
}

@end
