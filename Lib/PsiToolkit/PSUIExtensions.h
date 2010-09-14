// -------------------------------------------------------
// PSUIExtensions.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

@interface UIAlertView (PsiToolkit)
+ (void) psShowAlertWithTitle: (NSString *) title message: (NSString *) message;
+ (void) psShowErrorWithMessage: (NSString *) message;
@end

@interface UIView (PsiToolkit)
- (void) psMoveVerticallyBy: (CGFloat) pixels;
- (void) psMoveVerticallyTo: (CGFloat) position;
- (void) psMoveHorizontallyBy: (CGFloat) pixels;
- (void) psMoveHorizontallyTo: (CGFloat) position;
- (void) psResizeVerticallyBy: (CGFloat) pixels;
- (void) psResizeVerticallyTo: (CGFloat) position;
- (void) psResizeHorizontallyBy: (CGFloat) pixels;
- (void) psResizeHorizontallyTo: (CGFloat) position;
@end

@interface UITableView (PsiToolkit)
- (UITableViewCell *) psCellWithStyle: (UITableViewCellStyle) style andIdentifier: (NSString *) identifier;
- (UITableViewCell *) psGenericCellWithStyle: (UITableViewCellStyle) style;
@end

@interface UIViewController (PsiToolkit)
- (void) psSetBackButtonTitle: (NSString *) title;
@end

#endif
