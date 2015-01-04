// -------------------------------------------------------
// RepositoriesPanelController.m
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "Git.h"
#import "RepositoriesPanelController.h"
#import "RepositoryListController.h"
#import "Repository.h"

@implementation RepositoriesPanelController

- (id) init {
  return [super initWithNibName: @"RepositoriesPreferencesPanel" bundle: nil];
}

- (NSString *) identifier {
  return @"Repositories";
}

- (NSImage *) toolbarItemImage {
  return [NSImage imageNamed: @"repositories_icon"];
}

- (NSString *) toolbarItemLabel {
  return @"Repositories";
}

- (id) gitClass {
  return [Git class];
}

- (IBAction) removeRepositories: (id) sender {
  [self.repositoryListController removeSelectedRepositories];
}

- (IBAction) showRepositoryError: (id) sender {
  NSInteger row = [sender clickedRow];
  if ([sender clickedColumn] == [sender columnWithIdentifier:@"Status"]) {
    Repository *repository = [self.repositoryListController repositoryList][row];
    NSError *error = repository.lastError;
    if (error) {
      NSAlert *alert = [NSAlert new];
      NSString *url = error.userInfo[NSFilePathErrorKey];
      NSObject *description = error.userInfo[NSLocalizedDescriptionKey];
      alert.messageText = [NSString stringWithFormat:@"%@: %@", url, description];
      alert.informativeText = error.userInfo[NSLocalizedFailureReasonErrorKey];
      [alert beginSheetModalForWindow:self.view.window
                    completionHandler:nil];
    }
  }
}

@end
