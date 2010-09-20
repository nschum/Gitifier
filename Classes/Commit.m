// -------------------------------------------------------
// Commit.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Commit.h"
#import "RegexKitLite.h"

@implementation Commit

@synthesize authorName, authorEmail, subject;

- (BOOL) isMergeCommit {
  return [subject isMatchedByRegex: @"^Merge branch '.*'"];
}

@end
