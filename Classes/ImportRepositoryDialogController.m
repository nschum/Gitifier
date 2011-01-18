// -------------------------------------------------------
// ImportRepositoryDialogController.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "ImportRepositoryDialogController.h"
#import "Repository.h"
#import "RepositoryListController.h"

@implementation ImportRepositoryDialogController

@synthesize repositoryListController, usernameField, passwordField, importButton, cancelButton, spinner;

- (IBAction) showImportRepositorySheet: (id) sender {
    [usernameField setStringValue: @""];
    [passwordField setStringValue: @""];
    [NSApp beginSheet: [self window]
       modalForWindow: [sender window]
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
}

- (IBAction) cancelImportingRepositories: (id) sender {
    [self hideImportRepositoriesSheet];
}

- (IBAction) importRepositories: (id) sender {
    // Password can be blank - in that case, just import
    // public repos.
    NSString *username = [[usernameField stringValue] psTrimmedString];
    NSString *password = [[passwordField stringValue] psTrimmedString];
    if ([username isEqual: @""] || [password isEqual: @""]) {
        [self showAlertWithTitle: @"Oops" 
                         message: @"Please provide a username & password."];
        return;
    }
    [self lockDialog];
    githubEngine = [[UAGithubEngine alloc] initWithUsername:username 
                                                   password:password 
                                                   delegate:self];
    
    [githubEngine getRepositoriesForUser: username
                          includeWatched: YES];
    
    [githubEngine release];
    
}

- (void) hideImportRepositoriesSheet {
    [NSApp endSheet: self.window];
    [self.window orderOut: self];
}

- (void) showAlertWithTitle: (NSString *) title message: (NSString *) message {
    NSAlert *alertWindow = [[NSAlert alloc] init];
    [alertWindow addButtonWithTitle: @"OK"];
    [alertWindow setMessageText: title];
    [alertWindow setInformativeText: message];
    [alertWindow beginSheetModalForWindow: self.window
                            modalDelegate: self
                           didEndSelector: @selector(modalWasClosed:)
                              contextInfo: nil];
    [NSApp runModalForWindow: self.window];
}

- (void) modalWasClosed: (NSAlert *) alert {
    [NSApp stopModal];
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
    [self showAlertWithTitle: @"Error talking to github"
                     message: [error localizedDescription]];
}

- (void)repositoriesReceived:(NSArray *)repositories forConnection:(NSString *)connectionIdentifier
{
    [self showAlertWithTitle: @"Importing..."
                     message: @"Your repositories will be cloned in the background."];
    [self hideImportRepositoriesSheet];
    
    for(NSDictionary * repo in repositories) {
        // Get the repo URL and construct a usable git URI
        NSString * url = [repo objectForKey: @"url"];
        url = [url stringByReplacingOccurrencesOfString: @"http://"
                                             withString: @"git://"];
        url = [url stringByReplacingOccurrencesOfString: @"https://"
                                             withString: @"git://"];
        url = [NSString stringWithFormat: @"%@.git", url];
        
        // Skip already existing repos
        NSArray *existing = [[repositoryListController repositoryList] valueForKeyPath: @"url"];
        if ([existing indexOfObject: url] != NSNotFound) {
            continue;
        }
        
        editedRepository = [[Repository alloc] initWithUrl: url];
        
        [editedRepository setDelegate: self];
        [editedRepository clone];
    }
    [self unlockDialog];
}

- (void) lockDialog {
    [importButton psDisable];
    [usernameField psDisable];
    [passwordField psDisable];
}

- (void) unlockDialog {
    [importButton psEnable];
    [usernameField psEnable];
    [passwordField psEnable];
}

- (void) repositoryWasCloned: (Repository *) repository {
    [repositoryListController addRepository: repository];
}

- (void) repositoryCouldNotBeCloned: (Repository *) repository {
    [self showAlertWithTitle: @"Repository could not be cloned."
                     message: @"Make sure you have entered a correct URL."];
}

@end
