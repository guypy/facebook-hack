/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <ReactABI13_0_0/ABI13_0_0RCTDefines.h>
#import <ReactABI13_0_0/ABI13_0_0RCTJavaScriptExecutor.h>

#if ABI13_0_0RCT_DEV // Debug executors are only supported in dev mode

@interface ABI13_0_0RCTWebSocketExecutor : NSObject <ABI13_0_0RCTJavaScriptExecutor>

- (instancetype)initWithURL:(NSURL *)URL;

@end

#endif
