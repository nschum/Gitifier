// -------------------------------------------------------
// PSModelManager.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  Class storage helper used internally by PSModel. Nothing interesting here, move along.
*/

#import <Foundation/Foundation.h>

@interface PSModelManager : NSObject {
  NSMutableArray *list;
  NSMutableDictionary *identityMap;
  NSArray *propertyList;
}

@property (nonatomic, readonly) NSMutableArray *list;
@property (nonatomic, readonly) NSMutableDictionary *identityMap;
@property (nonatomic, copy) NSArray *propertyList;

+ (PSModelManager *) managerForClass: (NSString *) className;

@end
