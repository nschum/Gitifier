@interface RepositoryStatus : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSError *error;
@property (nonatomic, assign, readonly) BOOL cloning;
@property (nonatomic, assign, readonly) BOOL updating;

- (instancetype)init;
- (instancetype)initWithError:(NSError *)error;

+ (instancetype)statusCloning;
+ (instancetype)statusUpdating;

@end
