// -------------------------------------------------------
// PSAccount.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#if defined(PSITOOLKIT_ENABLE_MODELS) && defined(PSITOOLKIT_ENABLE_SECURITY)

#import "PSAccount.h"

@implementation PSAccount

@synthesize username, password;
PSReleaseOnDealloc(username, password);

+ (NSArray *) propertyList {
  return @[@"username", @"password"];
}

+ (NSArray *) propertiesSavedInSettings {
  return [self propertyList];
}

+ (BOOL) isPropertySavedSecurely: (NSString *) property {
  return ([property isEqual: @"password"]);
}

+ (NSString *) settingNameForProperty: (NSString *) property {
  return PSFormat(@"account.%@", property);
}

+ (id) accountFromSettings {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

  PSAccount *newAccount = [[self alloc] init];
  newAccount.username = [settings objectForKey: [self settingNameForProperty: @"username"]];

  if (newAccount.username) {
    for (NSString *property in [self propertiesSavedInSettings]) {
      NSString *value;
      NSString *settingsKey = [self settingNameForProperty: property];

      if ([self isPropertySavedSecurely: property]) {
        value = [settings psPasswordForKey: settingsKey andUsername: newAccount.username];
      } else {
        value = [settings objectForKey: settingsKey];
      }

      [newAccount setValue: value forKey: property];
    }
  }

  if ([newAccount hasAllRequiredProperties]) {
    return [newAccount autorelease];
  } else {
    [newAccount release];
    return nil;
  }
}

- (BOOL) hasAllRequiredProperties {
  for (NSString *property in [[self class] propertiesSavedInSettings]) {
    NSString *value = [self valueForKey: property];
    if (PSIsBlank(value)) {
      return NO;
    }
  }

  return YES;
}

- (void) save {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

  for (NSString *property in [[self class] propertiesSavedInSettings]) {
    NSString *settingsKey = [[self class] settingNameForProperty: property];
    NSString *value = [self valueForKey: property];

    if ([[self class] isPropertySavedSecurely: property]) {
      [settings psSetPassword: value forKey: settingsKey andUsername: username];
    } else {
      if (value) {
        [settings setObject: value forKey: settingsKey];
      } else {
        [settings removeObjectForKey: settingsKey];
      }
    }
  }

  [settings synchronize];
}

- (void) clear {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSString *oldUsername = [username retain];

  for (NSString *property in [[self class] propertiesSavedInSettings]) {
    NSString *settingsKey = [[self class] settingNameForProperty: property];

    if ([[self class] isPropertySavedSecurely: property]) {
      [settings psSetPassword: nil forKey: settingsKey andUsername: oldUsername];
    } else {
      [settings removeObjectForKey: settingsKey];
    }

    [self setValue: nil forKey: property];
  }

  [oldUsername release];
  [settings synchronize];
}

@end

#endif
