@interface RepositoryStatus : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSError *error;

- (instancetype)init;
- (instancetype)initWithError:(NSError *)error;

@end
