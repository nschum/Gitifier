// -------------------------------------------------------
// Monitor.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Monitor.h"
#import "Repository.h"

#define MONITOR_INTERVAL 10.0

@implementation Monitor

@synthesize dataSource;

- (void) startMonitoring {
  if (!timer) {
    timer = [NSTimer scheduledTimerWithTimeInterval: MONITOR_INTERVAL
                                             target: self
                                           selector: @selector(timerFired)
                                           userInfo: nil
                                            repeats: YES];
  }
}

- (void) timerFired {
  NSArray *repositories = [[dataSource repositoryList] copy];
  [repositories makeObjectsPerformSelector: @selector(fetchNewCommits)];
}

@end
