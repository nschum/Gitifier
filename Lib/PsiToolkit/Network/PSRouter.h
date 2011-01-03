// -------------------------------------------------------
// PSRouter.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  Defines the minimum requirements for a class to be used as a routing helper in PSConnector
  (used by the CRUD methods ***RequestForObject). Implemented by PSRestRouter.
*/

#import <Foundation/Foundation.h>

@class PSModel;

@protocol PSRouter <NSObject>

- (NSString *) pathForModel: (Class) model;
- (NSString *) pathForObject: (PSModel *) object;

@end
