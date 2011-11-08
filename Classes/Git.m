// -------------------------------------------------------
// Git.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "RegexKitLite.h"
#import "Git.h"
#import "GitifierAppDelegate.h"
#import "PasswordHelper.h"

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
  PSNotifyWithData(GitExecutableSetNotification, PSHash(@"path", path ? path : PSNull));
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
    [self notifyDelegateWithSelector: @selector(commandFailed:output:)
                             command: command
                              output: @"No Git executable found."];
    return;
  }

  currentData = [[NSMutableData alloc] init];

  PSLog(@"running command git %@ %@", command, arguments);

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
    NSMutableDictionary *environment = [[[NSProcessInfo processInfo] environment] mutableCopy];

    NSDictionary *customEnvironment = [[NSUserDefaults standardUserDefaults] objectForKey: @"gitEnvironment"];
    if (customEnvironment) {
      [environment addEntriesFromDictionary: customEnvironment];
    }

    [environment setObject: @"Gitifier"   forKey: @"DISPLAY"];
    [environment setObject: askPassPath   forKey: @"SSH_ASKPASS"];
    [environment setObject: repositoryUrl forKey: @"AUTH_HOSTNAME"];
    [environment setObject: @"Gitifier"   forKey: @"AUTH_USERNAME"];
    [environment setObject: PSInt(pid)    forKey: @"GITIFIER_PID"];

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
    NSFileHandle *readHandle = [[currentTask standardOutput] fileHandleForReading];

    PSObserve(readHandle, NSFileHandleReadCompletionNotification, receivedData:);
    [readHandle readInBackgroundAndNotify];
    [currentTask launch];
    [currentTask waitUntilExit];
    PSStopObserving(readHandle, NSFileHandleReadCompletionNotification);

    if (cancelled) {
      currentTask = nil;
      currentData = nil;
    } else {
      [currentData appendData: [readHandle readDataToEndOfFile]];
      [readHandle closeFile];

      NSInteger status = [currentTask terminationStatus];
      NSString *command = [[currentTask arguments] psFirstObject];
      NSString *output = [[NSString alloc] initWithData: currentData encoding: NSUTF8StringEncoding];
      currentTask = nil;
      currentData = nil;

      if (status == 0) {
        PSLog(@"command git %@ completed with output: %@", command, output);
        [self notifyDelegateWithSelector: @selector(commandCompleted:output:) command: command output: output];
      } else {
        if ([output isMatchedByRegex: @"Authentication failed"]) {
          [PasswordHelper removePasswordForHost: repositoryUrl user: @"Gitifier"];
        }
        PSLog(@"command git %@ failed with output: %@", command, output);
        [self notifyDelegateWithSelector: @selector(commandFailed:output:) command: command output: output];
      }
    }
  } @catch (NSException *e) {
    NSString *command = [[currentTask arguments] psFirstObject];
    currentTask = nil;
    currentData = nil;
    PSLog(@"command git %@ failed with exception: %@", command, e);
    [self notifyDelegateWithSelector: @selector(commandFailed:output:) command: command output: [e description]];
    return;
  }
}

- (void) receivedData: (NSNotification *) notification {
  NSData *data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
  NSFileHandle *readHandle = [notification object];
  [currentData appendData: data];
  [readHandle readInBackgroundAndNotify];
}

- (void) notifyDelegateWithSelector: (SEL) selector command: (NSString *) command output: (NSString *) output {
  if ([delegate respondsToSelector: selector]) {
    [delegate performSelector: selector withObject: command withObject: output];
  }
}

@end
