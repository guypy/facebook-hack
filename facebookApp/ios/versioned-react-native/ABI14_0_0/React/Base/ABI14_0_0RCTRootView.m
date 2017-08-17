/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI14_0_0RCTRootView.h"
#import "ABI14_0_0RCTRootViewDelegate.h"
#import "ABI14_0_0RCTRootViewInternal.h"

#import <objc/runtime.h>

#import "ABI14_0_0RCTAssert.h"
#import "ABI14_0_0RCTBridge.h"
#import "ABI14_0_0RCTBridge+Private.h"
#import "ABI14_0_0RCTEventDispatcher.h"
#import "ABI14_0_0RCTKeyCommands.h"
#import "ABI14_0_0RCTLog.h"
#import "ABI14_0_0RCTPerformanceLogger.h"
#import "ABI14_0_0RCTTouchHandler.h"
#import "ABI14_0_0RCTUIManager.h"
#import "ABI14_0_0RCTUtils.h"
#import "ABI14_0_0RCTView.h"
#import "UIView+ReactABI14_0_0.h"
#import "ABI14_0_0RCTProfile.h"

#if TARGET_OS_TV
#import "ABI14_0_0RCTTVRemoteHandler.h"
#import "ABI14_0_0RCTTVNavigationEventEmitter.h"
#endif

NSString *const ABI14_0_0RCTContentDidAppearNotification = @"ABI14_0_0RCTContentDidAppearNotification";

@interface ABI14_0_0RCTUIManager (ABI14_0_0RCTRootView)

- (NSNumber *)allocateRootTag;

@end

@interface ABI14_0_0RCTRootContentView : ABI14_0_0RCTView <ABI14_0_0RCTInvalidating, UIGestureRecognizerDelegate>

@property (nonatomic, readonly) BOOL contentHasAppeared;
@property (nonatomic, readonly, strong) ABI14_0_0RCTTouchHandler *touchHandler;
@property (nonatomic, assign) BOOL passThroughTouches;

- (instancetype)initWithFrame:(CGRect)frame
                       bridge:(ABI14_0_0RCTBridge *)bridge
                     ReactABI14_0_0Tag:(NSNumber *)ReactABI14_0_0Tag
               sizeFlexiblity:(ABI14_0_0RCTRootViewSizeFlexibility)sizeFlexibility NS_DESIGNATED_INITIALIZER;
@end

@implementation ABI14_0_0RCTRootView
{
  ABI14_0_0RCTBridge *_bridge;
  NSString *_moduleName;
  NSDictionary *_launchOptions;
  ABI14_0_0RCTRootContentView *_contentView;
}

- (instancetype)initWithBridge:(ABI14_0_0RCTBridge *)bridge
                    moduleName:(NSString *)moduleName
             initialProperties:(NSDictionary *)initialProperties
{
  ABI14_0_0RCTAssertMainQueue();
  ABI14_0_0RCTAssert(bridge, @"A bridge instance is required to create an ABI14_0_0RCTRootView");
  ABI14_0_0RCTAssert(moduleName, @"A moduleName is required to create an ABI14_0_0RCTRootView");

  ABI14_0_0RCT_PROFILE_BEGIN_EVENT(ABI14_0_0RCTProfileTagAlways, @"-[ABI14_0_0RCTRootView init]", nil);

  if ((self = [super initWithFrame:CGRectZero])) {

    self.backgroundColor = [UIColor whiteColor];

    _bridge = bridge;
    _moduleName = moduleName;
    _appProperties = [initialProperties copy];
    _loadingViewFadeDelay = 0.25;
    _loadingViewFadeDuration = 0.25;
    _sizeFlexibility = ABI14_0_0RCTRootViewSizeFlexibilityNone;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bridgeDidReload)
                                                 name:ABI14_0_0RCTJavaScriptWillStartLoadingNotification
                                               object:_bridge];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(javaScriptDidLoad:)
                                                 name:ABI14_0_0RCTJavaScriptDidLoadNotification
                                               object:_bridge];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoadingView)
                                                 name:ABI14_0_0RCTContentDidAppearNotification
                                               object:self];

#if TARGET_OS_TV
    self.tvRemoteHandler = [ABI14_0_0RCTTVRemoteHandler new];
    for (UIGestureRecognizer *gr in self.tvRemoteHandler.tvRemoteGestureRecognizers) {
      [self addGestureRecognizer:gr];
    }
#endif

    if (!_bridge.loading) {
      [self bundleFinishedLoading:[_bridge batchedBridge]];
    }

    [self showLoadingView];
  }

  ABI14_0_0RCT_PROFILE_END_EVENT(ABI14_0_0RCTProfileTagAlways, @"");

  return self;
}

- (instancetype)initWithBundleURL:(NSURL *)bundleURL
                       moduleName:(NSString *)moduleName
                initialProperties:(NSDictionary *)initialProperties
                    launchOptions:(NSDictionary *)launchOptions
{
  ABI14_0_0RCTBridge *bridge = [[ABI14_0_0RCTBridge alloc] initWithBundleURL:bundleURL
                                            moduleProvider:nil
                                             launchOptions:launchOptions];

  return [self initWithBridge:bridge moduleName:moduleName initialProperties:initialProperties];
}

