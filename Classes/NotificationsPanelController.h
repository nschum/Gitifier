//
//  NotificationsPanelController.h
//  Gitifier
//
//  Created by Jakub Suder on 28.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MASPreferencesViewController.h"

@interface NotificationsPanelController : NSViewController <MASPreferencesViewController>

@property /*(weak)*/ IBOutlet NSButton *ignoreOwnEmailsField;
@property /*(weak)*/ IBOutlet NSView *growlInfoPanel;

- (IBAction) getGrowlButtonPressed: (id) sender;

@end
