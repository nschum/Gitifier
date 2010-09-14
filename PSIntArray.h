// -------------------------------------------------------
// PSIntArray.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

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
