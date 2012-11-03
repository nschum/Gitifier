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

@property /*(weak)*/ IBOutlet NSTextView *textView;
@property /*(weak)*/ IBOutlet NSTextField *authorLabel;
@property /*(weak)*/ IBOutlet NSTextField *dateLabel;
@property /*(weak)*/ IBOutlet NSTextField *subjectLabel;
@property /*(weak)*/ IBOutlet NSButton *viewInBrowserButton;
@property /*(weak)*/ IBOutlet NSProgressIndicator *spinner;
@property /*(weak)*/ IBOutlet NSScrollView *scrollView;
@property /*(weak)*/ IBOutlet NSBox *scrollViewBox;
@property /*(weak)*/ IBOutlet NSBox *separator;

- (id) initWithCommit: (Commit *) commit;
- (void) show;
- (IBAction) viewInBrowser: (id) sender;

@end
