@class Commit;
@class Repository;
@class RepositoryListController;

@protocol NotificationController <NSObject>

- (void)setRepositoryListController: (RepositoryListController *)repositoryListController;

- (void) showNotificationWithCommit: (Commit *) commit;
- (void) showNotificationWithCommitGroup: (NSArray *) commits includesAllCommits: (BOOL) includesAll;
- (void) showNotificationWithCommitGroupIncludingAllCommits: (NSArray *) commits;
- (void) showNotificationWithCommitGroupIncludingSomeCommits: (NSArray *) commits;

- (void) showNotificationWithError: (NSString *) message repository: (Repository *) repository;
- (void) showNotificationWithTitle: (NSString *) title message: (NSString *) message type: (NSString *) type;

@end
