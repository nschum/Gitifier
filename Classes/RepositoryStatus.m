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

+ (instancetype)statusCloning {
    RepositoryStatus *status = [RepositoryStatus new];
    status->_cloning = YES;
    return status;
}

+ (instancetype)statusUpdating {
    RepositoryStatus *status = [RepositoryStatus new];
    status->_updating = YES;
    return status;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
