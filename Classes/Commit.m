// -------------------------------------------------------
// Commit.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Commit.h"
#import "Defaults.h"

static NSRegularExpression *mergeCommitRegex;

@implementation Commit

+ (void) initialize {
  mergeCommitRegex = [NSRegularExpression regularExpressionWithPattern: @"^Merge branch '.*'" options: 0 error: nil];
}

+ (Commit *) commitFromDictionary: (NSDictionary *) dictionary {
  return (Commit *) [Commit objectFromJSON: dictionary];
}

+ (NSArray *) propertyList {
  return @[@"authorName", @"authorEmail", @"subject", @"gitHash", @"date", @"repository"];
}

+ (NSArray *) chooseRelevantCommits: (NSArray *) commits forUser: (NSString *) userEmail {
  BOOL ignoreMerges = [GitifierDefaults boolForKey: IgnoreMergesKey];
  BOOL ignoreOwnCommits = [GitifierDefaults boolForKey: IgnoreOwnCommitsKey];
  NSMutableArray *relevantCommits = [NSMutableArray arrayWithCapacity: commits.count];

  for (Commit *commit in commits) {
    if (ignoreMerges && [commit isMergeCommit]) continue;
    if (ignoreOwnCommits && [commit.authorEmail isEqualToString: userEmail]) continue;

    [relevantCommits addObject: commit];
  }

  return relevantCommits;
}

- (BOOL) isMergeCommit {
  return [self.subject isMatchedByRegex: mergeCommitRegex];
}

- (NSDictionary *) toDictionary {
  return @{
    @"authorName": self.authorName,
    @"authorEmail": self.authorEmail,
    @"subject": self.subject,
    @"gitHash": self.gitHash,
    @"date": self.date
  };
}

@end
