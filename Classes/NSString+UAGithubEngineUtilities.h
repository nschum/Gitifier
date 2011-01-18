//
//  NSString+UAGithubEngineUtilities.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 08/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface NSString(UAGithubEngineUtilities)

- (NSDate *)dateFromGithubDateString;
- (NSString *)encodedString;

@end
