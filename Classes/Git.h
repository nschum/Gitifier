// -------------------------------------------------------
// Git.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

@interface Git : NSObject

@property (copy) NSString *repositoryUrl;

+ (NSString *) gitExecutable;
+ (void) setGitExecutable: (NSString *) path;
- (id) initWithDelegate: (id) aDelegate;
- (void) runCommand: (NSString *) command inPath: (NSString *) path;
- (void) runCommand: (NSString *) command withArguments: (NSArray *) arguments inPath: (NSString *) path;
- (void) cancelCommands;

@end
