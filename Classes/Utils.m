// -------------------------------------------------------
// Utils.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <CommonCrypto/CommonDigest.h>
#import "Utils.h"

@implementation NSString (Gitifier)

- (NSString *) MD5Hash {
  NSData *data = [self dataUsingEncoding: NSUTF8StringEncoding];
  if (!data) {
    return nil;
  }
  
  NSMutableData *digest = [NSMutableData dataWithLength: CC_MD5_DIGEST_LENGTH];
  if (digest && CC_MD5(data.bytes, data.length, digest.mutableBytes)) {
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

- (NSString *) lastKeyPathElement {
  return [[self componentsSeparatedByString: @"."] lastObject];
}

@end

@implementation NSWindow (Gitifier)

- (BOOL) keepOnTop {
  return (self.level == NSModalPanelWindowLevel || self.level == NSStatusWindowLevel);
}

- (void) setKeepOnTop: (BOOL) keepOnTop {
  if (self.level != NSStatusWindowLevel) {
    self.level = keepOnTop ? NSModalPanelWindowLevel : NSNormalWindowLevel;
  }
}

@end
