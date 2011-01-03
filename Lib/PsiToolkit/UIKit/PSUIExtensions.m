// -------------------------------------------------------
// PSUIExtensions.m
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#ifdef PSITOOLKIT_ENABLE_UIKIT

#import "PSMacros.h"
#import "PSUIExtensions.h"

// ------------------------------------------------------------------------------------------------

@implementation UIAlertView (PsiToolkit)

+ (void) psShowAlertWithTitle: (NSString *) title message: (NSString *) message {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                  message: message
                                                 delegate: nil
                                        cancelButtonTitle: @"OK"
                                        otherButtonTitles: nil];
  [alert show];
  [alert release];
}

+ (void) psShowErrorWithMessage: (NSString *) message {
  [self psShowAlertWithTitle: PSTranslate(@"Error") message: message];
}

@end

// ------------------------------------------------------------------------------------------------

@implementation UIView (PsiToolkit)

- (void) psMoveVerticallyBy: (CGFloat) pixels {
  CGRect frame = self.frame;
  frame.origin.y += pixels;
  self.frame = frame;
}

- (void) psMoveVerticallyTo: (CGFloat) position {
  CGRect frame = self.frame;
  frame.origin.y = position;
  self.frame = frame;
}

- (void) psMoveHorizontallyBy: (CGFloat) pixels {
  CGRect frame = self.frame;
  frame.origin.x += pixels;
  self.frame = frame;
}

- (void) psMoveHorizontallyTo: (CGFloat) position {
  CGRect frame = self.frame;
  frame.origin.x = position;
  self.frame = frame;
}

- (void) psResizeVerticallyBy: (CGFloat) pixels {
  CGRect frame = self.frame;
  frame.size.height += pixels;
  self.frame = frame;
}

- (void) psResizeVerticallyTo: (CGFloat) position {
  CGRect frame = self.frame;
  frame.size.height = position;
  self.frame = frame;
}

- (void) psResizeHorizontallyBy: (CGFloat) pixels {
  CGRect frame = self.frame;
  frame.size.width += pixels;
  self.frame = frame;
}

- (void) psResizeHorizontallyTo: (CGFloat) position {
  CGRect frame = self.frame;
  frame.size.width = position;
  self.frame = frame;
}

@end

// ------------------------------------------------------------------------------------------------

@implementation UITableView (PsiToolkit)

- (UITableViewCell *) psCellWithStyle: (UITableViewCellStyle) style andIdentifier: (NSString *) identifier {
  UITableViewCell *cell = [self dequeueReusableCellWithIdentifier: identifier];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle: style reuseIdentifier: identifier] autorelease];
  }
  return cell;
}

- (UITableViewCell *) psGenericCellWithStyle: (UITableViewCellStyle) style {
  return [self psCellWithStyle: style andIdentifier: PSGenericCell];
}

@end

// ------------------------------------------------------------------------------------------------

@implementation UIViewController (PsiToolkit)

- (void) psSetBackButtonTitle: (NSString *) title {
  UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle: title
                                                             style: UIBarButtonItemStylePlain
                                                            target: nil
                                                            action: nil];
  self.navigationItem.backBarButtonItem = [button autorelease];
}

@end

#endif
