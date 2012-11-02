// -------------------------------------------------------
// PSIntArray.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "PSIntArray.h"
#import "PSMacros.h"

@implementation PSIntArray

@synthesize count;

+ (PSIntArray *) arrayWithIntegers: (NSInteger) first, ... {
  if (first == PSIntArrayStop) {
    return [[PSIntArray alloc] initWithCapacity: 0];
  } else {
    NSMutableArray *nsarray = [[NSMutableArray alloc] init];
    [nsarray addObject: PSInt(first)];
    va_list args;
    va_start(args, first);
    NSInteger next;
    for (;;) {
      next = va_arg(args, NSInteger);
      if (next == PSIntArrayStop) {
        break;
      }
      [nsarray addObject: PSInt(next)];
    }
    va_end(args);

    PSIntArray *array = [[PSIntArray alloc] initWithCapacity: nsarray.count];
    for (NSInteger i = 0; i < nsarray.count; i++) {
      [array setInteger: [[nsarray objectAtIndex: i] intValue] atIndex: i];
    }
    return array;
  }
}

+ (PSIntArray *) emptyArray {
  return [PSIntArray arrayWithIntegers: PSIntArrayStop];
}

- (id) initWithCapacity: (NSInteger) capacity {
  self = [super init];
  if (self) {
    values = malloc(sizeof(NSInteger) * capacity);
    count = capacity;
  }
  return self;
}

- (void) setInteger: (NSInteger) value atIndex: (NSInteger) index {
  if (index >= 0 && index < count) {
    values[index] = value;
  } else {
    NSString *reason = PSFormat(@"Index outside range (index = %d, count = %d)", index, count);
    NSException *exception = [NSException exceptionWithName: NSRangeException reason: reason userInfo: nil];
    @throw(exception);
  }
}

- (NSInteger) integerAtIndex: (NSInteger) index {
  if (index >= 0 && index < count) {
    return values[index];
  } else {
    NSString *reason = PSFormat(@"Index outside range (index = %d, count = %d)", index, count);
    NSException *exception = [NSException exceptionWithName: NSRangeException reason: reason userInfo: nil];
    @throw(exception);
  }
}

@end
