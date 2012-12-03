@class RepositoryListController;

@interface NotificationControllerClickHandler : NSObject

@property RepositoryListController *repositoryListController;

- (void) handleClickWithDictionary: (NSDictionary *) dictionary;

@end
