//
//  NotificationsPanelController.m
//  Gitifier
//
//  Created by Jakub Suder on 28.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GitifierAppDelegate.h"
#import "GrowlController.h"
#import "NotificationsPanelController.h"

static NSString *IgnoreMyCommitsText = @"Ignore my own commits";
static NSString *GrowlAppStoreURL = @"macappstore://itunes.apple.com/us/app/growl/id467939042";

@implementation NotificationsPanelController

- (id) init {
  return [super initWithNibName: @"NotificationsPreferencesPanel" bundle: nil];
}

- (void) awakeFromNib {
  [self updateUserEmailText: [[NSApp delegate] userEmail]];
  PSObserve(nil, UserEmailChangedNotification, userEmailChanged:);
}

- (NSString *) toolbarItemIdentifier {
  return @"Notifications";
}

- (NSImage *) toolbarItemImage {
  return [NSImage imageNamed: @"notifications_icon.png"];
}

- (NSString *) toolbarItemLabel {
  return @"Notifications";
}

- (void) userEmailChanged: (NSNotification *) notification {
  [self updateUserEmailText: notification.userInfo[@"email"]];
}

- (void) updateUserEmailText: (NSString *) email {
  if (email) {
    NSString *title = PSFormat(@"%@ (%@)", IgnoreMyCommitsText, email);
    NSInteger labelLength = IgnoreMyCommitsText.length;
    NSRange labelRange = NSMakeRange(0, labelLength);
    NSRange emailRange = NSMakeRange(labelLength, title.length - labelLength);
    
    NSFont *standardFont = [NSFont systemFontOfSize: 13.0];
    NSFont *smallerFont = [NSFont systemFontOfSize: 11.0];
    NSColor *gray = [NSColor colorWithCalibratedWhite: 0.5 alpha: 1.0];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString: title];
    [text addAttribute: NSFontAttributeName value: standardFont range: labelRange];
    [text addAttribute: NSFontAttributeName value: smallerFont range: emailRange];
    [text addAttribute: NSForegroundColorAttributeName value: gray range: emailRange];
    self.ignoreOwnEmailsField.attributedTitle = text;
  } else {
    self.ignoreOwnEmailsField.title = IgnoreMyCommitsText;
  }
}

- (void) updateGrowlInfoPanel {
  BOOL growlDetected = [GrowlController growlDetected];
  BOOL panelVisible = !self.growlInfoPanel.isHidden;

  if (!growlDetected && !panelVisible) {
    [self.growlInfoPanel psShow];
    [self.view psResizeVerticallyBy: self.growlInfoPanel.frame.size.height];
  } else if (growlDetected && panelVisible) {
    [self.growlInfoPanel psHide];
    [self.view psResizeVerticallyBy: -self.growlInfoPanel.frame.size.height];
  }
}

- (IBAction) getGrowlButtonPressed: (id) sender {
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: GrowlAppStoreURL]];
}

@end
