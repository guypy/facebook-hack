/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <ReactABI14_0_0/ABI14_0_0RCTBridgeModule.h>
#import <ReactABI14_0_0/ABI14_0_0RCTInvalidating.h>

/**
 * A simple, asynchronous, persistent, key-value storage system designed as a
 * backend to the AsyncStorage JS module, which is modeled after LocalStorage.
 *
 * Current implementation stores small values in serialized dictionary and
 * larger values in separate files. Since we use a serial file queue
 * `RKFileQueue`, reading/writing from multiple threads should be perceived as
 * being atomic, unless someone bypasses the `ABI14_0_0RCTAsyncLocalStorage` API.
 *
 * Keys and values must always be strings or an error is returned.
 */
@interface ABI14_0_0RCTAsyncLocalStorage : NSObject <ABI14_0_0RCTBridgeModule,ABI14_0_0RCTInvalidating>

@property (nonatomic, assign) BOOL clearOnInvalidate;

@property (nonatomic, readonly, getter=isValid) BOOL valid;

// Clear the ABI14_0_0RCTAsyncLocalStorage data from native code
- (void)clearAllData;

// For clearing data when the bridge may not exist, e.g. when logging out.
+ (void)clearAllData;

@end
