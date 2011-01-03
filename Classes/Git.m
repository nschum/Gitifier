// -------------------------------------------------------
// Git.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "RegexKitLite.h"
#import "Git.h"
#import "GitifierAppDelegate.h"
#import "PasswordHelper.h"
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
  PSNotifyWithData(GitExecutableSetNotification, PSHash(@"path", path));
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
    NSFileHandle *readHandle = [[currentTask standardOutput] fileHandleForReading];

    PSObserve(readHandle, NSFileHandleReadCompletionNotification, receivedData:);
    [readHandle readInBackgroundAndNotify];
    [currentTask launch];
    [currentTask waitUntilExit];
    PSStopObserving(readHandle, NSFileHandleReadCompletionNotification);

    if (cancelled) {
      currentTask = currentData = nil;
    } else {
      [currentData appendData: [readHandle readDataToEndOfFile]];

      NSInteger status = [currentTask terminationStatus];
      NSString *command = [[currentTask arguments] objectAtIndex: 0];
      NSString *output = [[NSString alloc] initWithData: currentData encoding: NSUTF8StringEncoding];
      currentTask = currentData = nil;

      if (status == 0) {
        [self notifyDelegateWithSelector: @selector(commandCompleted:output:) command: command output: output];
      } else {
        if ([output isMatchedByRegex: @"Authentication failed"]) {
          [PasswordHelper removePasswordForHost: repositoryUrl user: @"Gitifier"];
        }
        [self notifyDelegateWithSelector: @selector(commandFailed:output:) command: command output: output];
      }
    }
  } @catch (NSException *e) {
    NSString *command = [[currentTask arguments] objectAtIndex: 0];
    currentTask = currentData = nil;
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
