// -------------------------------------------------------
// CommitWindowController.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "ANSIEscapeHelper.h"

@class Commit;
@class Repository;

@interface CommitWindowController : NSWindowController

@property IBOutlet NSTextView *textView;
@property IBOutlet NSTextField *authorLabel;
@property IBOutlet NSTextField *dateLabel;
@property IBOutlet NSTextField *subjectLabel;
@property IBOutlet NSButton *viewInBrowserButton;
@property IBOutlet NSProgressIndicator *spinner;
@property IBOutlet NSScrollView *scrollView;
@property IBOutlet NSBox *scrollViewBox;
@property IBOutlet NSBox *separator;

- (id) initWithCommit: (Commit *) commit;
- (void) show;
- (IBAction) viewInBrowser: (id) sender;

@end
