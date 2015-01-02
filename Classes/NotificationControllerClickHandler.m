#import "NotificationControllerClickHandler.h"
#import "Defaults.h"
#import "Repository.h"
#import "RepositoryListController.h"
#import "Commit.h"
#import "CommitWindowController.h"

@implementation NotificationControllerClickHandler

- (void) handleClickWithDictionary: (NSDictionary *) clickContext {

  BOOL shouldShowDiffs = [GitifierDefaults boolForKey: ShowDiffWindowKey];
  BOOL shouldOpenInBrowser = [GitifierDefaults boolForKey: OpenDiffInBrowserKey];

  if (clickContext && shouldShowDiffs) {
    NSString *url = clickContext[@"repository"];
    NSDictionary *commitHash = clickContext[@"commit"];
    Repository *repository = [self.repositoryListController findByUrl: url];

    if (repository) {
      Commit *commit = [Commit commitFromDictionary: commitHash];
      commit.repository = repository;
      NSURL *webUrl = [repository webUrlForCommit: commit];

      if (webUrl && shouldOpenInBrowser) {
        [[NSWorkspace sharedWorkspace] openURL: webUrl];
      } else {
        [[[CommitWindowController alloc] initWithCommit: commit] show];
      }
    }
  }
}

@end
