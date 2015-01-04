#import "RepositoryStatus.h"

@implementation RepositoryStatus

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithError:(NSError *)error {
    self = [self init];
    if (self) {
        _error = [error copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
