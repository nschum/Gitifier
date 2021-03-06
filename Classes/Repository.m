// -------------------------------------------------------
// Repository.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "RegexKitLite.h"

#import "Commit.h"
#import "Git.h"
#import "Repository.h"
#import "RepositoryStatus.h"

static NSString *nameRegexp = @"[\\p{Ll}\\p{Lu}\\p{Lt}\\p{Lo}\\p{Nd}\\-\\.]+";
static NSString *commitRangeRegexp = @"[0-9a-f]+\\.\\.[0-9a-f]+";

@interface Repository ()

@property (nonatomic, copy) RepositoryStatus *status;

@end

@implementation Repository {
  Git *git;
  NSString *commitUrlPattern;
}

+ (NSDictionary *) repositoryUrlPatterns {
  static NSDictionary *patterns = nil;
  if (!patterns) {
    patterns = @{
      @"git@github\\.com:(NAME)\\/(NAME)\\.git":                   @"https://github.com/$1/$2/commit/%@",
      @"https?:\\/\\/(NAME)@github\\.com\\/(NAME)\\/(NAME)\\.git": @"https://github.com/$2/$3/commit/%@",
      @"git:\\/\\/github\\.com\\/(NAME)\\/(NAME)\\.git":           @"https://github.com/$1/$2/commit/%@",
      @"git:\\/\\/gitorious\\.org\\/(NAME)\\/(NAME)\\.git":        @"http://gitorious.org/$1/$2/commit/%@",
      @"http:\\/\\/git\\.gitorious\\.org\\/(NAME)\\/(NAME)\\.git": @"http://gitorious.org/$1/$2/commit/%@",
      @"git@bitbucket\\.org:(NAME)/(NAME)\\.git":                  @"https://bitbucket.org/$1/$2/commits/%@",
      @"https://(NAME)@bitbucket.org/(NAME)/(NAME).git":           @"https://bitbucket.org/$2/$3/commits/%@"
    };
  }
  return patterns;
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

    return self;
  } else {
    return nil;
  }
}

- (NSDictionary *) hashRepresentation {
  return @{@"url": self.url, @"name": self.name};
}

- (NSString *) findCommitUrlPattern {
  NSDictionary *patterns = [Repository repositoryUrlPatterns];

  for (NSString *pattern in patterns) {
    NSString *commitPattern = patterns[pattern];
    NSString *repoPattern = [pattern stringByReplacingOccurrencesOfString: @"NAME" withString: nameRegexp];
    repoPattern = PSFormat(@"^%@$", repoPattern); // looks like a curse that was censored, doesn't it? ;)

    if ([self.url isMatchedByRegex: repoPattern]) {
      return [self.url stringByReplacingOccurrencesOfRegex: repoPattern withString: commitPattern];
    }
  }

  return nil;
}

- (NSURL *) webUrlForCommit: (Commit *) commit {
  if (commitUrlPattern) {
    NSString *webUrl = [commitUrlPattern stringByReplacingOccurrencesOfString:@"%@" withString:commit.gitHash];
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
    self.status = [RepositoryStatus statusCloning];
    [git runCommand: @"clone" withArguments: @[self.url, workingCopy, @"-n", @"--depth", @"1", @"--no-single-branch"] inPath: cachesDirectory];
  } else {
    [self failWithMessage:@"Cached copy was deleted and can't be restored." reason:nil];
    if ([_delegate respondsToSelector:@selector(repositoryCouldNotBeCloned:)]) {
      assert([NSThread isMainThread]);
      [_delegate repositoryCouldNotBeCloned:self];
    }
  }
}

- (void)failWithMessage:(NSString *)message reason:(NSString *)reason {
  NSString *bundleIdentifier = [NSRunningApplication currentApplication].bundleIdentifier;
  NSDictionary *userInfo = @{
      NSLocalizedDescriptionKey: message,
      NSLocalizedFailureReasonErrorKey: reason ?: @"",
      NSFilePathErrorKey: self.url,
  };
  NSError *error = [NSError errorWithDomain:bundleIdentifier code:0 userInfo:userInfo];
  self.status = [[RepositoryStatus alloc] initWithError:error];
}

