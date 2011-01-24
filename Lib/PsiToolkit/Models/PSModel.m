// -------------------------------------------------------
// PSModel.m
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#ifdef PSITOOLKIT_ENABLE_MODELS

#import "PSModel.h"
#import "PSModelManager.h"
#import "PSMacros.h"
#import "PSFoundationExtensions.h"

@interface PSModel ()
+ (NSArray *) properties;
+ (NSMutableArray *) mutableList;
+ (NSMutableDictionary *) identityMap;
+ (NSString *) collectionElementsCount: (id) collection;
@end

@implementation PSModel

PSReleaseOnDealloc(numericRecordId);

// -------------------------------------------------------------------------------------------
#pragma mark Overridable methods

// e.g. activityType => ActivityType, can be overridden to e.g. add a prefix (ZXActivityType)
+ (NSString *) classNameForProperty: (NSString *) property {
  return [property psStringWithUppercaseFirstLetter];
}

// e.g. ZXActivityType => activity_types
+ (NSString *) routeName {
  NSString *name = NSStringFromClass(self);
  NSString *head = [name substringToIndex: 1];
  NSString *tail = [name substringFromIndex: 1];
  NSString *propertyForm = [[head lowercaseString] stringByAppendingString: tail];
  return [[propertyForm psUnderscoreSeparatedString] psPluralizedString];
}

// e.g. PSArray(@"name", @"telephoneMain", @"address")
+ (NSArray *) propertyList {
  return [NSArray array];
}

// change only if you want a custom record id field
+ (NSString *) recordIdProperty {
  return @"numericRecordId";
}

// -------------------------------------------------------------------------------------------
#pragma mark Creating from JSON

#ifdef PSITOOLKIT_ENABLE_MODELS_JSON

+ (id) valueFromJSONString: (NSString *) jsonString {
  #if defined(PSITOOLKIT_USE_YAJL)
    return [jsonString yajl_JSON];
  #elif defined(PSITOOLKIT_USE_JSON_FRAMEWORK)
    return [jsonString JSONValue];
  #elif defined(PSITOOLKIT_USE_TOUCHJSON)
    static CJSONDeserializer *deserializer;
    if (!deserializer) {
      deserializer = [[CJSONDeserializer deserializer] retain];
    }
    NSData *jsonData = [jsonString dataUsingEncoding: NSUTF32BigEndianStringEncoding];
    return [deserializer deserialize: jsonData error: nil];
  #elif defined(PSITOOLKIT_USE_JSONKIT)
    return [jsonString objectFromJSONString];
  #endif
}

+ (id) objectFromJSONString: (NSString *) jsonString {
  NSDictionary *record = [self valueFromJSONString: jsonString];
  return [self objectFromJSON: record];
}

+ (NSArray *) objectsFromJSONString: (NSString *) jsonString {
  NSArray *records = [self valueFromJSONString: jsonString];
  return [self objectsFromJSON: records];
}

#endif // ifdef PSITOOLKIT_ENABLE_MODELS_JSON

+ (id) objectFromJSON: (NSDictionary *) json {
  if ([json isKindOfClass: [PSModel class]]) {
    return [[json copy] autorelease];
  } else {
    PSModel *object = [[self alloc] init];
    [object copyFieldsFrom: json skipNullValues: YES];
    return [object autorelease];
  }
}

+ (NSArray *) objectsFromJSON: (NSArray *) jsonArray {
  return [self psArrayByCalling: @selector(objectFromJSON:) withObjectsFrom: jsonArray];
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

+ (id) objectWithId: (id) objectId {
  return [[self identityMap] objectForKey: objectId];
}

+ (id) objectWithIntegerId: (NSInteger) objectId {
  return [self objectWithId: PSInt(objectId)];
}

+ (id) objectWithId: (id) objectId context: (id) context {
  // override in subclasses to provide a different lookup, e.g. within a scope of another object
  return [self objectWithId: objectId];
}

+ (void) insertObjects: (NSArray *) objects atPosition: (NSInteger) position {
  NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(position, objects.count)];
  [self willChange: NSKeyValueChangeInsertion valuesAtIndexes: indexes forKey: @"list"];
  [[self mutableList] insertObjects: objects atIndexes: indexes];
  [self didChange: NSKeyValueChangeInsertion valuesAtIndexes: indexes forKey: @"list"];

  NSMutableDictionary *identityMap = [self identityMap];
  for (id object in objects) {
    id recordId = [object recordId];
    NSAssert1(recordId != nil, @"Can't add object with no recordId to list: %@", object);
    [identityMap setObject: object forKey: recordId];
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
    properties = [self propertyList];
    if (![properties containsObject: [self recordIdProperty]]) {
      properties = [properties arrayByAddingObject: [self recordIdProperty]];
    }
    [[self modelManager] setPropertyList: properties];
  }
  return properties;
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) removeObjectFromList {
  NSMutableArray *list = [[self class] mutableList];
  NSMutableDictionary *map = [[self class] identityMap];
  NSUInteger position = [list indexOfObject: self];

  if (position != NSNotFound) {
    [[self retain] autorelease];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex: position];
    [[self class] willChange: NSKeyValueChangeRemoval valuesAtIndexes: indexes forKey: @"list"];
    [list removeObjectAtIndex: position];
    [[self class] didChange: NSKeyValueChangeRemoval valuesAtIndexes: indexes forKey: @"list"];
    [map removeObjectForKey: [self recordId]];
  }
}

