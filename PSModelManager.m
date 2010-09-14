// -------------------------------------------------------
// PSModelManager.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import "PSModelManager.h"

static NSMutableDictionary *managers;

@implementation PSModelManager

@synthesize list, identityMap, propertyList;

- (id) init {
  self = [super init];
  if (self) {
    list = [[NSMutableArray alloc] initWithCapacity: 100];
    identityMap = [[NSMutableDictionary alloc] initWithCapacity: 100];
  }
  return self;
}

+ (void) initialize {
  managers = [[NSMutableDictionary alloc] initWithCapacity: 5];
}

+ (PSModelManager *) managerForClass: (NSString *) className {
  PSModelManager *manager = [managers objectForKey: className];
  if (!manager) {
    manager = [[PSModelManager alloc] init];
    [managers setObject: manager forKey: className];
    [manager release];
  }
  return manager;
}

@end
