#import "NSImage+GitifierTint.h"

@implementation NSImage (GitifierTint)

- (NSImage *)gitifier_imageWithOverlayColor:(NSColor *)color {

    return [NSImage imageWithSize:self.size
                          flipped:false
                   drawingHandler:^BOOL(NSRect rect) {

        [self drawInRect:rect];

        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextSetBlendMode(context, kCGBlendModeSourceIn);

        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);

        return YES;
    }];
}

@end
