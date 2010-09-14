// -------------------------------------------------------
// PSPathBuilder.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class PSModel;

@interface PSPathBuilder : NSObject {
  NSMutableString *fullPath;
  BOOL hasParams;
}

@property (nonatomic, readonly) NSString *path;

// substitutes %d for record's id
+ (PSPathBuilder *) builderWithBasePath: (NSString *) path record: (PSModel *) record;
+ (PSPathBuilder *) builderWithBasePath: (NSString *) path;

- (void) setObject: (id) value forKey: (NSString *) key;
- (void) setInt: (NSInteger) number forKey: (NSString *) key;

@end
