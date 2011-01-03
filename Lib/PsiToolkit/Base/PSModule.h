// -------------------------------------------------------
// PSModule.h
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface PSModule : NSObject {}

+ (NSArray *) moduleInstanceMethods;
+ (void) copyMethod: (SEL) selector toClass: (Class) aClass;
+ (void) extendClass: (Class) aClass;

@end
