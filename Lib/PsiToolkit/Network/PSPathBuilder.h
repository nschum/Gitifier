// -------------------------------------------------------
// PSPathBuilder.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  Helper for building paths with parameters. Used internally by PSRequest, but can also be used by itself.

  Usage:
      PSPathBuilder *builder = [PSPathBuilder builderWithBasePath: @"/messages"];
      if (last) {
        [builder addParameterWithName: @"since" integerValue: last];
      } else {
        [builder addParameterWithName: @"limit" integerValue: 20];
      }
      [builder addParameterWithName: @"include" value: @"author"];

      NSLog(@"%@", [builder path]);  // e.g. /messages?since=123&include=author
*/

#import <Foundation/Foundation.h>

@interface PSPathBuilder : NSObject {
  NSMutableString *fullPath;
  BOOL hasParams;
}

// returns full path with all parameters added
@property (nonatomic, readonly) NSString *path;

+ (PSPathBuilder *) builderWithBasePath: (NSString *) path;
- (id) initWithBasePath: (NSString *) path;

- (void) addParameterWithName: (NSString *) param value: (id) value;
- (void) addParameterWithName: (NSString *) param integerValue: (NSInteger) value;

@end
