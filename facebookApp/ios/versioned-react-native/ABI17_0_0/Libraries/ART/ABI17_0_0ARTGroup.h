/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import "ABI17_0_0ARTContainer.h"
#import "ABI17_0_0ARTNode.h"

@interface ABI17_0_0ARTGroup : ABI17_0_0ARTNode <ABI17_0_0ARTContainer>

@property (nonatomic, assign) CGRect clipping;

@end
