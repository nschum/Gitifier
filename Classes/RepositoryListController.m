// -------------------------------------------------------
// RepositoryListController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
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

- (void) addObject: (id) repository {
  [repository addObserver: self forKeyPath: @"name" options: 0 context: nil];
  [super addObject: repository];
}

- (Repository *) findByUrl: (NSString *) url {
  for (Repository *repository in self.arrangedObjects) {
    if ([repository.url isEqualToString: url]) {
      return repository;
    }
  }
  return nil;
}

- (void) removeSelectedRepositories {
  NSArray *selectedRepositories = [self selectedObjects];
  [self performSelectorInBackground: @selector(deleteRepositoryDirectories:) withObject: selectedRepositories];
  [self removeObjects: selectedRepositories];
  [self saveRepositories];
}

- (void) deleteRepositoryDirectories: (NSArray *) selectedRepositories {
  [NSThread sleepForTimeInterval: 3.0];
  [selectedRepositories makeObjectsPerformSelector: @selector(deleteWorkingCopy)];
}

- (void) resetRepositoryStatuses {
  [[self arrangedObjects] makeObjectsPerformSelector: @selector(resetStatus)];
}

- (void) loadRepositories {
  NSArray *hashes = [GitifierDefaults arrayForKey: REPOSITORY_LIST_KEY];
  if (hashes) {
    for (id data in hashes) {
      Repository *repo = nil;

      if ([data isKindOfClass: [NSDictionary class]]) {
        repo = [Repository repositoryFromHash: data];
      } else if ([data isKindOfClass: [NSString class]]) {
        repo = [Repository repositoryWithUrl: data];
      }

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

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context {
  [self saveRepositories];
}

@end
