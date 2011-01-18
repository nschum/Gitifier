//
//  UAGithubUsersJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubUsersJSONParser.h"
#import "CJSONDeserializer.h"

@implementation UAGithubUsersJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
	
	if (self = [super initWithJSON:theJSON delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
		dateElements = [NSArray arrayWithObjects:@"created_at", @"created", @"pushed", nil];
	}
	
	[self parse];
	
	return self;
}


@end
