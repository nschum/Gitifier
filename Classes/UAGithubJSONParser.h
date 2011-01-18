//
//  UAGithubJSONParser.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "UAGithubParserDelegate.h"
#import "UAGithubEngineRequestTypes.h"

@interface UAGithubJSONParser : NSObject {
	id <UAGithubParserDelegate> delegate;
    NSString *connectionIdentifier;
    UAGithubRequestType requestType;
	UAGithubResponseType responseType;
    NSData *json;
	
	NSArray *boolElements;
	NSArray *dateElements;

}

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType;
- (void)parse;

@end
