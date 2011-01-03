// -------------------------------------------------------
// PSResponse.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  Helper class that wraps some of the PSRequest's fields - accessible as request.response.
*/

#import <Foundation/Foundation.h>

@class PSRequest;

@interface PSResponse : NSObject {
  PSRequest *request;
}

@property (nonatomic, readonly) NSString *contentType;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSDictionary *headers;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSInteger status;

- (id) initWithRequest: (PSRequest *) request;

// tells if the response is (probably) human-readable
- (BOOL) hasReadableContentType;

// tells if the returned content type matches what the request expected (as set in expectedContentType)
- (BOOL) matchesExpectedContentType;

@end
