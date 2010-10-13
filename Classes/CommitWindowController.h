// -------------------------------------------------------
// CommitWindowController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class Commit;
@class Repository;

@interface CommitWindowController : NSWindowController {
  Repository *repository;
  Commit *commit;
  NSTextView *textView;
  NSTextField *authorLabel;
  NSTextField *dateLabel;
  NSTextField *subjectLabel;
}

@property IBOutlet NSTextView *textView;
@property IBOutlet NSTextField *authorLabel;
@property IBOutlet NSTextField *dateLabel;
@property IBOutlet NSTextField *subjectLabel;

// public
- (id) initWithRepository: (Repository *) aRepository commit: (Commit *) commit;

// private
- (void) loadCommitDiff;
- (void) handleResult: (NSString *) result;
- (void) displayText: (NSString *) text;

@end
