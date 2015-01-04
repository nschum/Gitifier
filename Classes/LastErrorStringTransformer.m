#import "LastErrorStringTransformer.h"

@implementation LastErrorStringTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return [super allowsReverseTransformation];
}

- (id)transformedValue:(id)value {
    NSString *string;
    NSColor *color;
    if (value) {
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
