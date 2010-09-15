// -------------------------------------------------------
// Repository.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Git.h"
#import "Repository.h"
#import "Utils.h"

static NSString *urlRegexp = @"(git|ssh|http|https|ftp|ftps|rsync):\\/\\/\\S+";

@implementation Repository

@synthesize url, delegate;

- (id) initWithUrl: (NSString *) anUrl {
  self = [super init];
  if ([self isProperUrl: anUrl]) {
    url = anUrl;
    return self;
  } else {
    return nil;
  }
}

- (void) clone {
  NSString *path = [self prepareCloneDirectory];
  if (!path) {
    [self notifyDelegateWithSelector: @selector(repositoryCouldNotBeCloned:)];
    return;
  }

  Git *git = [[Git alloc] initWithDirectory: path];
  [git setDelegate: self];
  [git runCommand: @"clone" withArguments: PSArray(url)];
}

- (void) commandCompleted: (NSString *) command {
  if ([command isEqual: @"clone"]) {
    [self notifyDelegateWithSelector: @selector(repositoryWasCloned:)];
  }
}

- (void) commandFailed: (NSString *) command {
  if ([command isEqual: @"clone"]) {
    [self notifyDelegateWithSelector: @selector(repositoryCouldNotBeCloned:)];
  }
}

- (BOOL) isProperUrl: (NSString *) anUrl {
  NSPredicate *regexp = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", urlRegexp];
  return [regexp evaluateWithObject: anUrl];
}

- (NSString *) prepareCloneDirectory {
  NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachesDirectory = [directories objectAtIndex: 0];
  if (!cachesDirectory) {
    NSLog(@"Error: Caches directory could not be found.");
    return nil;
  }

  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  NSString *appCachesDirectory = [cachesDirectory stringByAppendingPathComponent: bundleIdentifier];

  NSString *urlHash = [url MD5Hash];
  NSString *cloneDirectory = [appCachesDirectory stringByAppendingPathComponent: urlHash];

  NSFileManager *manager = [NSFileManager defaultManager];
  NSError *error;

  BOOL exists = [manager fileExistsAtPath: cloneDirectory];
  if (exists) {
    BOOL removed = [manager removeItemAtPath: cloneDirectory error: &error];
    if (!removed) {
      NSLog(@"Error: File or directory %@ could not be deleted: %@.", cloneDirectory, error.localizedDescription);
      return nil;
    }
  }

  BOOL created = [manager createDirectoryAtPath: cloneDirectory
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: &error];
  if (!created) {
    NSLog(@"Error: Directory %@ could not be created: %@.", cloneDirectory, error.localizedDescription);
    return nil;
  }

  return cloneDirectory;
}

- (void) notifyDelegateWithSelector: (SEL) selector {
  if ([delegate respondsToSelector: selector]) {
    [delegate performSelector: selector withObject: self];
  }
}

@end
