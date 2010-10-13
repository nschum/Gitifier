// -------------------------------------------------------
// Commit.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>
#import "PSModel.h"

@interface Commit : PSModel {
  NSString *authorName;
  NSString *authorEmail;
  NSString *subject;
  NSString *gitHash;
  NSDate *date;
}

@property (copy) NSString *authorName;
@property (copy) NSString *authorEmail;
@property (copy) NSString *subject;
@property (copy) NSString *gitHash;
@property (copy) NSDate *date;

+ (Commit *) commitFromDictionary: (NSDictionary *) dictionary;
- (BOOL) isMergeCommit;
- (NSDictionary *) toDictionary;

@end
