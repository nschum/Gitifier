// -------------------------------------------------------
// PSIntArray.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  Array of integers (or enums) that don't need to be wrapped in NSNumber, similar to NSArray.

  Usage:
      PSIntArray *arr = PSIntegers(4, 8, 15, 16, 23, 42);
      NSLog(@"%d", arr.count);
      NSLog(@"%d", [arr integerAtIndex: 3]);
*/

#import <Foundation/Foundation.h>

#define PSIntArrayStop NSIntegerMin
#define PSIntegers(...)   [PSIntArray arrayWithIntegers: __VA_ARGS__, PSIntArrayStop]

@interface PSIntArray : NSObject {
  NSInteger *values;
  NSInteger count;
}

@property (nonatomic, readonly) NSInteger count;

+ (PSIntArray *) arrayWithIntegers: (NSInteger) first, ...;
+ (PSIntArray *) emptyArray;

- (id) initWithCapacity: (NSInteger) capacity;
- (void) setInteger: (NSInteger) value atIndex: (NSInteger) index;
- (NSInteger) integerAtIndex: (NSInteger) index;

@end
