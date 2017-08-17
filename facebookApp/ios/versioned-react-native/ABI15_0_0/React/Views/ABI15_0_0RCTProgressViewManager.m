/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI15_0_0RCTProgressViewManager.h"

#import "ABI15_0_0RCTConvert.h"

@implementation ABI15_0_0RCTConvert (ABI15_0_0RCTProgressViewManager)

ABI15_0_0RCT_ENUM_CONVERTER(UIProgressViewStyle, (@{
  @"default": @(UIProgressViewStyleDefault),
#if !TARGET_OS_TV
  @"bar": @(UIProgressViewStyleBar),
#endif
}), UIProgressViewStyleDefault, integerValue)

@end

@implementation ABI15_0_0RCTProgressViewManager

ABI15_0_0RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [UIProgressView new];
}

ABI15_0_0RCT_EXPORT_VIEW_PROPERTY(progressViewStyle, UIProgressViewStyle)
ABI15_0_0RCT_EXPORT_VIEW_PROPERTY(progress, float)
ABI15_0_0RCT_EXPORT_VIEW_PROPERTY(progressTintColor, UIColor)
ABI15_0_0RCT_EXPORT_VIEW_PROPERTY(trackTintColor, UIColor)
ABI15_0_0RCT_EXPORT_VIEW_PROPERTY(progressImage, UIImage)
ABI15_0_0RCT_EXPORT_VIEW_PROPERTY(trackImage, UIImage)

@end
