// -------------------------------------------------------
// RepositoryListController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Defaults.h"
#import "Repository.h"
#import "RepositoryListController.h"

@implementation RepositoryListController

- (NSArray *) repositoryList {
  return [self arrangedObjects];
}

- (void) addRepository: (Repository *) repository {
  [repository setDelegate: [NSApp delegate]];
  [self addObject: repository];
  [self saveRepositories];
}  

- (void) removeSelectedRepositories {
  NSArray *selectedRepositories = [self selectedObjects];
  [selectedRepositories makeObjectsPerformSelector: @selector(deleteWorkingCopy)];
  [self removeObjects: selectedRepositories];
  [self saveRepositories];
}

- (void) loadRepositories {
  NSArray *hashes = [GitifierDefaults arrayForKey: REPOSITORY_LIST_KEY];
  if (hashes) {
    for (NSDictionary *hash in hashes) {
      Repository *repo = [Repository repositoryFromHash: hash];
      if (repo) {
        [repo setDelegate: [NSApp delegate]];
        [self addObject: repo];
      }
    }
  }
}

- (void) saveRepositories {
  NSArray *repositories = [[self repositoryList] valueForKeyPath: @"hashRepresentation"];
  [GitifierDefaults setObject: repositories forKey: REPOSITORY_LIST_KEY];
  [GitifierDefaults synchronize];
}

@end
