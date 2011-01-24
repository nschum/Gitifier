// -------------------------------------------------------
// PSUIExtensions.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

#define PSUIColorWithRGB(r, g, b) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha: 1.0]
#define PSUIColorWithRGBA(r, g, b, a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha: a]
#define PSUIColorWithWhiteValue(w) [UIColor colorWithWhite: w/255.0 alpha: 1.0]

// ------------------------------------------------------------------------------------------------

@interface UIAlertView (PsiToolkit)

// displays a UIAlertView with given title, message and one button named "OK"
+ (void) psShowAlertWithTitle: (NSString *) title message: (NSString *) message;

// displays a UIAlertView with title "Error" (localized) and given message
+ (void) psShowErrorWithMessage: (NSString *) message;
@end

// ------------------------------------------------------------------------------------------------

@interface UINavigationController (PsiToolkit)

// returns the view controller at the bottom of the stack
- (UIViewController *) psRootController;

@end

// ------------------------------------------------------------------------------------------------

@interface UITableView (PsiToolkit)

// reuses a cell with given id from the table, if possible, otherwise makes a new one with given id and style
- (UITableViewCell *) psCellWithStyle: (UITableViewCellStyle) style andIdentifier: (NSString *) identifier;

// as above, but uses a generic cell id (use this if you only have one cell type in the table)
- (UITableViewCell *) psGenericCellWithStyle: (UITableViewCellStyle) style;
@end

// ------------------------------------------------------------------------------------------------

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

// ------------------------------------------------------------------------------------------------

@interface UIViewController (PsiToolkit)

// sets the name used on back button when this controller is below the active one (by setting backBarButtonItem)
- (void) psSetBackButtonTitle: (NSString *) title;

// hides the controller that is currently displayed as a modal popup
- (void) psHidePopupView;

// shows a given controller in a modal popup, wrapped in a navigation view
- (void) psShowPopupView: (UIViewController *) controller;

// shows a given controller in a modal popup, wrapped in a navigation view, with given presentation style (for iPad)
- (void) psShowPopupView: (UIViewController *) controller withStyle: (UIModalPresentationStyle) style;

// returns a new navigation controller having this controller as root
- (UINavigationController *) psWrapInNavigationController;

@end
