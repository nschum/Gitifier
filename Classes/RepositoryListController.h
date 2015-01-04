// -------------------------------------------------------
// RepositoryListController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Monitor.h"

@class Repository;

@interface RepositoryListController : NSArrayController <MonitorDataSource>

- (void) addRepository: (Repository *) repository;
- (void) removeSelectedRepositories;
- (void) loadRepositories;
- (void) saveRepositories;
- (Repository *) findByUrl: (NSString *) url;

@end
