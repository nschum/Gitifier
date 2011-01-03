// -------------------------------------------------------
// PSModule.m
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "PSModule.h"
#import "objc/runtime.h"

@implementation PSModule

+ (NSArray *) moduleInstanceMethods {
  return [NSArray array];
}

+ (void) copyMethod: (SEL) selector toClass: (Class) aClass {
  Method method = class_getInstanceMethod(self, selector);
  IMP implementation = method_getImplementation(method);
  const char *argumentTypes = method_getTypeEncoding(method);
  class_addMethod(aClass, selector, implementation, argumentTypes);
}

+ (void) extendClass: (Class) aClass {
  for (NSString *method in [self moduleInstanceMethods]) {
    [self copyMethod: NSSelectorFromString(method) toClass: aClass];
  }
}

@end
