#import "RepositoryStatusStringTransformer.h"
#import "RepositoryStatus.h"

@implementation RepositoryStatusStringTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return [super allowsReverseTransformation];
}

- (id)transformedValue:(id)value {
    NSString *string;
    NSColor *color;
    if ([value error]) {
        string = @"✘";
        color = [NSColor redColor];
    } else {
        string = @"✓";
        color = [NSColor greenColor];
    }
    return [[NSAttributedString alloc] initWithString:string
                                           attributes:@{NSForegroundColorAttributeName: color}];
}

@end
