// -------------------------------------------------------
// PSPathBuilder.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import "PSPathBuilder.h"
#import "PSMacros.h"
#import "PSModel.h"

@interface PSPathBuilder ()
- (id) initWithBasePath: (NSString *) path;
@end

@implementation PSPathBuilder

+ (PSPathBuilder *) builderWithBasePath: (NSString *) path record: (PSModel *) record {
  NSString *basePath = PSFormat(path, record.recordIdValue);
  PSPathBuilder *builder = [[PSPathBuilder alloc] initWithBasePath: basePath];
  return [builder autorelease];
}

+ (PSPathBuilder *) builderWithBasePath: (NSString *) path {
  PSPathBuilder *builder = [[PSPathBuilder alloc] initWithBasePath: path];
  return [builder autorelease];
}

- (id) initWithBasePath: (NSString *) path {
  self = [super init];
  if (self) {
    fullPath = [[NSMutableString alloc] initWithString: path];
    hasParams = NO;
  }
  return self;
}

- (void) setObject: (id) value forKey: (NSString *) key {
  [fullPath appendString: (hasParams ? @"&" : @"?")];
  [fullPath appendString: PSFormat(@"%@=%@", key, [value description])];
  hasParams = YES;
}

- (void) setInt: (NSInteger) number forKey: (NSString *) key {
  [self setObject: PSInt(number) forKey: key];
}

- (NSString *) path {
  return fullPath;
}

@end
