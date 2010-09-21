// -------------------------------------------------------
// Repository.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "RegexKitLite.h"

#import "Commit.h"
#import "Git.h"
#import "Repository.h"
#import "Utils.h"

static NSString *commitRangeRegexp = @"[0-9a-f]+\\.\\.[0-9a-f]+";

@implementation Repository

@synthesize url, name, delegate;

+ (Repository *) repositoryFromHash: (NSDictionary *) hash {
  NSString *url = [hash objectForKey: @"url"];
  NSString *name = [hash objectForKey: @"name"];
  Repository *repo = nil;
  if (url) {
    repo = [[Repository alloc] initWithUrl: url];
    if (name) {
      repo.name = name;
    }
  }
  return repo;
}

- (id) initWithUrl: (NSString *) anUrl {
  self = [super init];
  if ([self isProperUrl: anUrl]) {
    url = anUrl;
    git = [[Git alloc] initWithDelegate: self];
    name = [self nameFromUrl: url];
    return self;
  } else {
    return nil;
  }
}

- (NSDictionary *) hashRepresentation {
  return PSDict(url, @"url", name, @"name");
}

- (void) clone {
  NSString *cachesDirectory = [self cachesDirectory];
  NSString *workingCopy = [self workingCopyDirectory];
  BOOL cachesDirectoryExists = cachesDirectory && [self ensureDirectoryExists: cachesDirectory];
  BOOL workingCopyDoesntExist = workingCopy && [self ensureDirectoryIsDeleted: workingCopy];

  if (cachesDirectoryExists && workingCopyDoesntExist) {
    [git runCommand: @"clone" withArguments: PSArray(url, workingCopy, @"-n") inPath: cachesDirectory];
  } else {
    [self notifyDelegateWithSelector: @selector(repositoryCouldNotBeCloned:)];
  }
}

- (void) fetchNewCommits {
  if (!isBeingUpdated) {
    isBeingUpdated = YES;
    NSString *workingCopy = [self workingCopyDirectory];
    if (workingCopy) {
      if ([self directoryExists: workingCopy]) {
        [git runCommand: @"fetch" inPath: workingCopy];
      } else {
        NSLog(@"Working copy directory %@ was deleted, I need to clone it again.", workingCopy);
        [self clone];
      }
    }
  }
}

- (void) cancelCommands {
  [git cancelCommands];
}

- (void) deleteWorkingCopy {
  [self ensureDirectoryIsDeleted: [self workingCopyDirectory]];
}

- (void) commandCompleted: (NSString *) command output: (NSString *) output {
  if ([command isEqual: @"clone"]) {
    [self notifyDelegateWithSelector: @selector(repositoryWasCloned:)];
  } else if ([command isEqual: @"fetch"]) {
    NSArray *commitRanges = [output componentsMatchedByRegex: commitRangeRegexp];
    NSArray *arguments = [commitRanges arrayByAddingObject: @"--pretty=tformat:%aN%n%aE%n%s%n"];
    NSString *workingCopy = [self workingCopyDirectory];
    if (commitRanges.count > 0 && workingCopy && [self directoryExists: workingCopy]) {
      [git runCommand: @"log" withArguments: arguments inPath: workingCopy];
    } else {
      isBeingUpdated = NO;
    }
  } else if ([command isEqual: @"log"]) {
    NSArray *commitData = [output arrayOfCaptureComponentsMatchedByRegex: @"([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)(\\n\\n)"];
    NSMutableArray *commits = [NSMutableArray arrayWithCapacity: commitData.count];
    for (NSArray *fields in commitData) {
      Commit *commit = [[Commit alloc] init];
      commit.authorName = [fields objectAtIndex: 1];
      commit.authorEmail = [fields objectAtIndex: 2];
      commit.subject = [fields objectAtIndex: 3];
      [commits addObject: commit];
    }
    [delegate commitsReceived: commits inRepository: self];
    isBeingUpdated = NO;
  }
}

- (void) commandFailed: (NSString *) command output: (NSString *) output {
  if ([command isEqual: @"clone"]) {
    [self notifyDelegateWithSelector: @selector(repositoryCouldNotBeCloned:)];
  } else {
    isBeingUpdated = NO;
    NSString *truncated = (output.length > 100) ? PSFormat(@"%@...", [output substringToIndex: 100]) : output;
    NSLog(@"command %@ failed: \"%@\"", command, truncated);
  }
}

- (BOOL) isProperUrl: (NSString *) anUrl {
  return ![anUrl isMatchedByRegex: @"\\s"];
}

- (NSString *) nameFromUrl: (NSString *) anUrl {
  NSArray *names = [anUrl componentsSeparatedByString: @"/"];
  NSString *projectName = [names lastObject];
  if ([projectName isEqual: @""]) {
    projectName = [names objectAtIndex: names.count - 2];
  }
  if ([projectName hasSuffix: @".git"]) {
    projectName = [projectName substringToIndex: projectName.length - 4];
  }
  if ([[projectName lowercaseString] isEqual: projectName]) {
    projectName = [projectName capitalizedString];
  }
  return projectName;
}

- (NSString *) cachesDirectory {
  NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *userCachesDirectory = [directories objectAtIndex: 0];
  if (!userCachesDirectory) {
    NSLog(@"Error: Caches directory could not be found.");
    return nil;
  }

  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  return [userCachesDirectory stringByAppendingPathComponent: bundleIdentifier];
}

- (NSString *) workingCopyDirectory {
  return [[self cachesDirectory] stringByAppendingPathComponent: [url MD5Hash]];
}

- (BOOL) ensureDirectoryIsDeleted: (NSString *) directory {
  NSFileManager *manager = [NSFileManager defaultManager];
  NSError *error;

  BOOL exists = [manager fileExistsAtPath: directory];
  if (exists) {
    BOOL removed = [manager removeItemAtPath: directory error: &error];
    if (!removed) {
      NSLog(@"Error: File or directory %@ could not be deleted: %@.", directory, error.localizedDescription);
      return NO;
    }
  }

  return YES;
}

- (BOOL) directoryExists: (NSString *) directory {
  BOOL isDirectory;
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath: directory isDirectory: &isDirectory];
  return exists && isDirectory;
}

- (BOOL) ensureDirectoryExists: (NSString *) directory {
  NSFileManager *manager = [NSFileManager defaultManager];
  NSError *error;
  BOOL isDirectory;
  BOOL exists = [manager fileExistsAtPath: directory isDirectory: &isDirectory];
  if (exists) {
    if (isDirectory) {
      return YES;
    } else {
      BOOL removed = [manager removeItemAtPath: directory error: &error];
      if (!removed) {
        NSLog(@"Error: File or directory %@ could not be deleted: %@.", directory, error.localizedDescription);
        return NO;
      }
    }
  }

  BOOL created = [manager createDirectoryAtPath: directory
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: &error];
  if (!created) {
    NSLog(@"Error: Directory %@ could not be created: %@.", directory, error.localizedDescription);
    return NO;
  }

  return YES;
}

- (void) notifyDelegateWithSelector: (SEL) selector {
  if ([delegate respondsToSelector: selector]) {
    [delegate performSelector: selector withObject: self];
  }
}

@end
