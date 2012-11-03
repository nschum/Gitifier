//
//  NotificationsPanelController.h
//  Gitifier
//
//  Created by Jakub Suder on 28.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MASPreferencesViewController.h"

@interface NotificationsPanelController : NSViewController <MASPreferencesViewController>

@property IBOutlet NSButton *ignoreOwnEmailsField;
@property IBOutlet NSView *growlInfoPanel;

// public
- (IBAction) getGrowlButtonPressed: (id) sender;
- (void) updateGrowlInfoPanel;

// private
- (void) updateUserEmailText: (NSString *) email;

@end
