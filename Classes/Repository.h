// -------------------------------------------------------
// Repository.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Repository;

@protocol RepositoryDelegate
- (void) commitsReceived: (NSArray *) commits inRepository: (Repository *) repository;
@end

// ------------------------------

@class Git;

@interface Repository : NSObject {
  Git *git;
  NSString *url;
  NSString *name;
  NSString *commitUrlPattern;
  id delegate;
  BOOL isBeingUpdated;
}

@property (copy) NSString *url;
@property (copy) NSString *name;
@property id delegate;
@property (readonly) NSString *commitUrlPattern;

// public
+ (Repository *) repositoryFromHash: (NSDictionary *) hash;
- (id) initWithUrl: (NSString *) anUrl;
- (void) clone;
- (void) fetchNewCommits;
- (void) cancelCommands;
- (void) deleteWorkingCopy;
- (NSDictionary *) hashRepresentation;
- (NSString *) workingCopyDirectory;
- (BOOL) directoryExists: (NSString *) directory;

// private
+ (NSDictionary *) repositoryUrlPatterns;
- (NSString *) findCommitUrlPattern;
- (BOOL) isProperUrl: (NSString *) url;
- (NSString *) nameFromUrl: (NSString *) anUrl;
- (NSString *) cachesDirectory;
- (void) notifyDelegateWithSelector: (SEL) selector;
- (BOOL) ensureDirectoryIsDeleted: (NSString *) directory;
- (BOOL) ensureDirectoryExists: (NSString *) directory;

@end
