//
//  UAGithubURLConnection.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 26/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubURLConnection.h"
#import "NSString+UUID.h"


@implementation UAGithubURLConnection

@synthesize data, requestType, responseType, identifier;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
    if (self = [super initWithRequest:request delegate:delegate]) {
        data = [[NSMutableData alloc] initWithCapacity:0];
        identifier = [[NSString stringWithNewUUID] retain];
        requestType = reqType;
		responseType = respType;
    }
    
	NSLog(@"New %@ connection: %@, %@", request.HTTPMethod, request, identifier);
	
    return self;
}

- (void)resetDataLength
{
    [data setLength:0];
	
}


- (void)appendData:(NSData *)newData
{
    [data appendData:newData];
	
}


@end
