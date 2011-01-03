// -------------------------------------------------------
// PSConnector.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  The heart of the network module. Use this as the superclass for your own backend class that connects to a server.

  Your connector will probably need:
  - an init method that sets some general properties
  - prepareRequest method that sets request properties like HTTP headers
  - methods for generating various PSRequests
  - methods that handle those requests when they return
  - optionally, overridden methods like checkResponseForErrors, handleFailedRequest or handleFailedAuthentication

  Usage:
      MyConnector *connector = [[MyConnector alloc] init...];
      connector.account = [PSAccount accountFromSettings];
      [PSConnector setSharedConnector: connector];
      // or:
      [PSConnector setSharedConnectorClass: [MyConnector class]];

      // in init:
      self.baseURL = @"http://api.server.com";
      self.userAgent = @"ServerDestroyer/1.0";
      self.usesHTTPAuthentication = YES;

      // method prepareRequest:
      request.timeOutSeconds = 30;
      request.expectedContentType = PSXMLResponseType;
      [request addRequestHeader: @"X-API-Version" value: @"1.0"];

      // method updateFooRequestWithFoo:
      PSRequest *request = [self requestToPath: PSFormat(@"/foos/%d", foo.recordId) method: PSPutMethod];
      request.postData = [foo encodeToPostData];
      request.successHandler = @selector(fooUpdated:);
      request.userInfo = PSHash(@"object", foo);
      return request;

      // or using CRUD helpers:
      PSRequest *request = [self updateRequestForObject: foo];
      request.successHandler = @selector(fooUpdated:);
      return request;

      // method fooUpdated:
      Foo *newFoo = [self parseObjectFromRequest: request model: [Foo class]];
      if (newFoo) {
        // if parsed response is nil, stop processing
        Foo *oldFoo = [request objectAtKey: @"object"];
        oldFoo.updatedAt = newFoo.updatedAt;
        [request notifyTargetOfSuccessWithObject: oldFoo];
      }

      // in view controller:
      [[connector updateFooRequestWithFoo: foo] sendFor: self callback: @selector(fooWasUpdated:)];
      // on success, method fooWasUpdated: will be called with a Foo in argument

      // if you're fine with whatever parseResponseFromRequest returns (e.g. HTML or JSON dictionary)
      // or you don't need the response text at all, you can use the default successHandler, get rid of
      // both 'updateFooRequestWithFoo:' and 'fooUpdated:' in the connector and use a CRUD helper directly:
      [[connector updateRequestForObject: foo] sendFor: self callback: @selector(fooWasUpdated)];
*/

#import <Foundation/Foundation.h>
#import "PSConnectorAccount.h"
#import "PSRequest.h"
#import "PSRouter.h"

@class PSModel;

@interface PSConnector : NSObject {
  NSString *baseURL;
  NSString *userAgent;
  NSMutableArray *currentRequests;
  id account;
  id router;
  BOOL usesHTTPAuthentication;
  BOOL loggingEnabled;
}

// URL that is the base for all requests; set the field once or override the getter if URL isn't constant
@property (nonatomic, copy) NSString *baseURL;

// user agent - if not set, ASIHTTPRequest will build something reasonable automatically
@property (nonatomic, copy) NSString *userAgent;

// router used for CRUD helper methods - uses PSRestRouter by default
@property (nonatomic, retain) id router;

// account used for HTTP authentication
@property (nonatomic, retain) id account;

// if this is set and account is not null, account's username and password will be sent as HTTP auth
@property (nonatomic, assign) BOOL usesHTTPAuthentication;

// tells if info about sent requests and received responses should be printed with NSLog
// by default it's true if DEBUG is defined (see PSLog in PSMacros.h for more info)
@property (nonatomic, assign) BOOL loggingEnabled;


/* creating the connector */

// returns a singleton instance of the connector
+ (id) sharedConnector;

// sets the singleton instance
+ (void) setSharedConnector: (PSConnector *) connector;

// sets the singleton instance to a new object of the given class
+ (void) setSharedConnectorClass: (Class) klass;

// creates a new connector
- (id) init;
- (id) initWithBaseURL: (NSString *) url;


/* creating requests */

// empty method, called on all requests before sending - override to add headers, set timeout etc.
- (void) prepareRequest: (PSRequest *) request;

// creates a new request; 'path' version appends the path to the base URL, and default method is GET
- (PSRequest *) requestToPath: (NSString *) path;
- (PSRequest *) requestToURL: (NSString *) url;
- (PSRequest *) requestToPath: (NSString *) path method: (NSString *) method;
- (PSRequest *) requestToURL: (NSString *) url method: (NSString *) method;

// CRUD helpers - path is determined by the router, method is set according to REST rules,
// POST data is set to record's encodeToPostData (for create and update),
// and object is stored in request's userInfo under 'object' key
#ifdef PSITOOLKIT_ENABLE_MODELS
- (PSRequest *) createRequestForObject: (PSModel *) object;
- (PSRequest *) showRequestForObject: (PSModel *) object;
- (PSRequest *) updateRequestForObject: (PSModel *) object;
- (PSRequest *) deleteRequestForObject: (PSModel *) object;
#endif


/* handling responses */

// default response handler, used if request's successHandler isn't set;
// parses the response, and if it's correct, calls the callback on the target passing the response
- (void) handleFinishedRequest: (PSRequest *) request;

// handler for failed requests - notifies target of error; override if you need different error handling
- (void) handleFailedRequest: (PSRequest *) request;

// handler for failed authentication - notifies target of auth error; override if you need different error handling
- (void) handleFailedAuthentication: (PSRequest *) request;

// checks if the response has correct status and content type; if not, sets request.error to some kind of NSError.
// If you need additional checks, override this method, call super, and set request.error if something is wrong
- (void) checkResponseForErrors: (PSRequest *) request;

// returns response as string, NSData, image, JSON dictionary, or array of dictionaries, depending of content type;
// NSNull result means an empty response, and nil means JSON parsing error that was passed to 'handleFailedRequest'.
// (if JSON library is not available, JSON responses will just return a string)
- (id) parseResponseFromRequest: (PSRequest *) request;

#ifdef PSITOOLKIT_ENABLE_MODELS_JSON
// like parseResponseFromRequest, but builds a PSModel object instead of just returning a dictionary
- (id) parseObjectFromRequest: (PSRequest *) request model: (Class) klass;

// like parseResponseFromRequest, but builds an array of PSModel objects
- (NSArray *) parseObjectsFromRequest: (PSRequest *) request model: (Class) klass;
#endif

// called on all requests after they return;
// override and call super if you need to do something special to all requests
- (void) cleanupRequest: (PSRequest *) request;


/* other methods */

// cancels all requests that are currently in progress
- (void) cancelAllRequests;

// prints string to NSLog if loggingEnabled is YES
- (void) log: (NSString *) text;

@end