- (void) copyFieldsFromDictionary: (NSDictionary *) json
                      onlyMissing: (BOOL) onlyMissing
                   skipNullValues: (BOOL) skipNullValues {
  NSArray *properties = [[self class] properties];
  NSString *property;
  id value;

  // set all properties
  for (NSString *key in [json allKeys]) {
    property = nil;
    value = [json objectForKey: key];
    if (skipNullValues && [value isEqual: PSNull]) {
      continue;
    }

    if ([key hasSuffix: @"_id"]) {
      // for names ending with _id, find an associated object in another PSModel
      property = [[key substringToIndex: key.length - 3] psCamelizedString];
      Class targetClass = NSClassFromString([[self class] classNameForProperty: property]);
      if ([targetClass isSubclassOfClass: [PSModel class]]) {
        value = [targetClass objectWithId: value context: json];
      } else {
        continue;
      }
    } else {
      // for other names, assign the value as is to a correct property
      if ([key isEqual: @"id"]) {
        // 'id' is saved as 'recordId'
        property = [[self class] recordIdProperty];
      } else if ([key hasSuffix: @"?"]) {
        // 'foo?' is saved as 'foo'
        property = [[key substringToIndex: key.length - 1] psCamelizedString];
      } else {
        // normal property
        property = [key psCamelizedString];
      }
    }

    if ([properties containsObject: property]) {
      if (!value) {
        value = PSNull;
      }

      if (onlyMissing && [self valueForKey: property]) {
        continue;
      } else if (skipNullValues && [value isEqual: PSNull]) {
        continue;
      } else {
        [self setValue: value forKey: property];
      }
    }
  }
}

- (void) copyFieldsFromObject: (id) object
                  onlyMissing: (BOOL) onlyMissing
               skipNullValues: (BOOL) skipNullValues {
  for (NSString *property in [[self class] properties]) {
    id newValue = [object valueForKey: property];
    id oldValue = [self valueForKey: property];

    if ((onlyMissing && oldValue) || (skipNullValues && !newValue)) {
      continue;
    } else {
      [self setValue: newValue forKey: property];
    }
  }
}

- (void) copyFieldsFrom: (id) object skipNullValues: (BOOL) skipNullValues {
  if ([object isKindOfClass: [NSDictionary class]]) {
    [self copyFieldsFromDictionary: object onlyMissing: NO skipNullValues: skipNullValues];
  } else {
    [self copyFieldsFromObject: object onlyMissing: NO skipNullValues: skipNullValues];
  }
}

- (void) copyMissingFieldsFrom: (id) object {
  if ([object isKindOfClass: [NSDictionary class]]) {
    [self copyFieldsFromDictionary: object onlyMissing: YES skipNullValues: YES];
  } else {
    [self copyFieldsFromObject: object onlyMissing: YES skipNullValues: YES];
  }
}

- (id) copyWithZone: (NSZone *) zone {
  id other = [[[self class] alloc] init];
  [other copyFieldsFrom: self skipNullValues: YES];
  return other;
}

- (BOOL) isEqual: (id) other {
  if ([other isKindOfClass: [self class]]) {
    return [[other recordId] isEqual: [self recordId]];
  } else {
    return false;
  }
}

- (NSUInteger) hash {
  return [[self recordId] hash];
}

- (id) recordId {
  return [self valueForKey: [[self class] recordIdProperty]];
}

- (void) setRecordId: (id) newId {
  [self setValue: newId forKey: [[self class] recordIdProperty]];
}

- (NSInteger) recordIdValue {
  return [[self recordId] intValue];
}

- (NSString *) toParam {
  return [[self recordId] description];
}

- (NSString *) description {
  NSMutableString *result = [[NSMutableString alloc] initWithString: @"<"];
  [result appendString: NSStringFromClass([self class])];
  [result appendFormat: @": 0x%x", self];

  NSArray *fields = [PSArray(@"recordId") arrayByAddingObjectsFromArray: [[self class] propertyList]];
  id value, output;

  for (NSString *property in fields) {
    value = [self valueForKey: property];

    if ([value isKindOfClass: [NSString class]]) {
      output = PSFormat(@"\"%@\"", value);
    } else if ([value isKindOfClass: [NSArray class]]) {
      output = PSFormat(@"[%@]", [PSModel collectionElementsCount: value]);
    } else if ([value isKindOfClass: [NSDictionary class]]) {
      output = PSFormat(@"{%@}", [PSModel collectionElementsCount: value]);
    } else if ([value isKindOfClass: [PSModel class]]) {
      output = PSFormat(@"<%@: 0x%x, recordId=%@>", NSStringFromClass([value class]), value, [value recordId]);
    } else {
      output = value;
    }

    [result appendFormat: @", %@=%@", property, output];
  }

  [result appendString: @">"];
  return [result autorelease];
}

- (NSString *) encodeToPostData {
  [self doesNotRecognizeSelector: _cmd];
  return nil;
}

+ (NSString *) collectionElementsCount: (id) collection {
  NSInteger count = [collection count];
  switch (count) {
    case 0: return @"";
    case 1: return @"1 element";
    default: return PSFormat(@"%d elements", count);
  }
}

@end

#endif
