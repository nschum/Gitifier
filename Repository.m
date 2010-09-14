// -------------------------------------------------------
// Repository.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Repository.h"

static NSString *urlRegexp = @"(git|ssh|http|https|ftp|ftps|rsync):\\/\\/\\S+";

@implementation Repository

@synthesize url;

- (id) initWithUrl: (NSString *) anUrl {
  self = [super init];
  if ([self isProperUrl: anUrl]) {
    url = anUrl;
    return self;
  } else {
    return nil;
  }
}

- (BOOL) isProperUrl: (NSString *) anUrl {
  NSPredicate *regexp = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", urlRegexp];
  return [regexp evaluateWithObject: anUrl];
}

@end
