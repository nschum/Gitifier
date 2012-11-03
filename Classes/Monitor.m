// -------------------------------------------------------
// Monitor.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Defaults.h"
#import "Monitor.h"
#import "Repository.h"

@implementation Monitor {
  NSTimer *timer;
}

- (void) awakeFromNib {
  ObserveDefaults(MonitorIntervalKey);
}

- (void) startMonitoring {
  if (!timer) {
    NSInteger interval = [GitifierDefaults integerForKey: MonitorIntervalKey];
    timer = [NSTimer scheduledTimerWithTimeInterval: (interval * 60)
                                             target: self
                                           selector: @selector(timerFired)
                                           userInfo: nil
                                            repeats: YES];
  }
}

- (void) stopMonitoring {
  [timer invalidate];
  timer = nil;
}

- (void) restartMonitoring {
  [self stopMonitoring];
  [self startMonitoring];
}

- (void) executeFetch {
  NSArray *repositories = [[self.dataSource repositoryList] copy];
  [repositories makeObjectsPerformSelector: @selector(fetchNewCommits)];
}

- (void) timerFired {
  [self executeFetch];
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context {
  if (timer && [[keyPath lastKeyPathElement] isEqual: MonitorIntervalKey]) {
    [self restartMonitoring];
  }
}

@end
