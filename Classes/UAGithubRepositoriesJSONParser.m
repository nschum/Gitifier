//
//  UAGithubRepositoriesJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubRepositoriesJSONParser.h"


@implementation UAGithubRepositoriesJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{	
	if (self = [super initWithJSON:theJSON delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
		boolElements = [NSArray arrayWithObjects:@"has_issues", @"has_downloads", @"fork", @"has_wiki", @"private", nil];
		dateElements = [NSArray arrayWithObjects:@"created_at", @"pushed_at", @"created", @"pushed", nil];
	}
	
	[self parse];
	
	return self;
}

@end
