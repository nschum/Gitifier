// -------------------------------------------------------
// Monitor.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Defaults.h"
#import "Monitor.h"
#import "Repository.h"

@implementation Monitor

@synthesize dataSource;

- (NSString *) monitorKeyPath {
  return PSFormat(@"values.%@", MONITOR_INTERVAL_KEY);
}

- (void) awakeFromNib {
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  [defaultsController addObserver: self
                       forKeyPath: [self monitorKeyPath]
                          options: 0
                          context: nil];
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

- (void) timerFired {
  NSArray *repositories = [[dataSource repositoryList] copy];
  [repositories makeObjectsPerformSelector: @selector(fetchNewCommits)];
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context {
  if ([keyPath isEqual: [self monitorKeyPath]]) {
    [self stopMonitoring];
    [self startMonitoring];
  }
}

@end
