/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI12_0_0RCTSourceCode.h"

#import "ABI12_0_0RCTDefines.h"
#import "ABI12_0_0RCTAssert.h"
#import "ABI12_0_0RCTBridge.h"
#import "ABI12_0_0RCTUtils.h"

@implementation ABI12_0_0RCTSourceCode

ABI12_0_0RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

- (NSDictionary<NSString *, id> *)constantsToExport
{
  NSString *URL = self.bridge.bundleURL.absoluteString ?: @"";
  return @{@"scriptURL": URL};
}

@end
