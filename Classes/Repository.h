// -------------------------------------------------------
// Repository.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@class Commit;
@class Git;
@class Repository;

@protocol RepositoryDelegate<NSObject>
@optional

- (void) commitsReceived: (NSArray *) commits inRepository: (Repository *) repository;
- (void) repositoryWasFetched:(Repository *)repository;
- (void) repositoryCouldNotBeFetched:(Repository *)repository error:(NSError *)error;
- (void) repositoryWasCloned: (Repository *) repository;
- (void) repositoryCouldNotBeCloned: (Repository *) repository error:(NSError *)error;

@end

// ------------------------------

@interface Repository : NSObject

@property (copy) NSString *url;
@property (copy) NSString *name;
@property (nonatomic, copy, readonly) NSError *lastError;
@property (weak) id<RepositoryDelegate> delegate;

+ (Repository *) repositoryFromHash: (NSDictionary *) hash;
+ (Repository *) repositoryWithUrl: (NSString *) anUrl;
- (id) initWithUrl: (NSString *) anUrl;
- (void) clone;
- (void) fetchNewCommits;
- (void) cancelCommands;
- (void) deleteWorkingCopy;
- (NSDictionary *) hashRepresentation;
- (NSString *) workingCopyDirectory;
- (BOOL) directoryExists: (NSString *) directory;
- (NSURL *) webUrlForCommit: (Commit *) commit;

@end
