//
//  UAGithubSimpleJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/08/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubSimpleJSONParser.h"

@implementation UAGithubSimpleJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
	
	self = [super initWithJSON:theJSON delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType];
	[self parse];
	
	return self;
}


@end
