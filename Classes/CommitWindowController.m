// -------------------------------------------------------
// CommitWindowController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Commit.h"
#import "CommitWindowController.h"
#import "Git.h"
#import "Repository.h"

#define ERROR_TEXT @"Error loading commit diff."


@implementation CommitWindowController

@synthesize textView, authorLabel, dateLabel, subjectLabel, viewInBrowserButton, spinner;

- (id) initWithRepository: (Repository *) aRepository commit: (Commit *) aCommit {
  self = [super initWithWindowNibName: @"CommitWindow"];
  if (self) {
    repository = aRepository;
    commit = [aCommit copy];
    colorConverter = [[ANSIEscapeHelper alloc] init];
  }
  return self;
}

- (void) windowDidLoad {
  self.window.title = PSFormat(@"%@ – commit %@", repository.name, commit.gitHash);

  authorLabel.stringValue = PSFormat(@"%@ <%@>", commit.authorName, commit.authorEmail);
  subjectLabel.stringValue = commit.subject;

  [textView.textContainer setWidthTracksTextView: NO];
  [textView.textContainer setContainerSize: NSMakeSize(1000000, 1000000)];

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateStyle = NSDateFormatterMediumStyle;
  formatter.timeStyle = NSDateFormatterMediumStyle;
  dateLabel.stringValue = [formatter stringFromDate: commit.date];

  NSURL *webUrl = [repository webUrlForCommit: commit];
  if (webUrl) {
    viewInBrowserButton.title = PSFormat(@"View on %@", webUrl.host);
  } else {
    [viewInBrowserButton psHide];
  }

  [self loadCommitDiff];
}

- (void) loadCommitDiff {
  Git *git = [[Git alloc] initWithDelegate: self];
  git.repositoryUrl = repository.url;
  NSString *workingCopy = [repository workingCopyDirectory];

  if (workingCopy && [repository directoryExists: workingCopy]) {
    [spinner performSelector: @selector(startAnimation:) withObject: self afterDelay: 0.1];
    [git runCommand: @"show" withArguments: PSArray(commit.gitHash, @"--color=always", @"--format=%b") inPath: workingCopy];
  } else {
    [self displayText: ERROR_TEXT];
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
  [self handleResult: ERROR_TEXT];
}

- (void) handleResult: (id) result {
  [self performSelectorOnMainThread: @selector(displayText:) withObject: result waitUntilDone: NO];
}

- (void) displayText: (id) text {
  [[spinner class] cancelPreviousPerformRequestsWithTarget: spinner];
  [spinner stopAnimation: self];
  if ([text isKindOfClass: [NSAttributedString class]]) {
    [textView.textStorage setAttributedString: text];
  } else {
    textView.string = text;
  }
}

- (IBAction) viewInBrowser: (id) sender {
  [[NSWorkspace sharedWorkspace] openURL: [repository webUrlForCommit: commit]];
  [self close];
}

@end
