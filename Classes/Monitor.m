// -------------------------------------------------------
// Monitor.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Defaults.h"
#import "Monitor.h"
#import "Repository.h"

@implementation Monitor

@synthesize dataSource;

- (void) awakeFromNib {
  ObserveDefaults(MONITOR_INTERVAL_KEY);
}

- (void) startMonitoring {
  if (!timer) {
    NSInteger interval = [GitifierDefaults integerForKey: MONITOR_INTERVAL_KEY];
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
  NSArray *repositories = [[dataSource repositoryList] copy];
  [repositories makeObjectsPerformSelector: @selector(fetchNewCommits)];
}

- (void) timerFired {
  [self executeFetch];
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context {
  if (timer && [[keyPath lastKeyPathElement] isEqual: MONITOR_INTERVAL_KEY]) {
    [self restartMonitoring];
  }
}

@end
