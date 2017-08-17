/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI13_0_0RCTRawTextManager.h"

#import "ABI13_0_0RCTShadowRawText.h"

@implementation ABI13_0_0RCTRawTextManager

ABI13_0_0RCT_EXPORT_MODULE()

- (ABI13_0_0RCTShadowView *)shadowView
{
  return [ABI13_0_0RCTShadowRawText new];
}

ABI13_0_0RCT_EXPORT_SHADOW_PROPERTY(text, NSString)

@end
