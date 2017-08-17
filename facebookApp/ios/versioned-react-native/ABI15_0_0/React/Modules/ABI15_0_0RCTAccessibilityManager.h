/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <ReactABI15_0_0/ABI15_0_0RCTBridge.h>
#import <ReactABI15_0_0/ABI15_0_0RCTBridgeModule.h>

extern NSString *const ABI15_0_0RCTAccessibilityManagerDidUpdateMultiplierNotification; // posted when multiplier is changed

@interface ABI15_0_0RCTAccessibilityManager : NSObject <ABI15_0_0RCTBridgeModule>

@property (nonatomic, readonly) CGFloat multiplier;

/// map from UIKit categories to multipliers
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *multipliers;

@property (nonatomic, assign) BOOL isVoiceOverEnabled;

@end

@interface ABI15_0_0RCTBridge (ABI15_0_0RCTAccessibilityManager)

@property (nonatomic, readonly) ABI15_0_0RCTAccessibilityManager *accessibilityManager;

@end
