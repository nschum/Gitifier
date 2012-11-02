// -------------------------------------------------------
// LinkLabel.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "LinkLabel.h"

@implementation LinkLabel

- (void) awakeFromNib {
  NSColor *underlineColor = [NSColor colorWithCalibratedRed: 0.0 green: 0.0 blue: 1.0 alpha: 0.35];

  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
  [paragraph setAlignment: NSCenterTextAlignment];
  attributes[NSForegroundColorAttributeName] = [NSColor blueColor];
  attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
  attributes[NSUnderlineColorAttributeName] = underlineColor;
  attributes[NSFontAttributeName] = self.font;
  attributes[NSParagraphStyleAttributeName] = paragraph;

  self.attributedTitle = [[NSAttributedString alloc] initWithString: self.title attributes: attributes];
}  

- (void) resetCursorRects {
  [self addCursorRect: self.bounds cursor: [NSCursor pointingHandCursor]];
}

@end
