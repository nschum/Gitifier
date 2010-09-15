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
  if (currentTask) {
    [self cancelCommands];
  }

  currentTask = [[NSTask alloc] init];
  currentTask.arguments = [[NSArray arrayWithObject: command] arrayByAddingObjectsFromArray: arguments];
  currentTask.currentDirectoryPath = path;
  currentTask.launchPath = @"/usr/local/git/bin/git"; // TODO find git automatically
  currentTask.standardOutput = output;
  currentTask.standardError = output;
  cancelled = NO;

  // this should work in the same thread without waitUntilExit, but it doesn't. oh well.
  [NSThread detachNewThreadSelector: @selector(executeTask) toTarget: self withObject: nil];
}

- (void) cancelCommands {
  cancelled = YES;
  [currentTask terminate];
}

- (void) executeTask {
  [currentTask launch];
  [currentTask waitUntilExit];

  if (cancelled) {
    currentTask = nil;
  } else {
    NSInteger status = [currentTask terminationStatus];
    NSString *command = [[currentTask arguments] objectAtIndex: 0];
    currentTask = nil;

    if (status == 0) {
      [self notifyDelegateWithSelector: @selector(commandCompleted:) command: command];
    } else {
      [self notifyDelegateWithSelector: @selector(commandFailed:) command: command];
    }
  }
}

- (void) notifyDelegateWithSelector: (SEL) selector command: (NSString *) command {
  if ([delegate respondsToSelector: selector]) {
    [delegate performSelector: selector withObject: command];
  }
}

@end
