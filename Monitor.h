// -------------------------------------------------------
// Monitor.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@protocol MonitorDelegate
- (NSArray *) repositoryList;
@end

// ------------------------------

@interface Monitor : NSObject {
  NSTimer *timer;
}

@property IBOutlet id delegate;

// public
- (void) startMonitoring;

@end
