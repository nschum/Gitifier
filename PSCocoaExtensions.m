// -------------------------------------------------------
// PSCocoaExtensions.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#if !TARGET_OS_IPHONE

#import "PSCocoaExtensions.h"

@implementation NSControl (PsiToolkit)

- (void) psDisable {
  [self setEnabled: NO];
}

- (void) psEnable {
  [self setEnabled: YES];
}

@end

@implementation NSTextField (PsiToolkit)

- (void) psUnselectText {
  NSText *editor = [[self window] fieldEditor: YES forObject: self];
  editor.selectedRange = NSMakeRange(editor.string.length, 0);
}

@end

@implementation NSView (PsiToolkit)

- (void) psHide {
  [self setHidden: YES];
}

- (void) psShow {
  [self setHidden: NO];
}

@end

@implementation NSWindow (PsiToolkit)

- (void) psShowAlertSheetWithTitle: (NSString *) title message: (NSString *) message {
  NSAlert *alertWindow = [NSAlert alertWithMessageText: title
                                         defaultButton: @"OK"
                                       alternateButton: nil
                                           otherButton: nil
                             informativeTextWithFormat: message];
  [alertWindow beginSheetModalForWindow: self
                          modalDelegate: nil
                         didEndSelector: nil
                            contextInfo: nil];
}

@end

#endif
