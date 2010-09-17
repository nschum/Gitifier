// -------------------------------------------------------
// Git.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Git.h"

@implementation Git

- (id) initWithDelegate: (id) aDelegate {
  self = [super init];
  if (self) {
    delegate = aDelegate;
  }
  return self;
}

- (void) runCommand: (NSString *) command inPath: (NSString *) path {
  [self runCommand: command withArguments: [NSArray array] inPath: path];
}

- (void) runCommand: (NSString *) command withArguments: (NSArray *) arguments inPath: (NSString *) path {
  if (currentTask) {
    [self cancelCommands];
  }

  NSPipe *output = [NSPipe pipe];
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
    NSData *data = [[[currentTask standardOutput] fileHandleForReading] readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    currentTask = nil;

    if (status == 0) {
      [self notifyDelegateWithSelector: @selector(commandCompleted:output:) command: command output: output];
    } else {
      [self notifyDelegateWithSelector: @selector(commandFailed:output:) command: command output: output];
    }
  }
}

- (void) notifyDelegateWithSelector: (SEL) selector command: (NSString *) command output: (NSString *) output {
  if ([delegate respondsToSelector: selector]) {
    [delegate performSelector: selector withObject: command withObject: output];
  }
}

@end
