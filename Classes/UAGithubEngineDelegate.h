//
//  UAGithubEngineDelegate.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol UAGithubEngineDelegate <NSObject>

- (void)requestSucceeded:(NSString *)connectionIdentifier;
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error;


@optional

#pragma mark Connections

- (void)connectionStarted:(NSString *)connectionIdentifier;
- (void)connectionFinished:(NSString *)connectionIdentifier;


#pragma mark Users

- (void)usersReceived:(NSArray *)users forConnection:(NSString *)connectionIdentifier;


#pragma mark Repositories

- (void)repositoriesReceived:(NSArray *)repositories forConnection:(NSString *)connectionIdentifier;
- (void)deployKeysReceived:(NSArray *)deployKeys forConnection:(NSString *)connectionIdentifier;
- (void)collaboratorsReceived:(NSArray *)collaborators forConnection:(NSString *)connectionIdentifier;
- (void)languagesReceived:(NSArray *)languages forConnection:(NSString *)connectionIdentifier;
- (void)tagsReceived:(NSArray *)tags forConnection:(NSString *)connectionIdentifier;
- (void)branchesReceived:(NSArray *)branches forConnection:(NSString *)connectionIdentifier;


#pragma mark Commits

- (void)commitsReceived:(NSArray *)commits forConnection:(NSString *)connectionIdentifier;


#pragma mark Issues

- (void)issuesReceived:(NSArray *)issues forConnection:(NSString *)connectionIdentifier;


#pragma mark Labels

- (void)labelsReceived:(NSArray *)labels forConnection:(NSString *)connectionIdentifier;


#pragma mark Comments

- (void)issueCommentsReceived:(NSArray *)issueComments forConnection:(NSString *)connectionIdentifier;


#pragma mark Trees

- (void)treeReceived:(NSArray *)treeContents forConnection:(NSString *)connectionIdentifier;


#pragma mark Blobs

- (void)blobsReceieved:(NSArray *)blobs forConnection:(NSString *)connectionIdentifier;
- (void)blobReceived:(NSArray *)blob forConnection:(NSString *)connectionIdentifier;
- (void)rawBlobReceived:(NSData *)blob forConnection:(NSString *)connectionIdentifier;


@end
