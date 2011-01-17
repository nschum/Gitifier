// -------------------------------------------------------
// ImportRepositoryDialogController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "ImportRepositoryDialogController.h"


@implementation ImportRepositoryDialogController

- (IBAction) showImportRepositorySheet: (id) sender {
    [NSApp beginSheet: [self window]
       modalForWindow: [sender window]
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
}

@end
