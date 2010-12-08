// -------------------------------------------------------
// PSCocoaExtensions.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#if !TARGET_OS_IPHONE

#import <Cocoa/Cocoa.h>

@interface NSControl (PsiToolkit)
- (void) psDisable;
- (void) psEnable;
@end

@interface NSTextField (PsiToolkit)
- (void) psUnselectText;
@end

@interface NSView (PsiToolkit)
- (void) psHide;
- (void) psShow;
- (void) psMoveVerticallyBy: (CGFloat) pixels;
- (void) psMoveVerticallyTo: (CGFloat) position;
- (void) psMoveHorizontallyBy: (CGFloat) pixels;
- (void) psMoveHorizontallyTo: (CGFloat) position;
- (void) psResizeVerticallyBy: (CGFloat) pixels;
- (void) psResizeVerticallyTo: (CGFloat) position;
- (void) psResizeHorizontallyBy: (CGFloat) pixels;
- (void) psResizeHorizontallyTo: (CGFloat) position;
@end

@interface NSWindow (PsiToolkit)
- (void) psShowAlertSheetWithTitle: (NSString *) title message: (NSString *) message;
- (void) psMoveVerticallyBy: (CGFloat) pixels;
- (void) psMoveVerticallyTo: (CGFloat) position;
- (void) psMoveHorizontallyBy: (CGFloat) pixels;
- (void) psMoveHorizontallyTo: (CGFloat) position;
- (void) psResizeVerticallyBy: (CGFloat) pixels;
- (void) psResizeVerticallyTo: (CGFloat) position;
- (void) psResizeHorizontallyBy: (CGFloat) pixels;
- (void) psResizeHorizontallyTo: (CGFloat) position;
@end

#endif
