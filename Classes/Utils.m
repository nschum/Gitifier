// -------------------------------------------------------
// Utils.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <CommonCrypto/CommonDigest.h>
#import "Utils.h"

NSString *UserEmailChangedNotification = @"UserEmailChangedNotification";
NSString *GitExecutableSetNotification = @"GitExecutableSetNotification";


@implementation NSString (Gitifier)

- (NSArray *) arrayOfCaptureComponentsMatchedByRegex: (NSRegularExpression *) regex {
  NSArray *matches = [regex matchesInString: self options: 0 range: NSMakeRange(0, self.length)];
  NSMutableArray *results = [NSMutableArray arrayWithCapacity: matches.count];

  for (NSTextCheckingResult *match in matches) {
    NSMutableArray *components = [NSMutableArray arrayWithCapacity: match.numberOfRanges];

    for (NSInteger i = 0; i <= match.numberOfRanges; i++) {
      // 0 is full range, components start from 1
      [components addObject: [self substringWithRange: [match rangeAtIndex: i]]];
    }

    [results addObject: [NSArray arrayWithArray: components]];
  }

  return [NSArray arrayWithArray: results];
}

- (NSArray *) componentsMatchedByRegex: (NSRegularExpression *) regex {
  NSArray *matches = [regex matchesInString: self options: 0 range: NSMakeRange(0, self.length)];
  NSMutableArray *results = [NSMutableArray arrayWithCapacity: matches.count];

  for (NSTextCheckingResult *match in matches) {
    [results addObject: [self substringWithRange: match.range]];
  }

  return [NSArray arrayWithArray: results];
}

- (BOOL) isMatchedByRegex: (NSRegularExpression *) regex {
  NSTextCheckingResult *result = [regex firstMatchInString: self options: 0 range: NSMakeRange(0, self.length)];
  return (result != nil);
}

- (NSString *) lastKeyPathElement {
  return [[self componentsSeparatedByString: @"."] lastObject];
}

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
      [buffer appendFormat: @"%02lX", (unsigned long) dataBuffer[i]];
    }
    return buffer;
  } else {
    return nil;
  }
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
