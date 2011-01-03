// -------------------------------------------------------
// PSSecurityExtensions.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#ifdef PSITOOLKIT_ENABLE_SECURITY

#if TARGET_OS_IPHONE
  #import "SFHFKeychainUtils.h"
#else
  #import "SDKeychain.h"
#endif

@interface NSUserDefaults (PsiToolkitPrivate)
- (NSString *) psKeychainServiceNameForKey: (NSString *) key;
@end

@implementation NSUserDefaults (PsiToolkitPrivate)

- (NSString *) psKeychainServiceNameForKey: (NSString *) key {
  return PSFormat(@"%@/%@", [[NSBundle mainBundle] bundleIdentifier], key);
}

@end

@implementation NSUserDefaults (PsiToolkit)

- (NSString *) psPasswordForKey: (NSString *) key andUsername: (NSString *) username {
  if (username) {
    #if TARGET_OS_IPHONE
      NSError *error;
      NSString *serviceName = [self psKeychainServiceNameForKey: key];
      return [SFHFKeychainUtils getPasswordForUsername: username andServiceName: serviceName error: &error];
    #else
      return [SDKeychain securePasswordForIdentifier: username];
    #endif
  } else {
    return nil;
  }
}

- (void) psSetPassword: (NSString *) password forKey: (NSString *) key andUsername: (NSString *) username {
  #if TARGET_OS_IPHONE
    NSError *error;
    NSString *serviceName = [self psKeychainServiceNameForKey: key];
    if (password) {
      [SFHFKeychainUtils storeUsername: username
                           andPassword: password
                        forServiceName: serviceName
                        updateExisting: YES
                                 error: &error];
    } else {
      [SFHFKeychainUtils deleteItemForUsername: username
                                andServiceName: serviceName
                                         error: &error];
    }
  #else
    [SDKeychain setSecurePassword: password forIdentifier: username];
  #endif
}

@end

#endif
