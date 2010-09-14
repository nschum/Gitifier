// -------------------------------------------------------
// PSModel.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import "PSModel.h"
#import "PSModelManager.h"
#import "PSMacros.h"
#import "PSFoundationExtensions.h"

@interface PSModel ()
+ (NSArray *) properties;
+ (NSMutableArray *) mutableList;
+ (NSMutableDictionary *) identityMap;
@end

@implementation PSModel

@synthesize recordId;
PSReleaseOnDealloc(recordId);

// -------------------------------------------------------------------------------------------
#pragma mark Overridable methods

// e.g. activityType => ActivityType, can be overridden to e.g. add a prefix (ZXActivityType)
+ (NSString *) classNameForProperty: (NSString *) property {
  return [property psStringWithUppercaseFirstLetter];
}

// e.g. PSArray(@"name", @"telephoneMain", @"address")
+ (NSArray *) propertyList {
  return [NSArray array];
}

// -------------------------------------------------------------------------------------------
#pragma mark Creating from JSON

+ (id) objectFromJSON: (NSDictionary *) json {
  // create a blank object
  PSModel *object = [[self alloc] init];
  NSArray *properties = [self properties];

  // set all properties
  for (NSString *key in [json allKeys]) {
    id value = [json objectForKey: key];
    NSString *property = nil;
    if (value == nil || [value isEqual: PSNull]) {
      continue;
    }

    if ([key hasSuffix: @"_id"]) {
      // for names ending with _id, find an associated object in another PSModel
      property = [[key substringToIndex: key.length - 3] psCamelizedString];
      Class targetClass = NSClassFromString([self classNameForProperty: property]);
      if ([targetClass isSubclassOfClass: [PSModel class]]) {
        value = [targetClass objectWithId: value];
      } else {
        continue;
      }
    } else {
      // for other names, assign the value as is to a correct property
      if ([key isEqual: @"id"]) {
        // 'id' is saved as 'recordId'
        property = PSModelRecordId;
      } else if ([key hasSuffix: @"?"]) {
        // 'foo?' is saved as 'foo'
        property = [[key substringToIndex: key.length - 1] psCamelizedString];
      } else {
        // normal property
        property = [key psCamelizedString];
      }
    }

    if (value && [properties containsObject: property]) {
      [object setValue: value forKey: property];
    }
  }

  return [object autorelease];
}

+ (id) objectFromJSONString: (NSString *) jsonString {
  NSDictionary *record = [jsonString performSelector: @selector(yajl_JSON)];
  return [self objectFromJSON: record];
}

+ (NSArray *) objectsFromJSON: (NSArray *) jsonArray {
  NSMutableArray *objects = [NSMutableArray arrayWithCapacity: jsonArray.count];
  for (NSDictionary *record in jsonArray) {
    [objects addObject: [self objectFromJSON: record]];
  }
  return objects;
}

+ (NSArray *) objectsFromJSONString: (NSString *) jsonString {
  NSArray *records = [jsonString performSelector: @selector(yajl_JSON)];
  return [self objectsFromJSON: records];
}

// -------------------------------------------------------------------------------------------
#pragma mark Reading and updating global object list and map

+ (PSModelManager *) modelManager {
  return [PSModelManager managerForClass: NSStringFromClass([self class])];
}

+ (void) reset {
  NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, self.list.count)];
  [self willChange: NSKeyValueChangeRemoval valuesAtIndexes: indexes forKey: @"list"];
  [[self mutableList] removeAllObjects];
  [self didChange: NSKeyValueChangeRemoval valuesAtIndexes: indexes forKey: @"list"];
  [[self identityMap] removeAllObjects];
}

+ (id) objectWithId: (NSNumber *) objectId {
  return [[self identityMap] objectForKey: objectId];
}

+ (id) objectWithIntegerId: (NSInteger) objectId {
  return [self objectWithId: PSInt(objectId)];
}

+ (void) insertObjects: (NSArray *) objects atPosition: (NSInteger) position {
  NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(position, objects.count)];
  [self willChange: NSKeyValueChangeInsertion valuesAtIndexes: indexes forKey: @"list"];
  [[self mutableList] insertObjects: objects atIndexes: indexes];
  [self didChange: NSKeyValueChangeInsertion valuesAtIndexes: indexes forKey: @"list"];

  NSMutableDictionary *identityMap = [self identityMap];
  for (id object in objects) {
    [identityMap setObject: object forKey: [object valueForKey: PSModelRecordId]];
  }
}

+ (void) appendObjectsToList: (NSArray *) objects {
  [self insertObjects: objects atPosition: [[self mutableList] count]];
}

+ (void) prependObjectsToList: (NSArray *) objects {
  [self insertObjects: objects atPosition: 0];
}

+ (NSInteger) count {
  return [[self mutableList] count];
}

+ (NSMutableArray *) mutableList {
  return [[self modelManager] list];
}

+ (NSMutableDictionary *) identityMap {
  return [[self modelManager] identityMap];
}

+ (NSArray *) list {
  return [self mutableList];
}

+ (NSArray *) properties {
  NSArray *properties = [[self modelManager] propertyList];
  if (!properties) {
    properties = [[self propertyList] arrayByAddingObject: PSModelRecordId];
    [[self modelManager] setPropertyList: properties];
  }
  return properties;
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (id) copyWithZone: (NSZone *) zone {
  id other = [[[self class] alloc] init];
  for (NSString *property in [[self class] properties]) {
    id value = [self valueForKey: property];
    [other setValue: value forKey: property];
  }
  return other;
}

- (BOOL) isEqual: (id) other {
  if ([other isKindOfClass: [self class]]) {
    id otherRecordId = [other valueForKey: PSModelRecordId];
    id myRecordId = [self valueForKey: PSModelRecordId];
    return [otherRecordId isEqual: myRecordId];
  } else {
    return false;
  }
}

- (NSUInteger) hash {
  return [[self valueForKey: PSModelRecordId] unsignedIntValue];
}

- (NSInteger) recordIdValue {
  return [recordId intValue];
}

@end
