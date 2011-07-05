// -------------------------------------------------------
// RepositoriesPanelController.h
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MASPreferencesViewController.h"

@class RepositoryListController;

@interface RepositoriesPanelController : NSViewController <MASPreferencesViewController> {
  RepositoryListController *repositoryListController;
}

@property IBOutlet RepositoryListController *repositoryListController;
@property (readonly) id gitClass;

- (IBAction) removeRepositories: (id) sender;

@end
