// -------------------------------------------------------
// PSConnectorDelegate.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  These methods might be called on any object that acts as a PSConnector request target
  (you don't have to explicitly declare the class as implementing the protocol).
*/

@class PSRequest;

@protocol PSConnectorDelegate

- (void) requestFailed: (PSRequest *) request withError: (NSError *) error;
- (void) authenticationFailedInRequest: (PSRequest *) request;

@end
