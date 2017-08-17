/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI14_0_0RNSVGRenderableManager.h"

#import "ABI14_0_0RCTConvert+RNSVG.h"
#import "ABI14_0_0RNSVGCGFCRule.h"

@implementation ABI14_0_0RNSVGRenderableManager

ABI14_0_0RCT_EXPORT_MODULE()

- (ABI14_0_0RNSVGRenderable *)node
{
    return [ABI14_0_0RNSVGRenderable new];
}

ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(fill, ABI14_0_0RNSVGBrush)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(fillOpacity, CGFloat)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(fillRule, ABI14_0_0RNSVGCGFCRule)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(stroke, ABI14_0_0RNSVGBrush)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(strokeOpacity, CGFloat)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(strokeWidth, CGFloat)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(strokeLinecap, CGLineCap)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(strokeLinejoin, CGLineJoin)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(strokeDasharray, ABI14_0_0RNSVGCGFloatArray)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(strokeDashoffset, CGFloat)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(strokeMiterlimit, CGFloat)
ABI14_0_0RCT_EXPORT_VIEW_PROPERTY(propList, NSArray<NSString *>)

@end
