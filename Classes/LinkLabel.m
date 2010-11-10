// -------------------------------------------------------
// LinkLabel.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "LinkLabel.h"

@implementation LinkLabel

- (void) awakeFromNib {
  NSColor *underlineColor = [NSColor colorWithCalibratedRed: 0.0 green: 0.0 blue: 1.0 alpha: 0.35];

  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  [attributes setObject: [NSColor blueColor] forKey: NSForegroundColorAttributeName];
  [attributes setObject: PSInt(NSUnderlineStyleSingle) forKey: NSUnderlineStyleAttributeName];
  [attributes setObject: underlineColor forKey: NSUnderlineColorAttributeName];
  [attributes setObject: self.font forKey: NSFontAttributeName];

  self.attributedTitle = [[NSAttributedString alloc] initWithString: self.title attributes: attributes];
}  

- (void) resetCursorRects {
  [self addCursorRect: self.bounds cursor: [NSCursor pointingHandCursor]];
}

@end
