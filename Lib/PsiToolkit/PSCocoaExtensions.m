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

- (void) psMoveVerticallyBy: (CGFloat) pixels {
  NSRect frame = self.frame;
  frame.origin.y += pixels;
  self.frame = frame;
}

- (void) psMoveVerticallyTo: (CGFloat) position {
  NSRect frame = self.frame;
  frame.origin.y = position;
  self.frame = frame;
}

- (void) psMoveHorizontallyBy: (CGFloat) pixels {
  NSRect frame = self.frame;
  frame.origin.x += pixels;
  self.frame = frame;
}

- (void) psMoveHorizontallyTo: (CGFloat) position {
  NSRect frame = self.frame;
  frame.origin.x = position;
  self.frame = frame;
}

- (void) psResizeVerticallyBy: (CGFloat) pixels {
  NSRect frame = self.frame;
  frame.size.height += pixels;
  self.frame = frame;
}

- (void) psResizeVerticallyTo: (CGFloat) position {
  NSRect frame = self.frame;
  frame.size.height = position;
  self.frame = frame;
}

- (void) psResizeHorizontallyBy: (CGFloat) pixels {
  NSRect frame = self.frame;
  frame.size.width += pixels;
  self.frame = frame;
}

- (void) psResizeHorizontallyTo: (CGFloat) position {
  NSRect frame = self.frame;
  frame.size.width = position;
  self.frame = frame;
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

- (void) psMoveVerticallyBy: (CGFloat) pixels {
  NSRect frame = self.frame;
  frame.origin.y += pixels;
  [self setFrame: frame display: YES];
}

- (void) psMoveVerticallyTo: (CGFloat) position {
  NSRect frame = self.frame;
  frame.origin.y = position;
  [self setFrame: frame display: YES];
}

- (void) psMoveHorizontallyBy: (CGFloat) pixels {
  NSRect frame = self.frame;
  frame.origin.x += pixels;
  [self setFrame: frame display: YES];
}

- (void) psMoveHorizontallyTo: (CGFloat) position {
  NSRect frame = self.frame;
  frame.origin.x = position;
  [self setFrame: frame display: YES];
}

- (void) psResizeVerticallyBy: (CGFloat) pixels {
  NSRect frame = self.frame;
  frame.size.height += pixels;
  [self setFrame: frame display: YES];
}

- (void) psResizeVerticallyTo: (CGFloat) position {
  NSRect frame = self.frame;
  frame.size.height = position;
  [self setFrame: frame display: YES];
}

- (void) psResizeHorizontallyBy: (CGFloat) pixels {
  NSRect frame = self.frame;
  frame.size.width += pixels;
  [self setFrame: frame display: YES];
}

- (void) psResizeHorizontallyTo: (CGFloat) position {
  NSRect frame = self.frame;
  frame.size.width = position;
  [self setFrame: frame display: YES];
}

@end

#endif
