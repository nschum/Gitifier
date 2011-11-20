// -------------------------------------------------------
// Commit.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Commit.h"
#import "Defaults.h"
#import "RegexKitLite.h"

@implementation Commit

@synthesize authorName, authorEmail, subject, gitHash, date;

+ (Commit *) commitFromDictionary: (NSDictionary *) dictionary {
  return (Commit *) [Commit objectFromJSON: dictionary];
}

+ (NSArray *) propertyList {
  return PSArray(@"authorName", @"authorEmail", @"subject", @"gitHash", @"date");
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
  return [subject isMatchedByRegex: @"^Merge branch '.*'"];
}

- (NSDictionary *) toDictionary {
  return PSHash(
    @"authorName", authorName,
    @"authorEmail", authorEmail,
    @"subject", subject,
    @"gitHash", gitHash,
    @"date", date
  );
}

@end
