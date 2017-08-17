/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI16_0_0RCTTVNavigationEventEmitter.h"

NSString *const ABI16_0_0RCTTVNavigationEventNotification = @"ABI16_0_0RCTTVNavigationEventNotification";

static NSString *const TVNavigationEventName = @"onTVNavEvent";

@implementation ABI16_0_0RCTTVNavigationEventEmitter

ABI16_0_0RCT_EXPORT_MODULE()

- (instancetype)init
{
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTVNavigationEventNotification:)
                                                 name:ABI16_0_0RCTTVNavigationEventNotification
                                               object:nil];

  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[TVNavigationEventName];
}

- (void)handleTVNavigationEventNotification:(NSNotification *)notif
{
  [self sendEventWithName:TVNavigationEventName body:notif.object];
}

@end
