//
//  UAGithubCommitsJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 28/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubCommitsJSONParser.h"


@implementation UAGithubCommitsJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
	
	if (self = [super initWithJSON:theJSON delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
		dateElements = [NSArray arrayWithObjects:@"committed_date", @"authored_date", nil];
	}
	
	[self parse];
	
	return self;
}


@end
