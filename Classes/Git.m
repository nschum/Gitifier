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
#import "PSMacros.h"

static NSString *gitExecutable = nil;

@implementation Git {
  NSTask *currentTask;
  BOOL cancelled;
  /*__weak*/ id delegate;
}

+ (NSString *) gitExecutable {
  return gitExecutable;
}

+ (void) setGitExecutable: (NSString *) path {
  [self willChangeValueForKey: @"gitExecutable"];
  path = [path psTrimmedString];
  gitExecutable = [path isEqual: @""] ? nil : path;
  [self didChangeValueForKey: @"gitExecutable"];
  PSNotifyWithData(GitExecutableSetNotification, @{@"path": path ? path : PSNull});
}

- (id) initWithDelegate: (id) aDelegate {
  self = [super init];
  if (self) {
    delegate = aDelegate;
  }
  return self;
}

- (void) runCommand: (NSString *) command inPath: (NSString *) path {
  [self runCommand: command withArguments: @[] inPath: path];
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

  PSLog(@"running command git %@ %@", command, arguments);

  NSPipe *output = [NSPipe pipe];
  currentTask = [[NSTask alloc] init];
  currentTask.arguments = [@[command] arrayByAddingObjectsFromArray: arguments];
  currentTask.currentDirectoryPath = path;
  currentTask.launchPath = gitExecutable;
  currentTask.standardInput = [NSFileHandle fileHandleWithNullDevice];
  currentTask.standardOutput = output;
  currentTask.standardError = output;

  if (self.repositoryUrl) {
    NSString *askPassPath = [[NSBundle mainBundle] pathForResource: @"AskPass" ofType: @""];
    NSInteger pid = [[NSProcessInfo processInfo] processIdentifier];
    NSMutableDictionary *environment = [[[NSProcessInfo processInfo] environment] mutableCopy];

    NSDictionary *customEnvironment = [[NSUserDefaults standardUserDefaults] objectForKey: @"gitEnvironment"];
    if (customEnvironment) {
      [environment addEntriesFromDictionary: customEnvironment];
    }

    environment[@"DISPLAY"] = @"Gitifier";
    environment[@"SSH_ASKPASS"] = askPassPath;
    environment[@"AUTH_HOSTNAME"] = self.repositoryUrl;
    environment[@"AUTH_USERNAME"] = @"Gitifier";
    environment[@"GITIFIER_PID"] = @(pid);

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

    [currentTask launch];

    NSMutableData *collectedData = [[NSMutableData alloc] init];
    NSData *incomingData;

    while (true) {
      incomingData = [readHandle availableData];

      if (incomingData.length == 0) {
        break;
      } else {
        [collectedData appendData: incomingData];
      }
    }

    [currentTask waitUntilExit];

    if (cancelled) {
      currentTask = nil;
    } else {
      [readHandle closeFile];

      NSInteger status = [currentTask terminationStatus];
      NSString *command = [[currentTask arguments] firstObject];
      NSString *output = [[NSString alloc] initWithData: collectedData encoding: NSUTF8StringEncoding];
      currentTask = nil;

      if (status == 0) {
        PSLog(@"command git %@ completed with output: %@", command, output);
        [self notifyDelegateWithSelector: @selector(commandCompleted:output:) command: command output: output];
      } else {
        if ([output isMatchedByRegex: @"Authentication failed"]) {
          [PasswordHelper removePasswordForHost: self.repositoryUrl user: @"Gitifier"];
        }
        PSLog(@"command git %@ failed with output: %@", command, output);
        [self notifyDelegateWithSelector: @selector(commandFailed:output:) command: command output: output];
      }
    }
  } @catch (NSException *e) {
    NSString *command = [[currentTask arguments] firstObject];
    currentTask = nil;
    PSLog(@"command git %@ failed with exception: %@", command, e);
    [self notifyDelegateWithSelector: @selector(commandFailed:output:) command: command output: [e description]];
    return;
  }
}

- (void) notifyDelegateWithSelector: (SEL) selector command: (NSString *) command output: (NSString *) output {
  if ([delegate respondsToSelector: selector]) {
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
      [delegate performSelector: selector withObject: command withObject: output];
    }];
  }
}

@end
