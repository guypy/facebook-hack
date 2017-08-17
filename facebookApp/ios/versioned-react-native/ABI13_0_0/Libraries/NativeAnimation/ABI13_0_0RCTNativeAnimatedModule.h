/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <ReactABI13_0_0/ABI13_0_0RCTBridgeModule.h>
#import <ReactABI13_0_0/ABI13_0_0RCTEventDispatcher.h>
#import <ReactABI13_0_0/ABI13_0_0RCTEventEmitter.h>

#import "ABI13_0_0RCTValueAnimatedNode.h"

@interface ABI13_0_0RCTNativeAnimatedModule : ABI13_0_0RCTEventEmitter <ABI13_0_0RCTBridgeModule, ABI13_0_0RCTValueAnimatedNodeObserver, ABI13_0_0RCTEventDispatcherObserver>

@end
