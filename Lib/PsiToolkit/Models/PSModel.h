// -------------------------------------------------------
// PSModel.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  Base model class. Provides methods for building models from JSON dictionaries and strings, and keeps a global
  collection/map of records that can be accessed from anywhere.
  Important methods to override: 'propertyList', and 'encodeToPostData' if you send records in POST requests.

  Usage:
      NSArray *messages = [Message objectsFromJSONString: response];
      [Message appendObjectsToList: messages];

      NSLog(@"%d", [Message count]);
      NSLog(@"%@", [Message list]);
      NSLog(@"%@", [Message objectWithIntegerId: 2011]);

  You can use this macro to quickly define @synthesize and propertyList() class method for your properties:
      PSModelProperties(name, surname, address);
*/

#import <Foundation/Foundation.h>

@interface PSModel : NSObject <NSCopying> {
  NSNumber *numericRecordId;
}

// recordId is the record's unique id. It's taken from 'id' field in JSON data ('id' is a reserved word in ObjC).
// If you want to use a different field (e.g. NSString *name) as unique id, override 'recordIdProperty'.
@property (nonatomic, copy) id recordId;
@property (nonatomic, readonly) NSInteger recordIdValue;


/* overridable class methods */

// name of the class matching property name, if it's not 'SomeProperty' for 'someProperty'
// (e.g. if you need to add a prefix). This is used for to-one relationships.
+ (NSString *) classNameForProperty: (NSString *) property;

// model name used in REST-style routing, default is e.g. Article -> 'articles'
+ (NSString *) routeName;

// list of fields managed by the model; fields not listed here will be ignored
+ (NSArray *) propertyList;

// name of the property that acts as a unique id, if it's different from the default
+ (NSString *) recordIdProperty;


/* record building */

// builds a PSModel object from a JSON dictionary
+ (id) objectFromJSON: (NSDictionary *) json;

// builds a NSArray of PSModel objects from a NSArray of JSON dictionaries
+ (NSArray *) objectsFromJSON: (NSArray *) jsonArray;


/* global list management */

// adds objects from the array to the global list
+ (void) appendObjectsToList: (NSArray *) objects;
+ (void) prependObjectsToList: (NSArray *) objects;

// looks up a record in the global list by id; the context variant is used during record building
+ (id) objectWithId: (id) objectId;
+ (id) objectWithId: (id) objectId context: (id) context;
+ (id) objectWithIntegerId: (NSInteger) objectId;

// returns number of objects in the global list
+ (NSInteger) count;

// returns all objects in the global list
+ (NSArray *) list;

// clears the global list
+ (void) reset;


/* instance methods */

// removes object from the global list
- (void) removeObjectFromList;

// tells if two objects are the same (compares only the record id)
- (BOOL) isEqual: (id) other;

// tells how the record is displayed in routes (by default returns record id)
- (NSString *) toParam;

// used by [record copy] - copies all registered fields to the new record (shallow copy)
- (id) copyWithZone: (NSZone *) zone;

// copies all fields from a given PSModel or NSDictionary to this record; skipNullValues = only copy if not nil
- (void) copyFieldsFrom: (id) object skipNullValues: (BOOL) skipNullValues;

// copies all fields from a given PSModel or NSDictionary to this record, but only if they aren't already set
- (void) copyMissingFieldsFrom: (id) object;

// string representation - prints all properties with names and values
- (NSString *) description;

// abstract method - implement in subclasses if you want to use *RequestForObject helpers in PSConnector
// (NSString's method psStringWithFormEncodedFields:ofModelNamed: might be useful)
- (NSString *) encodeToPostData;

@end
