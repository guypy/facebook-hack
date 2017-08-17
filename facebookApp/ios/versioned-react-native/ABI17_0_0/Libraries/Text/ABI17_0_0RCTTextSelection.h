/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <ReactABI17_0_0/ABI17_0_0RCTConvert.h>

/**
 * Object containing information about a TextInput's selection.
 */
@interface ABI17_0_0RCTTextSelection : NSObject

@property (nonatomic, assign, readonly) NSInteger start;
@property (nonatomic, assign, readonly) NSInteger end;

- (instancetype)initWithStart:(NSInteger)start end:(NSInteger)end;

@end

@interface ABI17_0_0RCTConvert (ABI17_0_0RCTTextSelection)

+ (ABI17_0_0RCTTextSelection *)ABI17_0_0RCTTextSelection:(id)json;

@end
