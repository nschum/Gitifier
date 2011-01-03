// -------------------------------------------------------
// PSAccount.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  User account model, with username and password fields by default. Can be subclassed to add more fields
  (in that case, override 'propertyList' or 'propertiesSavedInSettings' and 'isPropertySavedSecurely' if necessary).

  Provides methods to load and save fields from settings/keychain and to clear them. This class is also used
  by PSConnector for HTTP Authentication (though you can use any other class that has username and password fields).

  Usage:
      PSConnector *connector = [PSConnector sharedConnector];
      connector.account = [PSAccount accountFromSettings];
      connector.usesHTTPAuthentication = YES;
      // connect ...

      [connector.account setPassword: @"updated"];
      [connector.account save];
*/

#import <Foundation/Foundation.h>
#import "PSModel.h"

@protocol PSConnectorAccount;

@interface PSAccount : PSModel <PSConnectorAccount> {
  NSString *username;
  NSString *password;
}

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

// fields that will be saved and loaded from settings/keychain (by default all fields listed in 'propertyList')
+ (NSArray *) propertiesSavedInSettings;

// callback that tells if a property is a password (by default only 'password' is a treated as a password)
+ (BOOL) isPropertySavedSecurely: (NSString *) property;

// settings key for a given property (by default 'account.<property>')
+ (NSString *) settingNameForProperty: (NSString *) property;

// loads account data from settings/keychain and returns a new account, or nil if not all fields are set
+ (id) accountFromSettings;

// tells if all fields listed in propertiesSavedInSettings are set and non-empty
- (BOOL) hasAllRequiredProperties;

// saves account data to settings/keychain
- (void) save;

// clears account data in settings/keychain and sets all fields to nil
- (void) clear;

@end
