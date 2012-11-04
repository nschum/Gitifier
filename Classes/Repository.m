// -------------------------------------------------------
// Repository.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Commit.h"
#import "Git.h"
#import "GrowlController.h"
#import "Repository.h"

static NSString *namePattern = @"[\\p{Ll}\\p{Lu}\\p{Lt}\\p{Lo}\\p{Nd}\\-\\.]+";
static NSString *commitRangePattern = @"[0-9a-f]+\\.\\.[0-9a-f]+";
static NSString *commitDataPattern = @"([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)(\\n\\n)";
static NSRegularExpression *commitDataRegex;
static NSRegularExpression *commitRangeRegex;
static NSDictionary *repositoryUrlPatterns;

@implementation Repository {
  RepositoryStatus status;
  Git *git;
  NSString *commitUrlPattern;
  BOOL isBeingUpdated;
}

+ (void) initialize {
  commitDataRegex = [NSRegularExpression regularExpressionWithPattern: commitDataPattern options: 0 error: nil];
  commitRangeRegex = [NSRegularExpression regularExpressionWithPattern: commitRangePattern options: 0 error: nil];

  repositoryUrlPatterns = @{
    [self urlRegexWithPattern: @"git@github\\.com:(NAME)\\/(NAME)\\.git"]:
      @"http://github.com/$1/$2/commit/%@",

    [self urlRegexWithPattern: @"https?:\\/\\/(NAME)@github\\.com\\/(NAME)\\/(NAME)\\.git"]:
      @"http://github.com/$2/$3/commit/%@",

    [self urlRegexWithPattern: @"git:\\/\\/github\\.com\\/(NAME)\\/(NAME)\\.git"]:
      @"http://github.com/$1/$2/commit/%@",

    [self urlRegexWithPattern: @"git:\\/\\/gitorious\\.org\\/(NAME)\\/(NAME)\\.git"]:
      @"http://gitorious.org/$1/$2/commit/%@",

    [self urlRegexWithPattern: @"http:\\/\\/git\\.gitorious\\.org\\/(NAME)\\/(NAME)\\.git"]:
      @"http://gitorious.org/$1/$2/commit/%@"
  };
}

+ (NSRegularExpression *) urlRegexWithPattern: (NSString *) pattern {
  NSString *expandedPattern = [pattern stringByReplacingOccurrencesOfString: @"NAME" withString: namePattern];

  return [NSRegularExpression regularExpressionWithPattern: PSFormat(@"^%@$", expandedPattern) options: 0 error: nil];
}

+ (Repository *) repositoryFromHash: (NSDictionary *) hash {
  NSString *url = hash[@"url"];
  NSString *name = hash[@"name"];
  Repository *repo = nil;
  if (url) {
    repo = [[Repository alloc] initWithUrl: url];
    if (name) {
      repo.name = name;
    }
  }
  return repo;
}

+ (Repository *) repositoryWithUrl: (NSString *) aUrl {
  return [[Repository alloc] initWithUrl: aUrl];
}

- (id) initWithUrl: (NSString *) aUrl {
  self = [super init];
  if ([self isProperUrl: aUrl]) {
    self.url = aUrl;
    self.name = [self nameFromUrl: aUrl];

    git = [[Git alloc] initWithDelegate: self];
    git.repositoryUrl = self.url;

    commitUrlPattern = [self findCommitUrlPattern];
    status = ActiveRepository;

    return self;
  } else {
    return nil;
  }
}

- (NSDictionary *) hashRepresentation {
  return @{@"url": self.url, @"name": self.name};
}

- (void) resetStatus {
  status = ActiveRepository;
}

- (NSString *) findCommitUrlPattern {
  for (NSRegularExpression *regex in repositoryUrlPatterns) {
    if ([self.url isMatchedByRegex: regex]) {
      return [regex stringByReplacingMatchesInString: self.url
                                             options: 0
                                               range: NSMakeRange(0, self.url.length)
                                        withTemplate: repositoryUrlPatterns[regex]];
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
    [git runCommand: @"clone" withArguments: @[self.url, workingCopy, @"-n"] inPath: cachesDirectory];
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
    NSArray *commitRanges = [output componentsMatchedByRegex: commitRangeRegex];
    NSArray *arguments = [commitRanges arrayByAddingObject: @"--pretty=tformat:%ai%n%H%n%aN%n%aE%n%s%n"];
    NSString *workingCopy = [self workingCopyDirectory];
    if (commitRanges.count > 0 && workingCopy && [self directoryExists: workingCopy]) {
      [git runCommand: @"log" withArguments: arguments inPath: workingCopy];
    } else {
      isBeingUpdated = NO;
      status = ActiveRepository;
    }
  } else if ([command isEqual: @"log"]) {
    NSArray *matches = [output arrayOfCaptureComponentsMatchedByRegex: commitDataRegex];
    NSMutableArray *commits = [NSMutableArray arrayWithCapacity: matches.count];

    for (NSArray *fields in matches) {
      Commit *commit = [[Commit alloc] init];
      commit.date = [NSDate dateWithString: fields[1]];
      commit.gitHash = fields[2];
      commit.authorName = fields[3];
      commit.authorEmail = fields[4];
      commit.subject = fields[5];
      commit.repository = self;
      [commits addObject: commit];
    }

    isBeingUpdated = NO;
    status = ActiveRepository;
    [self.delegate commitsReceived: commits inRepository: self];
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

- (BOOL) isProperUrl: (NSString *) aUrl {
  return [aUrl psIsPresent];
}

- (NSString *) nameFromUrl: (NSString *) aUrl {
  NSCharacterSet *separators = [NSCharacterSet characterSetWithCharactersInString: @"/:"];
  NSArray *names = [aUrl componentsSeparatedByCharactersInSet: separators];

  NSString *projectName = [names lastObject];
  if ([projectName isEqual: @""]) {
    projectName = names[names.count - 2];
  }
  if ([projectName hasSuffix: @".git"]) {
    projectName = [projectName substringToIndex: projectName.length - 4];
  }
  if ([projectName isEqual: @""]) {
    projectName = names[names.count - 3];
  }
  if ([[projectName lowercaseString] isEqualToString: projectName] && ![projectName psContainsString: @"_"]) {
    projectName = [projectName capitalizedString];
  }
  return projectName;
}

- (NSString *) cachesDirectory {
  NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *userCachesDirectory = [directories psFirstObject];
  if (!userCachesDirectory) {
    NSLog(@"Error: Caches directory could not be found.");
    return nil;
  }

  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  return [userCachesDirectory stringByAppendingPathComponent: bundleIdentifier];
}

- (NSString *) workingCopyDirectory {
  return [[self cachesDirectory] stringByAppendingPathComponent: [self.url MD5Hash]];
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
  if ([self.delegate respondsToSelector: selector]) {
    [self.delegate performSelectorOnMainThread: selector withObject: self waitUntilDone: NO];
  }
}

@end
