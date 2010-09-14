// -------------------------------------------------------
// PSModel.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

#define PSModelRecordId @"recordId"

@interface PSModel : NSObject <NSCopying> {
  NSNumber *recordId;
}

@property (nonatomic, copy) NSNumber *recordId;
@property (nonatomic, readonly) NSInteger recordIdValue;

+ (NSString *) classNameForProperty: (NSString *) property;
+ (NSArray *) propertyList;

+ (id) objectFromJSON: (NSDictionary *) json;
+ (id) objectFromJSONString: (NSString *) jsonString;
+ (NSArray *) objectsFromJSON: (NSArray *) jsonArray;
+ (NSArray *) objectsFromJSONString: (NSString *) jsonString;

+ (void) appendObjectsToList: (NSArray *) objects;
+ (void) prependObjectsToList: (NSArray *) objects;
+ (id) objectWithId: (NSNumber *) objectId;
+ (id) objectWithIntegerId: (NSInteger) objectId;
+ (NSInteger) count;
+ (NSArray *) list;
+ (void) reset;

- (BOOL) isEqual: (id) other;

@end