ABI14_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame)
ABI14_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder)

#if TARGET_OS_TV
- (UIView *)preferredFocusedView
{
  if (self.ReactABI14_0_0PreferredFocusedView) {
    return self.ReactABI14_0_0PreferredFocusedView;
  }
  return [super preferredFocusedView];
}
#endif

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
  super.backgroundColor = backgroundColor;
  _contentView.backgroundColor = backgroundColor;
}

- (BOOL)passThroughTouches
{
  return _contentView.passThroughTouches;
}

- (void)setPassThroughTouches:(BOOL)passThroughTouches
{
  _contentView.passThroughTouches = passThroughTouches;
}

- (UIViewController *)ReactABI14_0_0ViewController
{
  return _ReactABI14_0_0ViewController ?: [super ReactABI14_0_0ViewController];
}

- (BOOL)canBecomeFirstResponder
{
  return YES;
}

- (void)setLoadingView:(UIView *)loadingView
{
  _loadingView = loadingView;
  if (!_contentView.contentHasAppeared) {
    [self showLoadingView];
  }
}

- (void)showLoadingView
{
  if (_loadingView && !_contentView.contentHasAppeared) {
    _loadingView.hidden = NO;
    [self addSubview:_loadingView];
  }
}

- (void)hideLoadingView
{
  if (_loadingView.superview == self && _contentView.contentHasAppeared) {
    if (_loadingViewFadeDuration > 0) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_loadingViewFadeDelay * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{

                       [UIView transitionWithView:self
                                         duration:self->_loadingViewFadeDuration
                                          options:UIViewAnimationOptionTransitionCrossDissolve
                                       animations:^{
                                         self->_loadingView.hidden = YES;
                                       } completion:^(__unused BOOL finished) {
                                         [self->_loadingView removeFromSuperview];
                                       }];
                     });
    } else {
      _loadingView.hidden = YES;
      [_loadingView removeFromSuperview];
    }
  }
}

- (NSNumber *)ReactABI14_0_0Tag
{
  ABI14_0_0RCTAssertMainQueue();
  if (!super.ReactABI14_0_0Tag) {
    /**
     * Every root view that is created must have a unique ReactABI14_0_0 tag.
     * Numbering of these tags goes from 1, 11, 21, 31, etc
     *
     * NOTE: Since the bridge persists, the RootViews might be reused, so the
     * ReactABI14_0_0 tag must be re-assigned every time a new UIManager is created.
     */
    self.ReactABI14_0_0Tag = [_bridge.uiManager allocateRootTag];
  }
  return super.ReactABI14_0_0Tag;
}

- (void)bridgeDidReload
{
  ABI14_0_0RCTAssertMainQueue();
  // Clear the ReactABI14_0_0Tag so it can be re-assigned
  self.ReactABI14_0_0Tag = nil;
}

- (void)javaScriptDidLoad:(NSNotification *)notification
{
  ABI14_0_0RCTAssertMainQueue();

  // Use the (batched) bridge that's sent in the notification payload, so the
  // ABI14_0_0RCTRootContentView is scoped to the right bridge
  ABI14_0_0RCTBridge *bridge = notification.userInfo[@"bridge"];
  [self bundleFinishedLoading:bridge];
}

- (void)bundleFinishedLoading:(ABI14_0_0RCTBridge *)bridge
{
  if (!bridge.valid) {
    return;
  }

  [_contentView removeFromSuperview];
  _contentView = [[ABI14_0_0RCTRootContentView alloc] initWithFrame:self.bounds
                                                    bridge:bridge
                                                  ReactABI14_0_0Tag:self.ReactABI14_0_0Tag
                                            sizeFlexiblity:_sizeFlexibility];
  [self runApplication:bridge];

  _contentView.backgroundColor = self.backgroundColor;
  [self insertSubview:_contentView atIndex:0];

  if (_sizeFlexibility == ABI14_0_0RCTRootViewSizeFlexibilityNone) {
    self.intrinsicSize = self.bounds.size;
  }
}

- (void)runApplication:(ABI14_0_0RCTBridge *)bridge
{
  NSString *moduleName = _moduleName ?: @"";
  NSDictionary *appParameters = @{
    @"rootTag": _contentView.ReactABI14_0_0Tag,
    @"initialProps": _appProperties ?: @{},
  };

  ABI14_0_0RCTLogInfo(@"Running application %@ (%@)", moduleName, appParameters);
  [bridge enqueueJSCall:@"AppRegistry"
                 method:@"runApplication"
                   args:@[moduleName, appParameters]
             completion:NULL];
}

- (void)setSizeFlexibility:(ABI14_0_0RCTRootViewSizeFlexibility)sizeFlexibility
{
  _sizeFlexibility = sizeFlexibility;
  [self setNeedsLayout];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  _contentView.frame = self.bounds;
  _loadingView.center = (CGPoint){
    CGRectGetMidX(self.bounds),
    CGRectGetMidY(self.bounds)
  };
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  // The root view itself should never receive touches
  UIView *hitView = [super hitTest:point withEvent:event];
  if (self.passThroughTouches && hitView == self) {
    return nil;
  }
  return hitView;
}