- (void) fetchNewCommits {
  if (!self.status.cloning && !self.status.updating) {
    NSString *workingCopy = [self workingCopyDirectory];
    if (workingCopy) {
      if ([self directoryExists: workingCopy]) {
        self.status = [RepositoryStatus statusUpdating];
        [git runCommand: @"fetch" inPath: workingCopy];
      } else {
        NSLog(@"Working copy directory %@ was deleted, I need to clone it again.", workingCopy);
        [self clone];
      }
    } else {
      [self failWithMessage:@"Can't fetch repository." reason:nil];
      if ([_delegate respondsToSelector:@selector(repositoryCouldNotBeFetched:)]) {
        assert([NSThread isMainThread]);
        [_delegate repositoryCouldNotBeFetched:self];
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
    self.status = [RepositoryStatus new];

    if ([_delegate respondsToSelector:@selector(repositoryWasCloned:)]) {
      assert([NSThread isMainThread]);
      [_delegate repositoryWasCloned:self];
    }
  } else if ([command isEqual: @"fetch"]) {
    NSArray *commitRanges = [output componentsMatchedByRegex: commitRangeRegexp];
    NSArray *arguments = [commitRanges arrayByAddingObject: @"--pretty=tformat:%ai%n%H%n%aN%n%aE%n%s%n"];
    NSString *workingCopy = [self workingCopyDirectory];
    if (commitRanges.count > 0 && workingCopy && [self directoryExists: workingCopy]) {
      [git runCommand: @"log" withArguments: arguments inPath: workingCopy];
    } else {
      self.status = [RepositoryStatus new];
    }
    if ([_delegate respondsToSelector:@selector(repositoryWasFetched:)]) {
      assert([NSThread isMainThread]);
      [_delegate repositoryWasFetched:self];
    }
  } else if ([command isEqual: @"log"]) {
    NSArray *commitData = [output arrayOfCaptureComponentsMatchedByRegex:
                                  @"([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)\\n([^\\n]+)(\\n\\n)"];
    NSMutableArray *commits = [NSMutableArray arrayWithCapacity: commitData.count];
    for (NSArray *fields in commitData) {
      Commit *commit = [[Commit alloc] init];
      commit.date = [NSDate dateWithString: fields[1]];
      commit.gitHash = fields[2];
      commit.authorName = fields[3];
      commit.authorEmail = fields[4];
      commit.subject = fields[5];
      commit.repository = self;
      [commits addObject: commit];
    }
    self.status = [RepositoryStatus new];
    id <RepositoryDelegate> o = self.delegate;
    if ([o respondsToSelector:@selector(commitsReceived:inRepository:)]) {
      assert([NSThread isMainThread]);
      [o commitsReceived:commits inRepository:self];
    }
  }
}

- (void) commandFailed: (NSString *) command output: (NSString *) output {
  if ([command isEqual: @"clone"]) {
    [self failWithMessage:@"Cached copy was deleted and can't be restored." reason:nil];
    if ([_delegate respondsToSelector:@selector(repositoryCouldNotBeCloned:)]) {
      assert([NSThread isMainThread]);
      [_delegate repositoryCouldNotBeCloned:self];
    }
  } else {
    NSString *message = [NSString stringWithFormat:@"Command git %@ failed", command];
    NSLog(@"%@: %@", message, output);
    [self failWithMessage:message reason:output];
    if ([_delegate respondsToSelector:@selector(repositoryCouldNotBeFetched:)]) {
      assert([NSThread isMainThread]);
      [_delegate repositoryCouldNotBeFetched:self];
    }
  }
}

- (BOOL) isProperUrl: (NSString *) anUrl {
  return [anUrl psIsPresent];
}

- (NSString *) nameFromUrl: (NSString *) anUrl {
  NSArray *names = [anUrl componentsSeparatedByRegex: @"[/:]"];
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
  NSString *userCachesDirectory = [directories firstObject];
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

@end
