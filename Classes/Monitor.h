// -------------------------------------------------------
// Monitor.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@protocol MonitorDataSource
- (NSArray *) repositoryList;
@end

// ------------------------------

@interface Monitor : NSObject

@property IBOutlet id dataSource;

- (void) startMonitoring;
- (void) restartMonitoring;
- (void) executeFetch;

@end
