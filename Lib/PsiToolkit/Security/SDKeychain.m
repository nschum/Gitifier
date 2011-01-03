//
//  SDKeychain.m
//
//  Copyright (c) 2009, Steven Degutis. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that
//  the following conditions are met:
//    * Redistributions of source code must retain the above copyright notice, this list of conditions and the
//      following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
//      following disclaimer in the documentation and/or other materials provided with the distribution.
//    * Neither the name of the Steven Degutis nor the names of its contributors may be used to endorse or promote
//      products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
//  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#if !TARGET_OS_IPHONE && defined(PSITOOLKIT_ENABLE_SECURITY)

#import "SDKeychain.h"

@interface SDKeychain (Private)

+ (SecKeychainItemRef) itemForKeychainUsername:(NSString*)username;
+ (NSString*) _uniqueServiceNameForApp;

@end


@implementation SDKeychain

+ (NSString*) _uniqueServiceNameForApp {
	return [[NSBundle mainBundle] bundleIdentifier];
}

+ (SecKeychainItemRef) itemForKeychainUsername:(NSString*)username {
	SecKeychainItemRef item = NULL;
	NSString *serviceName = [self _uniqueServiceNameForApp];
	
	OSErr err = SecKeychainFindGenericPassword(NULL,
											   [serviceName length],
											   [serviceName UTF8String],
											   [username length],
											   [username UTF8String],
											   NULL,
											   NULL,
											   &item
											   );
	
	if (err != noErr || item == NULL)
		return NULL;
	else
		return item;
}

+ (NSString*) securePasswordForIdentifier:(NSString*)username {
	SecKeychainItemRef item = [self itemForKeychainUsername:username];
	
	if (item == NULL)
		return nil;
	
	UInt32 passwordLength;
	char* password;
	
	OSErr err = SecKeychainItemCopyAttributesAndData(item,
													 NULL,
													 NULL,
													 NULL,
													 &passwordLength,
													 (void**)&password
													 );
	
	if (err != noErr) {
		CFStringRef errMsg = SecCopyErrorMessageString(err, NULL);
		CFShow(errMsg);
		CFRelease(errMsg);
		return nil;
	}
	
	NSString *passwordString = [[NSString alloc] initWithBytes:password
														length:passwordLength
													  encoding:NSUTF8StringEncoding];
	
	SecKeychainItemFreeContent(NULL, password);
	
	return [passwordString autorelease];
}

+ (BOOL) setSecurePassword:(NSString*)newPasswordString forIdentifier:(NSString*)username {
    if (!newPasswordString)
        newPasswordString = @"";
    
	SecKeychainItemRef item = [self itemForKeychainUsername:username];
	
	if (item == NULL) {
		NSString *serviceName = [self _uniqueServiceNameForApp];
		
		OSErr err = SecKeychainAddGenericPassword(NULL,
												  [serviceName length],
												  [serviceName UTF8String],
												  [username length],
												  [username UTF8String],
												  [newPasswordString length],
												  [newPasswordString UTF8String],
												  &item
												  );
		
		return (err == noErr && item != NULL);
	}
	else {
		const char *newPassword = [newPasswordString UTF8String];
		
		OSStatus err = SecKeychainItemModifyAttributesAndData(item,
															  NULL,
															  strlen(newPassword),
															  (void *)newPassword
															  );
		
		return (err == noErr && item != NULL);
	}
}

@end

#endif
