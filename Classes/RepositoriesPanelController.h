// -------------------------------------------------------
// RepositoriesPanelController.h
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "MASPreferencesViewController.h"

@class RepositoryListController;

@interface RepositoriesPanelController : NSViewController <MASPreferencesViewController>

@property (strong) IBOutlet RepositoryListController *repositoryListController;
@property (nonatomic, strong, readonly) id gitClass;

- (IBAction) removeRepositories: (id) sender;

@end
