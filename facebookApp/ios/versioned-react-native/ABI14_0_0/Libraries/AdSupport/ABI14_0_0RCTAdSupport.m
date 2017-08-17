/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI14_0_0RCTAdSupport.h"

#import <AdSupport/ASIdentifierManager.h>

#import <ReactABI14_0_0/ABI14_0_0RCTUtils.h>

@implementation ABI14_0_0RCTAdSupport

ABI14_0_0RCT_EXPORT_MODULE()

ABI14_0_0RCT_EXPORT_METHOD(getAdvertisingId:(ABI14_0_0RCTResponseSenderBlock)callback
                  withErrorCallback:(ABI14_0_0RCTResponseErrorBlock)errorCallback)
{
  NSUUID *advertisingIdentifier = [ASIdentifierManager sharedManager].advertisingIdentifier;
  if (advertisingIdentifier) {
    callback(@[advertisingIdentifier.UUIDString]);
  } else {
    errorCallback(ABI14_0_0RCTErrorWithMessage(@"Advertising identifier is unavailable."));
  }
}

ABI14_0_0RCT_EXPORT_METHOD(getAdvertisingTrackingEnabled:(ABI14_0_0RCTResponseSenderBlock)callback
                  withErrorCallback:(__unused ABI14_0_0RCTResponseSenderBlock)errorCallback)
{
  callback(@[@([ASIdentifierManager sharedManager].advertisingTrackingEnabled)]);
}

@end