- (void)setAppProperties:(NSDictionary *)appProperties
{
  ABI14_0_0RCTAssertMainQueue();

  if ([_appProperties isEqualToDictionary:appProperties]) {
    return;
  }

  _appProperties = [appProperties copy];

  if (_contentView && _bridge.valid && !_bridge.loading) {
    [self runApplication:_bridge];
  }
}

- (void)setIntrinsicSize:(CGSize)intrinsicSize
{
  BOOL oldSizeHasAZeroDimension = _intrinsicSize.height == 0 || _intrinsicSize.width == 0;
  BOOL newSizeHasAZeroDimension = intrinsicSize.height == 0 || intrinsicSize.width == 0;
  BOOL bothSizesHaveAZeroDimension = oldSizeHasAZeroDimension && newSizeHasAZeroDimension;

  BOOL sizesAreEqual = CGSizeEqualToSize(_intrinsicSize, intrinsicSize);

  _intrinsicSize = intrinsicSize;

  // Don't notify the delegate if the content remains invisible or its size has not changed
  if (bothSizesHaveAZeroDimension || sizesAreEqual) {
    return;
  }

  [_delegate rootViewDidChangeIntrinsicSize:self];
}

- (void)contentViewInvalidated
{
  [_contentView removeFromSuperview];
  _contentView = nil;
  [self showLoadingView];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_contentView invalidate];
}

- (void)cancelTouches
{
  [[_contentView touchHandler] cancel];
}

@end

@implementation ABI14_0_0RCTUIManager (ABI14_0_0RCTRootView)

- (NSNumber *)allocateRootTag
{
  NSNumber *rootTag = objc_getAssociatedObject(self, _cmd) ?: @1;
  objc_setAssociatedObject(self, _cmd, @(rootTag.integerValue + 10), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  return rootTag;
}

@end

@implementation ABI14_0_0RCTRootContentView
{
  __weak ABI14_0_0RCTBridge *_bridge;
  UIColor *_backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame
                       bridge:(ABI14_0_0RCTBridge *)bridge
                     ReactABI14_0_0Tag:(NSNumber *)ReactABI14_0_0Tag
               sizeFlexiblity:(ABI14_0_0RCTRootViewSizeFlexibility)sizeFlexibility
{
  if ((self = [super initWithFrame:frame])) {
    _bridge = bridge;
    self.ReactABI14_0_0Tag = ReactABI14_0_0Tag;
    _touchHandler = [[ABI14_0_0RCTTouchHandler alloc] initWithBridge:_bridge];
    _touchHandler.delegate = self;
    [self addGestureRecognizer:_touchHandler];
    [_bridge.uiManager registerRootView:self withSizeFlexibility:sizeFlexibility];
    self.layer.backgroundColor = NULL;
  }
  return self;
}

ABI14_0_0RCT_NOT_IMPLEMENTED(-(instancetype)initWithFrame:(CGRect)frame)
ABI14_0_0RCT_NOT_IMPLEMENTED(-(instancetype)initWithCoder:(nonnull NSCoder *)aDecoder)

- (void)insertReactABI14_0_0Subview:(UIView *)subview atIndex:(NSInteger)atIndex
{
  [super insertReactABI14_0_0Subview:subview atIndex:atIndex];
  [_bridge.performanceLogger markStopForTag:ABI14_0_0RCTPLTTI];
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!self->_contentHasAppeared) {
      self->_contentHasAppeared = YES;
      [[NSNotificationCenter defaultCenter] postNotificationName:ABI14_0_0RCTContentDidAppearNotification
                                                          object:self.superview];
    }
  });
}

- (void)setFrame:(CGRect)frame
{
  super.frame = frame;
  if (self.ReactABI14_0_0Tag && _bridge.isValid) {
    [_bridge.uiManager setFrame:frame forView:self];
  }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
  _backgroundColor = backgroundColor;
  if (self.ReactABI14_0_0Tag && _bridge.isValid) {
    [_bridge.uiManager setBackgroundColor:backgroundColor forView:self];
  }
}

- (UIColor *)backgroundColor
{
  return _backgroundColor;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  // The root content view itself should never receive touches
  UIView *hitView = [super hitTest:point withEvent:event];
  if (_passThroughTouches && hitView == self) {
    return nil;
  }
  return hitView;
}

- (void)invalidate
{
  if (self.userInteractionEnabled) {
    self.userInteractionEnabled = NO;
    [(ABI14_0_0RCTRootView *)self.superview contentViewInvalidated];
    [_bridge enqueueJSCall:@"AppRegistry"
                    method:@"unmountApplicationComponentAtRootTag"
                      args:@[self.ReactABI14_0_0Tag]
                completion:NULL];
  }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  if (![gestureRecognizer isKindOfClass:[ABI14_0_0RCTTouchHandler class]]) {
    return YES;
  }

  UIView *currentView = touch.view;
  while (currentView && ![currentView isReactABI14_0_0RootView]) {
    currentView = currentView.superview;
  }
  return currentView == self;
}


@end
