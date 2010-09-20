// -------------------------------------------------------
// Commit.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface Commit : NSObject {
  NSString *authorName;
  NSString *authorEmail;
  NSString *subject;
}

@property (copy) NSString *authorName;
@property (copy) NSString *authorEmail;
@property (copy) NSString *subject;

- (BOOL) isMergeCommit;

@end
