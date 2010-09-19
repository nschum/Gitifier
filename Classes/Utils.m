// -------------------------------------------------------
// Utils.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <openssl/md5.h>
#import "Utils.h"

@implementation NSString (Gitifier)

- (NSString *) MD5Hash {
  NSData *data = [self dataUsingEncoding: NSUTF8StringEncoding];
  if (!data) {
    return nil;
  }
  
  NSMutableData *digest = [NSMutableData dataWithLength: MD5_DIGEST_LENGTH];
  if (digest && MD5(data.bytes, data.length, digest.mutableBytes)) {
    NSMutableString *buffer = [NSMutableString stringWithCapacity: digest.length * 2];
    const unsigned char *dataBuffer = digest.bytes;
    
    for (NSInteger i = 0; i < digest.length; i++) {
      [buffer appendFormat: @"%02X", (unsigned long) dataBuffer[i]];
    }
    return buffer;
  } else {
    return nil;
  }
}

@end
