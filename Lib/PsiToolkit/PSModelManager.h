// -------------------------------------------------------
// PSModelManager.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

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
