// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI18_0_0EXKeepAwake.h"
#import "ABI18_0_0EXUnversioned.h"

#import <UIKit/UIKit.h>

@implementation ABI18_0_0EXKeepAwake
{
  BOOL _active;
}

@synthesize bridge = _bridge;

ABI18_0_0RCT_EXPORT_MODULE(ExponentKeepAwake);

- (void)setBridge:(ABI18_0_0RCTBridge *)bridge
{
  _bridge = bridge;
  _active = NO;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidForeground:)
                                               name:@"EXKernelBridgeDidForegroundNotification"
                                             object:bridge];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidBackground:)
                                               name:@"EXKernelBridgeDidBackgroundNotification"
                                             object:bridge];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

ABI18_0_0RCT_EXPORT_METHOD(activate)
{
  _active = YES;
  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

ABI18_0_0RCT_EXPORT_METHOD(deactivate)
{
  _active = NO;
  [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)bridgeDidForeground:(NSNotification *)notification
{
  if (_active) {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
  }
}

- (void)bridgeDidBackground:(NSNotification *)notification
{
  [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

@end
