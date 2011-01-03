// -------------------------------------------------------
// PSPathBuilder.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#ifdef PSITOOLKIT_ENABLE_NETWORK

#import "PSPathBuilder.h"

@implementation PSPathBuilder

+ (PSPathBuilder *) builderWithBasePath: (NSString *) path {
  PSPathBuilder *builder = [[PSPathBuilder alloc] initWithBasePath: path];
  return [builder autorelease];
}

- (id) initWithBasePath: (NSString *) path {
  self = [super init];
  if (self) {
    fullPath = [[NSMutableString alloc] initWithString: path];
    hasParams = [fullPath psContainsString: @"?"];
  }
  return self;
}

- (void) addParameterWithName: (NSString *) name value: (id) value {
  [fullPath appendString: (hasParams ? @"&" : @"?")];
  [fullPath appendString: PSFormat(@"%@=%@", name, [value description])];
  hasParams = YES;
}

- (void) addParameterWithName: (NSString *) name integerValue: (NSInteger) value {
  [self addParameterWithName: name value: PSInt(value)];
}

- (NSString *) path {
  return fullPath;
}

@end

#endif
