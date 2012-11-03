// -------------------------------------------------------
// CommitWindowController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Commit.h"
#import "CommitWindowController.h"
#import "Defaults.h"
#import "Git.h"
#import "Repository.h"

static NSString *ErrorText = @"Error loading commit diff.";
static NSMutableArray *windows;

@implementation CommitWindowController {
  Commit *commit;
  ANSIEscapeHelper *colorConverter;
}

+ (void) initialize {
  windows = [NSMutableArray array];
}

- (id) initWithCommit: (Commit *) aCommit {
  self = [super initWithWindowNibName: @"CommitWindow"];
  if (self) {
    commit = [aCommit copy];
    colorConverter = [[ANSIEscapeHelper alloc] init];

    // prevent window from being deallocated immediately
    [windows addObject: self];
  }
  return self;
}

- (void) windowDidLoad {
  self.window.title = PSFormat(@"%@ – commit %@", commit.repository.name, commit.gitHash);

  self.authorLabel.stringValue = PSFormat(@"%@ <%@>", commit.authorName, commit.authorEmail);
  self.subjectLabel.stringValue = commit.subject;
  [self resizeSubjectLabelToFit];

  [self.textView.textContainer setWidthTracksTextView: NO];
  [self.textView.textContainer setContainerSize: NSMakeSize(1000000, 1000000)];

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateStyle = NSDateFormatterMediumStyle;
  formatter.timeStyle = NSDateFormatterMediumStyle;
  self.dateLabel.stringValue = [formatter stringFromDate: commit.date];

  NSURL *webUrl = [commit.repository webUrlForCommit: commit];
  if (webUrl) {
    [self.viewInBrowserButton setTitle: PSFormat(@"View on %@", webUrl.host)];
  } else {
    [self.viewInBrowserButton psHide];
  }

  [self loadCommitDiff];
}

- (void) windowWillClose: (NSNotification *) notification {
  [windows removeObject: self];
}

- (void) resizeSubjectLabelToFit {
  NSAttributedString *text = self.subjectLabel.attributedStringValue;
  NSSize currentSize = self.subjectLabel.frame.size;
  NSRect requiredFrame = [text boundingRectWithSize: NSMakeSize(currentSize.width, 200.0)
                                            options: NSStringDrawingUsesLineFragmentOrigin];
  CGFloat difference = requiredFrame.size.height - currentSize.height;

  [self.subjectLabel psResizeVerticallyBy: difference];
  [self.subjectLabel psMoveVerticallyBy: -difference];
  [self.window psResizeVerticallyBy: difference];
  [self.window psMoveVerticallyBy: -difference];
  [self.scrollViewBox psResizeVerticallyBy: -difference];
  [self.scrollView psResizeVerticallyBy: -difference];
  [self.separator psMoveVerticallyBy: -difference];
}

- (void) loadCommitDiff {
  Git *git = [[Git alloc] initWithDelegate: self];
  git.repositoryUrl = commit.repository.url;
  NSString *workingCopy = [commit.repository workingCopyDirectory];

  if (workingCopy && [commit.repository directoryExists: workingCopy]) {
    [self.spinner performSelector: @selector(startAnimation:) withObject: self afterDelay: 0.1];
    [git runCommand: @"show" withArguments: @[commit.gitHash, @"--color", @"--pretty=format:%b"] inPath: workingCopy];
  } else {
    [self displayText: ErrorText];
  }
}

- (void) commandCompleted: (NSString *) command output: (NSString *) output {
  NSFont *font = [NSFont fontWithName: @"Monaco" size: 11.0];

  NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
  [text appendAttributedString: [colorConverter attributedStringWithANSIEscapedString: [output psTrimmedString]]];
  [text addAttribute: NSFontAttributeName value: font range: NSMakeRange(0, text.length)];

  [self handleResult: text];
}

- (void) commandFailed: (NSString *) command output: (NSString *) output {
  [self handleResult: ErrorText];
}

- (void) handleResult: (id) result {
  [self performSelectorOnMainThread: @selector(displayText:) withObject: result waitUntilDone: NO];
}

- (void) displayText: (id) text {
  [self.spinner.class cancelPreviousPerformRequestsWithTarget: self.spinner];
  [self.spinner stopAnimation: self];
  if ([text isKindOfClass: [NSAttributedString class]]) {
    [self.textView.textStorage setAttributedString: text];
  } else {
    [self.textView setString: text];
  }
}

- (IBAction) viewInBrowser: (id) sender {
  [[NSWorkspace sharedWorkspace] openURL: [commit.repository webUrlForCommit: commit]];
  [self close];
}

- (void) show {
  [self showWindow: self];
  [NSApp activateIgnoringOtherApps: YES];
}

@end
