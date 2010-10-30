// -------------------------------------------------------
// CommitWindowController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "ANSIEscapeHelper.h"

@class Commit;
@class Repository;

@interface CommitWindowController : NSWindowController {
  Repository *repository;
  Commit *commit;
  NSTextView *textView;
  NSTextField *authorLabel;
  NSTextField *dateLabel;
  NSTextField *subjectLabel;
  ANSIEscapeHelper *colorConverter;
  NSButton *viewInBrowserButton;
  NSProgressIndicator *spinner;
}

@property IBOutlet NSTextView *textView;
@property IBOutlet NSTextField *authorLabel;
@property IBOutlet NSTextField *dateLabel;
@property IBOutlet NSTextField *subjectLabel;
@property IBOutlet NSButton *viewInBrowserButton;
@property IBOutlet NSProgressIndicator *spinner;

// public
- (id) initWithRepository: (Repository *) aRepository commit: (Commit *) commit;
- (IBAction) viewInBrowser: (id) sender;

// private
- (void) loadCommitDiff;
- (void) handleResult: (id) result;
- (void) displayText: (id) text;
- (void) resizeLabelToFit: (NSControl *) label;

@end
