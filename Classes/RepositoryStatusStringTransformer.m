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
    } else if ([value cloning]) {
        string = @"🕑";
        color = [NSColor yellowColor];
    } else {
        string = @"✓";
        color = [NSColor greenColor];
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSCenterTextAlignment;

    return [[NSAttributedString alloc] initWithString:string
                                           attributes:@{
        NSForegroundColorAttributeName: color,
        NSParagraphStyleAttributeName: paragraphStyle,
    }];
}

@end
