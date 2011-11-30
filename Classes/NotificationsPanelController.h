//
//  NotificationsPanelController.h
//  Gitifier
//
//  Created by Jakub Suder on 28.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MASPreferencesViewController.h"

@interface NotificationsPanelController : NSViewController <MASPreferencesViewController> {
  NSButton *ignoreOwnEmailsField;
}

@property IBOutlet NSButton *ignoreOwnEmailsField;

// private
- (void) updateUserEmailText: (NSString *) email;

@end
