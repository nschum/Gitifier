// -------------------------------------------------------
// PSRequest.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#ifdef PSITOOLKIT_ENABLE_NETWORK

#import "PSConnectorDelegate.h"
#import "PSRequest.h"
#import "PSResponse.h"

@interface PSRequest ()
- (NSString *) acceptHeaderForContentType: (PSResponseContentType) contentType;
@end

@implementation PSRequest

@synthesize target, callback, expectedContentType, successHandler;
PSReleaseOnDealloc(response, target, pathBuilder);

- (id) initWithURL: (NSString *) aURL connector: (PSConnector *) aConnector {
  self = [super initWithURL: [NSURL URLWithString: aURL]];
  if (self) {
    connector = aConnector;
    successHandler = @selector(handleFinishedRequest:);
    pathBuilder = [[PSPathBuilder alloc] initWithBasePath: aURL];
    self.delegate = aConnector;
  }
  return self;
}

- (void) updatePath {
  [self setURL: [NSURL URLWithString: [pathBuilder path]]];
}

- (void) addURLParameter: (NSString *) param value: (id) value {
  [pathBuilder addParameterWithName: param value: value];
  [self updatePath];
}

- (void) addURLParameter: (NSString *) param integerValue: (NSInteger) value {
  [pathBuilder addParameterWithName: param integerValue: value];
  [self updatePath];
}

- (id) objectForKey: (NSString *) key {
  return [self.userInfo objectForKey: key];
}

- (NSString *) postData {
  return [[[NSString alloc] initWithData: self.postBody encoding: NSUTF8StringEncoding] autorelease];
}

- (void) setPostData: (NSString *) text {
  [self appendPostData: [text dataUsingEncoding: NSUTF8StringEncoding]];
}

- (void) setExpectedContentType: (PSResponseContentType) contentType {
  expectedContentType = contentType;
  [self addRequestHeader: @"Accept" value: [self acceptHeaderForContentType: contentType]];
}

- (NSString *) acceptHeaderForContentType: (PSResponseContentType) contentType {
  switch (contentType) {
    case PSHTMLResponseType:
      return @"text/html,application/xhtml+xml";
    case PSImageResponseType:
    case PSImageDataResponseType:
      return @"image/*";
    case PSJSONResponseType:
      return @"application/json";
    case PSXMLResponseType:
      return @"text/xml";
    case PSAnyResponseType:
    case PSBinaryResponseType:
      return @"*/*";
    default:
      return nil;
  }
}

- (void) sendFor: (id) aTarget callback: (SEL) aCallback {
  self.target = aTarget;
  self.callback = aCallback;
  [self send];
}

- (void) send {
  [self startAsynchronous];
}

- (PSResponse *) response {
  if (!response) {
    response = [[PSResponse alloc] initWithRequest: self];
  }
  return response;
}

- (void) notifyTargetOfSuccess {
  [target performSelector: callback withObject: nil];
}

- (void) notifyTargetOfSuccessWithObject: (id) object {
  [target performSelector: callback withObject: object];
}

- (void) notifyTargetOfError: (NSError *) anError {
  [target requestFailed: self withError: anError];
}

- (void) notifyTargetOfAuthenticationError {
  [target authenticationFailedInRequest: self];
}

@end

#endif
