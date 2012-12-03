@class Commit;
@class Repository;
@class RepositoryListController;

@protocol NotificationController <NSObject>

- (void)setRepositoryListController: (RepositoryListController *)repositoryListController;

- (void) showGrowlWithCommit: (Commit *) commit;
- (void) showGrowlWithCommitGroup: (NSArray *) commits includesAllCommits: (BOOL) includesAll;
- (void) showGrowlWithCommitGroupIncludingAllCommits: (NSArray *) commits;
- (void) showGrowlWithCommitGroupIncludingSomeCommits: (NSArray *) commits;

- (void) showGrowlWithError: (NSString *) message repository: (Repository *) repository;
- (void) showGrowlWithTitle: (NSString *) title message: (NSString *) message type: (NSString *) type;

@end
