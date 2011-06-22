// -------------------------------------------------------
// Monitor.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@protocol MonitorDataSource
- (NSArray *) repositoryList;
@end

// ------------------------------

@interface Monitor : NSObject {
  NSTimer *timer;
  id dataSource;
}

@property IBOutlet id dataSource;

// public
- (void) startMonitoring;
- (void) restartMonitoring;
- (void) executeFetch;

@end
