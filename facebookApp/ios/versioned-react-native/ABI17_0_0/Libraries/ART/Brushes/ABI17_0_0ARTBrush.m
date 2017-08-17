/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI17_0_0ARTBrush.h"

#import <ReactABI17_0_0/ABI17_0_0RCTDefines.h>

@implementation ABI17_0_0ARTBrush

- (instancetype)initWithArray:(NSArray *)data
{
  return [super init];
}

ABI17_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

- (BOOL)applyFillColor:(CGContextRef)context
{
  return NO;
}

- (void)paint:(CGContextRef)context
{
  // abstract
}

@end
