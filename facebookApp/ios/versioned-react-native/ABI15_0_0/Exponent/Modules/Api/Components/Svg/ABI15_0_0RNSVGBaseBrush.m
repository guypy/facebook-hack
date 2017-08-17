/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI15_0_0RNSVGBaseBrush.h"
#import "ABI15_0_0RCTConvert+RNSVG.h"
#import <ReactABI15_0_0/ABI15_0_0RCTLog.h>

@implementation ABI15_0_0RNSVGBaseBrush

- (instancetype)initWithArray:(NSArray *)array
{
    if ((self = [super initWithArray:array])) {
        if (array.count != 2) {
            ABI15_0_0RCTLogError(@"-[%@ %@] expects 2 elements, received %@",
                        self.class, NSStringFromSelector(_cmd), array);
            return nil;
        }
        
        self.brushRef = [array objectAtIndex:1];
    }
    return self;
}

- (void)paint:(CGContextRef)context opacity:(CGFloat)opacity brushConverter:(ABI15_0_0RNSVGBrushConverter *)brushConverter
{
    BOOL transparency = opacity < 1;
    if (transparency) {
        CGContextSetAlpha(context, opacity);
        CGContextBeginTransparencyLayer(context, NULL);
    }
    
    if (brushConverter.type == kABI15_0_0RNSVGLinearGradient) {
        [brushConverter drawLinearGradient:context];
    } else if (brushConverter.type == kABI15_0_0RNSVGRadialGradient) {
        [brushConverter drawRidialGradient:context];
    } else if (brushConverter.type == kABI15_0_0RNSVGPattern) {
        // todo:
    }
    
    if (transparency) {
        CGContextEndTransparencyLayer(context);
    }
}

@end
