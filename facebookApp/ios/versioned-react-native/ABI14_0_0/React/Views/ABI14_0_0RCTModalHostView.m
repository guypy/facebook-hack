/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI14_0_0RCTModalHostView.h"

#import "ABI14_0_0RCTAssert.h"
#import "ABI14_0_0RCTBridge.h"
#import "ABI14_0_0RCTModalHostViewController.h"
#import "ABI14_0_0RCTTouchHandler.h"
#import "ABI14_0_0RCTUIManager.h"
#import "UIView+ReactABI14_0_0.h"

#import <UIKit/UIKit.h>

@implementation ABI14_0_0RCTModalHostView
{
  __weak ABI14_0_0RCTBridge *_bridge;
  BOOL _isPresented;
  ABI14_0_0RCTModalHostViewController *_modalViewController;
  ABI14_0_0RCTTouchHandler *_touchHandler;
  UIView *_ReactABI14_0_0Subview;
#if !TARGET_OS_TV
  UIInterfaceOrientation _lastKnownOrientation;
#endif
}

ABI14_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame)
ABI14_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:coder)

- (instancetype)initWithBridge:(ABI14_0_0RCTBridge *)bridge
{
  if ((self = [super initWithFrame:CGRectZero])) {
    _bridge = bridge;
    _modalViewController = [ABI14_0_0RCTModalHostViewController new];
    UIView *containerView = [UIView new];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _modalViewController.view = containerView;
    _touchHandler = [[ABI14_0_0RCTTouchHandler alloc] initWithBridge:bridge];
    _isPresented = NO;

    __weak typeof(self) weakSelf = self;
    _modalViewController.boundsDidChangeBlock = ^(CGRect newBounds) {
      [weakSelf notifyForBoundsChange:newBounds];
    };
  }

  return self;
}

- (void)notifyForBoundsChange:(CGRect)newBounds
{
  if (_ReactABI14_0_0Subview && _isPresented) {
    [_bridge.uiManager setFrame:newBounds forView:_ReactABI14_0_0Subview];
    [self notifyForOrientationChange];
  }
}

- (void)notifyForOrientationChange
{
#if !TARGET_OS_TV
  if (!_onOrientationChange) {
    return;
  }

  UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (currentOrientation == _lastKnownOrientation) {
    return;
  }
  _lastKnownOrientation = currentOrientation;

  BOOL isPortrait = currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown;
  NSDictionary *eventPayload =
  @{
    @"orientation": isPortrait ? @"portrait" : @"landscape",
    };
  _onOrientationChange(eventPayload);
#endif
}

- (void)insertReactABI14_0_0Subview:(UIView *)subview atIndex:(NSInteger)atIndex
{
  ABI14_0_0RCTAssert(_ReactABI14_0_0Subview == nil, @"Modal view can only have one subview");
  [super insertReactABI14_0_0Subview:subview atIndex:atIndex];
  [subview addGestureRecognizer:_touchHandler];
  subview.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                             UIViewAutoresizingFlexibleWidth;

  [_modalViewController.view insertSubview:subview atIndex:0];
  _ReactABI14_0_0Subview = subview;
}

- (void)removeReactABI14_0_0Subview:(UIView *)subview
{
  ABI14_0_0RCTAssert(subview == _ReactABI14_0_0Subview, @"Cannot remove view other than modal view");
  [super removeReactABI14_0_0Subview:subview];
  [subview removeGestureRecognizer:_touchHandler];
  _ReactABI14_0_0Subview = nil;
}

- (void)didUpdateReactABI14_0_0Subviews
{
  // Do nothing, as subview (singular) is managed by `insertReactABI14_0_0Subview:atIndex:`
}

- (void)dismissModalViewController
{
  if (_isPresented) {
    [_delegate dismissModalHostView:self withViewController:_modalViewController animated:[self hasAnimationType]];
    _isPresented = NO;
  }
}

- (void)didMoveToWindow
{
  [super didMoveToWindow];

  if (!_isPresented && self.window) {
    ABI14_0_0RCTAssert(self.ReactABI14_0_0ViewController, @"Can't present modal view controller without a presenting view controller");

#if !TARGET_OS_TV
    _modalViewController.supportedInterfaceOrientations = [self supportedOrientationsMask];
#endif
    if ([self.animationType isEqualToString:@"fade"]) {
      _modalViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    } else if ([self.animationType isEqualToString:@"slide"]) {
      _modalViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    [_delegate presentModalHostView:self withViewController:_modalViewController animated:[self hasAnimationType]];
    _isPresented = YES;
  }
}

- (void)didMoveToSuperview
{
  [super didMoveToSuperview];

  if (_isPresented && !self.superview) {
    [self dismissModalViewController];
  }
}

- (void)invalidate
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self dismissModalViewController];
  });
}

- (BOOL)isTransparent
{
  return _modalViewController.modalPresentationStyle == UIModalPresentationOverFullScreen;
}

- (BOOL)hasAnimationType
{
  return ![self.animationType isEqualToString:@"none"];
}

- (void)setTransparent:(BOOL)transparent
{
  _modalViewController.modalPresentationStyle = transparent ? UIModalPresentationOverFullScreen : UIModalPresentationFullScreen;
}

#if !TARGET_OS_TV
- (UIInterfaceOrientationMask)supportedOrientationsMask
{
  if (_supportedOrientations.count == 0) {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      return UIInterfaceOrientationMaskAll;
    } else {
      return UIInterfaceOrientationMaskPortrait;
    }
  }

  UIInterfaceOrientationMask supportedOrientations = 0;
  for (NSString *orientation in _supportedOrientations) {
    if ([orientation isEqualToString:@"portrait"]) {
      supportedOrientations |= UIInterfaceOrientationMaskPortrait;
    } else if ([orientation isEqualToString:@"portrait-upside-down"]) {
      supportedOrientations |= UIInterfaceOrientationMaskPortraitUpsideDown;
    } else if ([orientation isEqualToString:@"landscape"]) {
      supportedOrientations |= UIInterfaceOrientationMaskLandscape;
    } else if ([orientation isEqualToString:@"landscape-left"]) {
      supportedOrientations |= UIInterfaceOrientationMaskLandscapeLeft;
    } else if ([orientation isEqualToString:@"landscape-right"]) {
      supportedOrientations |= UIInterfaceOrientationMaskLandscapeRight;
    }
  }
  return supportedOrientations;
}
#endif

@end
