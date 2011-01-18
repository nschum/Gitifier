//
//  UAGithubURLConnection.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 26/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UAGithubEngineRequestTypes.h"

@interface UAGithubURLConnection : NSURLConnection 
{
    NSMutableData *data;                   
    UAGithubRequestType requestType;      
	UAGithubResponseType responseType;
    NSString *identifier;
}


@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, assign) UAGithubRequestType requestType;
@property (nonatomic, assign) UAGithubResponseType responseType;
@property (nonatomic, retain) NSString *identifier;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType;
- (void)resetDataLength;
- (void)appendData:(NSData *)newData;


@end
