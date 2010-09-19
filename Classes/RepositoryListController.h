// -------------------------------------------------------
// RepositoryListController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>
#import "Monitor.h"

@class Repository;

@interface RepositoryListController : NSArrayController <MonitorDataSource> {}

// public
- (void) addRepository: (Repository *) repository;
- (void) removeSelectedRepositories;
- (void) loadRepositories;
- (void) saveRepositories;

@end
