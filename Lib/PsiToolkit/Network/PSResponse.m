// -------------------------------------------------------
// PSResponse.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#ifdef PSITOOLKIT_ENABLE_NETWORK

#import "PSRequest.h"
#import "PSResponse.h"

#define DEBUG_RESPONSE_LIMIT 500

@implementation PSResponse

- (id) initWithRequest: (PSRequest *) aRequest {
  self = [super init];
  if (self) {
    request = aRequest;
  }
  return self;
}

- (NSDictionary *) headers {
  return request.responseHeaders;
}

- (NSString *) text {
  return request.responseString;
}

- (NSData *) data {
  return request.responseData;
}

- (NSInteger) status {
  return request.responseStatusCode;
}

- (NSString *) contentType {
  return [[self headers] objectForKey: @"Content-Type"];
}

- (BOOL) hasReadableContentType {
  NSString *contentType = [self contentType];
  return [contentType hasPrefix: @"text/"]
      || [contentType psContainsString: @"javascript"]
      || [contentType psContainsString: @"json"]
      || [contentType psContainsString: @"xml"];
}

- (BOOL) matchesExpectedContentType {
  NSString *actual = self.contentType;
  switch (request.expectedContentType) {
    case PSHTMLResponseType:
      return [actual hasPrefix: @"text/html"] || [actual hasPrefix: @"application/xhtml+xml"];
    case PSImageResponseType:
    case PSImageDataResponseType:
      return [actual hasPrefix: @"image/"];
    case PSJSONResponseType:
      return [actual psContainsString: @"javascript"] || [actual psContainsString: @"json"];
    case PSXMLResponseType:
      return [actual psContainsString: @"/xml"];
    case PSBinaryResponseType:
      return ![self hasReadableContentType];
    case PSAnyResponseType:
      return YES;
    default:
      return NO;
  }
}

- (NSString *) description {
  NSString *message = PSFormat(@"request to %@: status = %d, content type = %@",
                               request.url, self.status, self.contentType);
  if ([self hasReadableContentType] && (self.text.length <= DEBUG_RESPONSE_LIMIT)) {
    message = [message stringByAppendingFormat: @", text = %@", self.text];
  } else {
    message = [message stringByAppendingFormat: @", length = %d", self.text.length];
  }

  return message;
}

@end

#endif
