// -------------------------------------------------------
// RepositoryListController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Repository.h"
#import "RepositoryListController.h"

#define REPOSITORY_LIST_KEY @"repositoryList"

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
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSArray *hashes = [settings arrayForKey: REPOSITORY_LIST_KEY];
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
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSArray *repositories = [[self repositoryList] valueForKeyPath: @"hashRepresentation"];
  [settings setObject: repositories forKey: REPOSITORY_LIST_KEY];
  [settings synchronize];
}

@end
