// -------------------------------------------------------
// Repository.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "RegexKitLite.h"

#import "Commit.h"
#import "Git.h"
#import "GrowlController.h"
#import "Repository.h"
#import "Utils.h"

static NSString *nameRegexp = @"[\\p{Ll}\\p{Lu}\\p{Lt}\\p{Lo}\\p{Nd}\\-\\.]+";
static NSString *commitRangeRegexp = @"[0-9a-f]+\\.\\.[0-9a-f]+";

@implementation Repository

@synthesize url, name, delegate;

+ (NSDictionary *) repositoryUrlPatterns {
  static NSMutableDictionary *patterns = nil;
  if (!patterns) {
    patterns = [NSMutableDictionary dictionary];

    [patterns setObject: @"http://github.com/$1/$2/commit/%@"
                 forKey: @"git@github\\.com:(NAME)\\/(NAME)\\.git"];

    [patterns setObject: @"http://github.com/$2/$3/commit/%@"
                 forKey: @"https?:\\/\\/(NAME)@github\\.com\\/(NAME)\\/(NAME)\\.git"];

    [patterns setObject: @"http://github.com/$1/$2/commit/%@"
                 forKey: @"git:\\/\\/github\\.com\\/(NAME)\\/(NAME)\\.git"];

    [patterns setObject: @"http://gitorious.org/$1/$2/commit/%@"
                 forKey: @"git:\\/\\/gitorious\\.org\\/(NAME)\\/(NAME)\\.git"];

    [patterns setObject: @"http://gitorious.org/$1/$2/commit/%@"
                 forKey: @"http:\\/\\/git\\.gitorious\\.org\\/(NAME)\\/(NAME)\\.git"];
  }
  return patterns;
}

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
    git.repositoryUrl = self.url;
    name = [self nameFromUrl: url];
    commitUrlPattern = [self findCommitUrlPattern];
    status = ActiveRepository;
    return self;
  } else {
    return nil;
  }
}

- (NSDictionary *) hashRepresentation {
  return PSHash(@"url", url, @"name", name);
}

- (void) resetStatus {
  status = ActiveRepository;
}

- (NSString *) findCommitUrlPattern {
  NSDictionary *patterns = [Repository repositoryUrlPatterns];

  for (NSString *repoPattern in patterns) {
    NSString *commitPattern = [patterns objectForKey: repoPattern];
    repoPattern = [repoPattern stringByReplacingOccurrencesOfString: @"NAME" withString: nameRegexp];
    repoPattern = PSFormat(@"^%@$", repoPattern); // looks like a curse that was censored, doesn't it? ;)

    if ([url isMatchedByRegex: repoPattern]) {
      return [url stringByReplacingOccurrencesOfRegex: repoPattern withString: commitPattern];
    }
  }

  return nil;
}

- (NSURL *) webUrlForCommit: (Commit *) commit {
  if (commitUrlPattern) {
    NSString *webUrl = PSFormat(commitUrlPattern, commit.gitHash);
    return [NSURL URLWithString: webUrl];
  } else {
    return nil;
  }
}

- (void) clone {
  NSString *cachesDirectory = [self cachesDirectory];
  NSString *workingCopy = [self workingCopyDirectory];
  BOOL cachesDirectoryExists = cachesDirectory && [self ensureDirectoryExists: cachesDirectory];
  BOOL workingCopyDoesntExist = workingCopy && [self ensureDirectoryIsDeleted: workingCopy];

  if (cachesDirectoryExists && workingCopyDoesntExist) {
    isBeingUpdated = YES;
    [git runCommand: @"clone" withArguments: PSArray(url, workingCopy, @"-n") inPath: cachesDirectory];
  } else {
    [self notifyDelegateWithSelector: @selector(repositoryCouldNotBeCloned:)];
  }
}

- (void) fetchNewCommits {
  if (!isBeingUpdated) {
    NSString *workingCopy = [self workingCopyDirectory];
    if (workingCopy) {
      if ([self directoryExists: workingCopy]) {
        isBeingUpdated = YES;
        [git runCommand: @"fetch" inPath: workingCopy];
      } else {
        NSLog(@"Working copy directory %@ was deleted, I need to clone it again.", workingCopy);
        [self clone];
      }
    } else {
      [[GrowlController sharedController] showGrowlWithError: @"Can't fetch repository." repository: self];
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
    isBeingUpdated = NO;
    [self notifyDelegateWithSelector: @selector(repositoryWasCloned:)];
  } else if ([command isEqual: @"fetch"]) {
    NSArray *commitRanges = [output componentsMatchedByRegex: commitRangeRegexp];
    NSArray *arguments = [commitRanges arrayByAddingObject: @"--pretty=tformat:%ai%n%H%n%aN%n%aE%n%s%n"];
    NSString *workingCopy = [self workingCopyDirectory];
    if (commitRanges.count > 0 && workingCopy && [self directoryExists: workingCopy]) {
      [git runCommand: @"log" withArguments: arguments inPath: workingCopy];
    } else {
      isBeingUpdated = NO;
      status = ActiveRepository;
    }
  } else if ([command isEqual: @"log"]) {
    NSArray *commitData = [output arrayOfCaptureComponentsMatchedByRegex:
                                  @"([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)(\\n\\n)"];
    NSMutableArray *commits = [NSMutableArray arrayWithCapacity: commitData.count];
    for (NSArray *fields in commitData) {
      Commit *commit = [[Commit alloc] init];
      commit.date = [NSDate dateWithString: [fields objectAtIndex: 1]];
      commit.gitHash = [fields objectAtIndex: 2];
      commit.authorName = [fields objectAtIndex: 3];
      commit.authorEmail = [fields objectAtIndex: 4];
      commit.subject = [fields objectAtIndex: 5];
      [commits addObject: commit];
    }
    isBeingUpdated = NO;
    status = ActiveRepository;
    [delegate commitsReceived: commits inRepository: self];
  }
}

- (void) commandFailed: (NSString *) command output: (NSString *) output {
  isBeingUpdated = NO;
  if ([command isEqual: @"clone"]) {
    [self notifyDelegateWithSelector: @selector(repositoryCouldNotBeCloned:)];
  } else if (status != UnavailableRepository) {
    status = UnavailableRepository;
    NSString *truncated = (output.length > 100) ? PSFormat(@"%@...", [output substringToIndex: 100]) : output;
    [[GrowlController sharedController] showGrowlWithError: PSFormat(@"Command %@ failed: %@", command, truncated)
                                                repository: self];
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
  if ([[projectName lowercaseString] isEqualToString: projectName]) {
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
