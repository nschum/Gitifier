//
//  NSString+UAGithubEngineUtilities.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 08/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "NSString+UAGithubEngineUtilities.h"


@implementation NSString(UAGithubEngineUtilities)

- (NSDate *)dateFromGithubDateString {
	
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	NSString *dateString = self;

	// Because Github returns three different date string formats throughout the API, 
	// we need to check how to process the string based on the format used
	if ([[self substringWithRange:NSMakeRange(10, 1)] isEqualToString:@"T"])
	{
		if ([[self substringWithRange:NSMakeRange([self length] - 1, 1)] isEqualToString:@"Z"])
		{
			// eg 2010-05-23T21:26:03.921Z (UTC with milliseconds)
			if([[self substringWithRange:NSMakeRange(19, 1)] isEqualToString:@"."]){
				[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
			// eg 2010-05-23T21:26:03Z (UTC without milliseconds)
			} else {
				[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
			}
		}
		else 
			// eg 2010-04-07T12:50:15-07:00
		{
			NSMutableString *newDate = [self mutableCopy];
			[newDate deleteCharactersInRange:NSMakeRange(22, 1)];
			[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
			[dateString release];
			dateString = newDate;
		}
	} else {
		// eg 2010/07/28 21:21:00 +0100
		[df setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
	}
	
    return [df dateFromString:dateString];

}


- (NSString *)encodedString
{
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@";/?:@&=$+{}<>,", kCFStringEncodingUTF8);

}


@end
