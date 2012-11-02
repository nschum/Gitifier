// -------------------------------------------------------
// Commit.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "PSModel.h"

@class Repository;

@interface Commit : PSModel {
  NSString *authorName;
  NSString *authorEmail;
  NSString *subject;
  NSString *gitHash;
  NSDate *date;
  Repository *repository;
}

@property (copy) NSString *authorName;
@property (copy) NSString *authorEmail;
@property (copy) NSString *subject;
@property (copy) NSString *gitHash;
@property (copy) NSDate *date;
@property (strong) Repository *repository;

+ (Commit *) commitFromDictionary: (NSDictionary *) dictionary;
+ (NSArray *) chooseRelevantCommits: (NSArray *) commits forUser: (NSString *) userEmail;

- (BOOL) isMergeCommit;
- (NSDictionary *) toDictionary;

@end
