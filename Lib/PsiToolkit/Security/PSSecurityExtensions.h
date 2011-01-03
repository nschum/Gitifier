// -------------------------------------------------------
// PSSecurityExtensions.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  These helpers let you set and read a password property securely from the Keychain
  (works for iPhone device, iPhone simulator and on MacOSX).
*/

@interface NSUserDefaults (PsiToolkit)
- (NSString *) psPasswordForKey: (NSString *) key andUsername: (NSString *) username;
- (void) psSetPassword: (NSString *) password forKey: (NSString *) key andUsername: (NSString *) username;
@end
