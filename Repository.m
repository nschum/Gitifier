// -------------------------------------------------------
// Repository.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Repository.h"

@implementation Repository

@synthesize url;

- (id) initWithUrl: (NSString *) anUrl {
  self = [super init];
  if (self) {
    url = anUrl;
  }
  return self;
}

@end
