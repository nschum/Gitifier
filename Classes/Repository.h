// -------------------------------------------------------
// Repository.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@class Commit;
@class Git;
@class Repository;

typedef enum { ActiveRepository, UnavailableRepository } RepositoryStatus;

@protocol RepositoryDelegate<NSObject>
@optional

- (void) commitsReceived: (NSArray *) commits inRepository: (Repository *) repository;
- (void) repositoryWasCloned: (Repository *) repository;
- (void) repositoryCouldNotBeCloned: (Repository *) repository;

@end

// ------------------------------

@interface Repository : NSObject

@property (copy) NSString *url;
@property (copy) NSString *name;
@property (weak) id<RepositoryDelegate> delegate;

+ (Repository *) repositoryFromHash: (NSDictionary *) hash;
+ (Repository *) repositoryWithUrl: (NSString *) anUrl;
- (id) initWithUrl: (NSString *) anUrl;
- (void) clone;
- (void) fetchNewCommits;
- (void) cancelCommands;
- (void) deleteWorkingCopy;
- (void) resetStatus;
- (NSDictionary *) hashRepresentation;
- (NSString *) workingCopyDirectory;
- (BOOL) directoryExists: (NSString *) directory;
- (NSURL *) webUrlForCommit: (Commit *) commit;

@end
