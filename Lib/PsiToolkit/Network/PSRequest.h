// -------------------------------------------------------
// PSRequest.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  Subclass of ASIHTTPRequest that adds some useful features. You shouldn't need to subclass it,
  and you should only create instances using PSConnector's helper methods.
*/

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

// defines what kind of content types are expected in response - PSConnector checks if the content type is correct
typedef enum {
  PSAnyResponseType,       // matches any content type
  PSHTMLResponseType,      // matches html and xhtml
  PSImageResponseType,     // matches images - connector will parse the response as NSImage/UIImage
  PSImageDataResponseType, // as above, but connector will return NSData
  PSJSONResponseType,      // matches JSON responses - connector will return parsed JSON (default option)
  PSXMLResponseType,       // matches XML responses
  PSBinaryResponseType     // matches anything binary (i.e. not text)
}
PSResponseContentType;

@class PSConnector, PSModel, PSResponse, PSPathBuilder;

@interface PSRequest : ASIHTTPRequest {
  PSConnector *connector;
  id target;
  SEL callback;
  SEL successHandler;
  PSResponseContentType expectedContentType;
  PSResponse *response;
  PSPathBuilder *pathBuilder;
}

// object and its method that should be called on success, don't use directly
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL callback;

// method in connector that will process the response before it notifies the target
// by default it calls 'handleFinishedRequest:' which tries to parse the response and sends result to the callback
@property (nonatomic, assign) SEL successHandler;

// use this to add text that will be sent as POST data
@property (nonatomic, copy) NSString *postData;

// used by PSConnector for content type validation and for response parsing
@property (nonatomic, assign) PSResponseContentType expectedContentType;

// returns the PSResponse that wraps request's response data
@property (nonatomic, readonly) PSResponse *response;


// don't use directly
- (id) initWithURL: (NSString *) url connector: (PSConnector *) aConnector;

// appends a key=value parameter to the request's path (uses PSPathBuilder internally)
- (void) addURLParameter: (NSString *) param value: (id) value;
- (void) addURLParameter: (NSString *) param integerValue: (NSInteger) value;

// send the request, setting target and callback
- (void) sendFor: (id) target callback: (SEL) callback;

// send the request without target - no one will be notified of results
- (void) send;

// returns an object that was set earlier in request's userInfo dictionary under 'key'
- (id) objectForKey: (NSString *) key;

// calls the target's callback method with nil argument
- (void) notifyTargetOfSuccess;

// calls the target's callback method with given argument
- (void) notifyTargetOfSuccessWithObject: (id) object;

// calls the target's requestFailed:withError: method
- (void) notifyTargetOfError: (NSError *) error;

// calls the target's authenticationFailedInRequest: method
- (void) notifyTargetOfAuthenticationError;

@end
