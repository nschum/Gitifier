// -------------------------------------------------------
// Monitor.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
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
- (void) timerFired;

@end
