//
//  UAGithubJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubJSONParser.h"
#import "CJSONDeserializer.h"
#import "NSArray+Utilities.h"
#import "NSString+UAGithubEngineUtilities.h"

@implementation UAGithubJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
    if (self = [super init]) 
	{
        json = [theJSON retain];
        delegate = theDelegate;
		connectionIdentifier = [theIdentifier retain];
        requestType = reqType;
		responseType = respType;
    }
	
    return self;
	
}


- (void)dealloc
{
	[json release];
	[connectionIdentifier release];
	[super dealloc];
	
}


- (void)parse
{
	NSError *error = nil;
	NSMutableDictionary *dictionary = [[[CJSONDeserializer deserializer] deserializeAsDictionary:json error:&error] mutableCopy];	
	
	if (!error)
	{
		if ([[dictionary allKeys] containsObject:@"error"])
		{
			error = [NSError errorWithDomain:@"UAGithubEngineGithubError" code:0 userInfo:[NSDictionary dictionaryWithObject:[dictionary objectForKey:@"error"] forKey:@"errorMessage"]];
			[delegate parsingFailedForConnection:connectionIdentifier ofResponseType:responseType withError:error];
			return;
		}
		
		NSArray *parsedObjects = nil;

		// parsedObjects is expected to be an NSArray, so we have to check if the parser has returned an array or a dictionary.
		// This would be the case if there is only one result for our API call, such as for a single user.
		// If we're dealing with a single object, we have to wrap it in an array before we return it.
		if ([[[dictionary allValues] firstObject] isKindOfClass:[NSDictionary class]]) 
		{
			parsedObjects = [NSArray arrayWithObject:[[dictionary allValues] firstObject]];
		}
		else
		{
			parsedObjects = [[dictionary allValues] firstObject];
		}
		

		
		// Numbers and 'TRUE'/'FALSE' boolean are handled by the parser
		// We need to handle date elements and 0/1 boolean values 
		for (NSMutableDictionary *theDictionary in parsedObjects)
		{
			for (NSString *keyString in dateElements)
			{
				if ([theDictionary objectForKey:keyString] && ![[theDictionary objectForKey:keyString] isEqual:[NSNull null]]) {
					NSDate *date = [[theDictionary objectForKey:keyString] dateFromGithubDateString];
					[theDictionary setObject:date forKey:keyString];
				}
			}
			
			for (NSString *keyString in boolElements)
			{
				if ([theDictionary objectForKey:keyString]) {
					[theDictionary setObject:[NSNumber numberWithBool:[[theDictionary objectForKey:keyString] intValue]] forKey:keyString];
				}
			}
					 
		}

		[delegate parsingSucceededForConnection:connectionIdentifier ofResponseType:responseType withParsedObjects:parsedObjects];
	}
	else 
	{
		[delegate parsingFailedForConnection:connectionIdentifier ofResponseType:responseType withError:error];
	}
	
	[dictionary release];
	
}	



@end
