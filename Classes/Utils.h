// -------------------------------------------------------
// Utils.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

#define UserEmailChangedNotification @"UserEmailChangedNotification"
#define GitExecutableSetNotification @"GitExecutableSetNotification"

#define CommitReceivedGrowl @"Commit received"
#define RepositoryUpdateFailedGrowl @"Repository update failed"

@interface NSString (Gitifier)
- (NSString *) MD5Hash;
@end
