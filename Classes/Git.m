// -------------------------------------------------------
// Git.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Git.h"
#import "Utils.h"

static NSString *gitExecutable = nil;

@implementation Git

@synthesize repositoryUrl;

+ (NSString *) gitExecutable {
  return gitExecutable;
}

+ (void) setGitExecutable: (NSString *) path {
  [self willChangeValueForKey: @"gitExecutable"];
  path = [path psTrimmedString];
  gitExecutable = [path isEqual: @""] ? nil : path;
  [self didChangeValueForKey: @"gitExecutable"];
  PSNotifyWithData(GitExecutableSetNotification, PSDict(path, @"path"));
}

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

  if (!gitExecutable) {
    NSLog(@"Error: no git executable found.");
    // TODO: set warning icon
    return;
  }

  NSPipe *output = [NSPipe pipe];
  currentTask = [[NSTask alloc] init];
  currentTask.arguments = [[NSArray arrayWithObject: command] arrayByAddingObjectsFromArray: arguments];
  currentTask.currentDirectoryPath = path;
  currentTask.launchPath = gitExecutable;
  currentTask.standardInput = [NSFileHandle fileHandleWithNullDevice];
  currentTask.standardOutput = output;
  currentTask.standardError = output;

  if (repositoryUrl) {
    NSString *askPassPath = [[NSBundle mainBundle] pathForResource: @"AskPass" ofType: @""];
    NSInteger pid = [[NSProcessInfo processInfo] processIdentifier];
    NSDictionary *environment = [[[NSProcessInfo processInfo] environment] mutableCopy];
    [environment setValue: @"Gitifier" forKey: @"DISPLAY"];
    [environment setValue: askPassPath forKey: @"SSH_ASKPASS"];
    [environment setValue: repositoryUrl forKey: @"AUTH_HOSTNAME"];
    [environment setValue: @"Gitifier" forKey: @"AUTH_USERNAME"];
    [environment setValue: PSInt(pid) forKey: @"GITIFIER_PID"];
    currentTask.environment = environment;
  }

  cancelled = NO;

  // this should work in the same thread without waitUntilExit, but it doesn't. oh well.
  [NSThread detachNewThreadSelector: @selector(executeTask) toTarget: self withObject: nil];
}

- (void) cancelCommands {
  cancelled = YES;
  [currentTask terminate];
}

- (void) executeTask {
  @try {
    [currentTask launch];
    [currentTask waitUntilExit];
  } @catch (NSException *e) {
    NSString *command = [[currentTask arguments] objectAtIndex: 0];
    currentTask = nil;
    [self notifyDelegateWithSelector: @selector(commandFailed:output:) command: command output: [e description]];
    return;
  }

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
