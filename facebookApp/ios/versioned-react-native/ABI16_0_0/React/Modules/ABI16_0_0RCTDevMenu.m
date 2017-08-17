/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI16_0_0RCTDevMenu.h"

#import "ABI16_0_0RCTDevSettings.h"
#import "ABI16_0_0RCTKeyCommands.h"
#import "ABI16_0_0RCTLog.h"
#import "ABI16_0_0RCTUtils.h"

#if ABI16_0_0RCT_DEV

static NSString *const ABI16_0_0RCTShowDevMenuNotification = @"ABI16_0_0RCTShowDevMenuNotification";

@implementation UIWindow (ABI16_0_0RCTDevMenu)

- (void)ABI16_0_0RCT_motionEnded:(__unused UIEventSubtype)motion withEvent:(UIEvent *)event
{
  if (event.subtype == UIEventSubtypeMotionShake) {
    [[NSNotificationCenter defaultCenter] postNotificationName:ABI16_0_0RCTShowDevMenuNotification object:nil];
  }
}

@end

@implementation ABI16_0_0RCTDevMenuItem
{
  ABI16_0_0RCTDevMenuItemTitleBlock _titleBlock;
  dispatch_block_t _handler;
}

- (instancetype)initWithTitleBlock:(ABI16_0_0RCTDevMenuItemTitleBlock)titleBlock
                           handler:(dispatch_block_t)handler
{
  if ((self = [super init])) {
    _titleBlock = [titleBlock copy];
    _handler = [handler copy];
  }
  return self;
}

ABI16_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

+ (instancetype)buttonItemWithTitleBlock:(NSString *(^)(void))titleBlock handler:(dispatch_block_t)handler
{
  return [[self alloc] initWithTitleBlock:titleBlock handler:handler];
}

+ (instancetype)buttonItemWithTitle:(NSString *)title
                            handler:(dispatch_block_t)handler
{
  return [[self alloc] initWithTitleBlock:^NSString *{ return title; } handler:handler];
}

- (void)callHandler
{
  if (_handler) {
    _handler();
  }
}

- (NSString *)title
{
  if (_titleBlock) {
    return _titleBlock();
  }
  return nil;
}

@end

typedef void(^ABI16_0_0RCTDevMenuAlertActionHandler)(UIAlertAction *action);

@interface ABI16_0_0RCTDevMenu () <ABI16_0_0RCTBridgeModule, ABI16_0_0RCTInvalidating>

@end

@implementation ABI16_0_0RCTDevMenu
{
  UIAlertController *_actionSheet;
  NSMutableArray<ABI16_0_0RCTDevMenuItem *> *_extraMenuItems;
}

@synthesize bridge = _bridge;

+ (NSString *)moduleName { return @"ABI16_0_0RCTDevMenu"; }

- (instancetype)init
{
  if ((self = [super init])) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showOnShake)
                                                 name:ABI16_0_0RCTShowDevMenuNotification
                                               object:nil];
    _extraMenuItems = [NSMutableArray new];

#if TARGET_IPHONE_SIMULATOR
    ABI16_0_0RCTKeyCommands *commands = [ABI16_0_0RCTKeyCommands sharedInstance];
    __weak __typeof(self) weakSelf = self;

    // Toggle debug menu
    [commands registerKeyCommandWithInput:@"d"
                            modifierFlags:UIKeyModifierCommand
                                   action:^(__unused UIKeyCommand *command) {
                                     [weakSelf toggle];
                                   }];

    // Toggle element inspector
    [commands registerKeyCommandWithInput:@"i"
                            modifierFlags:UIKeyModifierCommand
                                   action:^(__unused UIKeyCommand *command) {
                                     [weakSelf.bridge.devSettings toggleElementInspector];
                                   }];

    // Reload in normal mode
    [commands registerKeyCommandWithInput:@"n"
                            modifierFlags:UIKeyModifierCommand
                                   action:^(__unused UIKeyCommand *command) {
                                     [weakSelf.bridge.devSettings setIsDebuggingRemotely:NO];
                                   }];
#endif
  }
  return self;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (void)invalidate
{
  _presentedItems = nil;
  [_actionSheet dismissViewControllerAnimated:YES completion:^(void){}];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showOnShake
{
  if ([_bridge.devSettings isShakeToShowDevMenuEnabled]) {
    [self show];
  }
}

- (void)toggle
{
  if (_actionSheet) {
    [_actionSheet dismissViewControllerAnimated:YES completion:^(void){}];
    _actionSheet = nil;
  } else {
    [self show];
  }
}

- (BOOL)isActionSheetShown
{
  return _actionSheet != nil;
}

- (void)addItem:(NSString *)title handler:(void(^)(void))handler
{
  [self addItem:[ABI16_0_0RCTDevMenuItem buttonItemWithTitle:title handler:handler]];
}

- (void)addItem:(ABI16_0_0RCTDevMenuItem *)item
{
  [_extraMenuItems addObject:item];
}

- (NSArray<ABI16_0_0RCTDevMenuItem *> *)_menuItemsToPresent
{
  NSMutableArray<ABI16_0_0RCTDevMenuItem *> *items = [NSMutableArray new];

  // Add built-in items
  __weak ABI16_0_0RCTBridge *bridge = _bridge;
  __weak ABI16_0_0RCTDevSettings *devSettings = _bridge.devSettings;

  [items addObject:[ABI16_0_0RCTDevMenuItem buttonItemWithTitle:@"Reload" handler:^{
    [bridge reload];
  }]];

  NSString *executorName = devSettings.websocketExecutorName ?: @"Remote JS";
  if (!devSettings.isRemoteDebuggingAvailable) {
    [items addObject:[ABI16_0_0RCTDevMenuItem buttonItemWithTitle:[NSString stringWithFormat:@"%@ Debugger Unavailable", executorName] handler:^{
      UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:[NSString stringWithFormat:@"%@ Debugger Unavailable", executorName]
        message:[NSString stringWithFormat:@"You need to include the ABI16_0_0RCTWebSocket library to enable %@ debugging", executorName]
        preferredStyle:UIAlertControllerStyleAlert];
      [ABI16_0_0RCTPresentedViewController() presentViewController:alertController animated:YES completion:NULL];
    }]];
  } else {
    [items addObject:[ABI16_0_0RCTDevMenuItem buttonItemWithTitleBlock:^NSString *{
      return devSettings.isDebuggingRemotely ?
        [NSString stringWithFormat:@"Stop %@ Debugging", executorName] :
        [NSString stringWithFormat:@"Debug %@", executorName];
    } handler:^{
      devSettings.isDebuggingRemotely = !devSettings.isDebuggingRemotely;
    }]];
  }

  if (devSettings.isLiveReloadAvailable) {
    [items addObject:[ABI16_0_0RCTDevMenuItem buttonItemWithTitleBlock:^NSString *{
      return devSettings.isLiveReloadEnabled ? @"Disable Live Reload" : @"Enable Live Reload";
    } handler:^{
      devSettings.isLiveReloadEnabled = !devSettings.isLiveReloadEnabled;
    }]];
    [items addObject:[ABI16_0_0RCTDevMenuItem buttonItemWithTitleBlock:^NSString *{
      return devSettings.isProfilingEnabled ? @"Stop Systrace" : @"Start Systrace";
    } handler:^{
      devSettings.isProfilingEnabled = !devSettings.isProfilingEnabled;
    }]];
  }

  if (_bridge.devSettings.isHotLoadingAvailable) {
    [items addObject:[ABI16_0_0RCTDevMenuItem buttonItemWithTitleBlock:^NSString *{
      return devSettings.isHotLoadingEnabled ? @"Disable Hot Reloading" : @"Enable Hot Reloading";
    } handler:^{
      devSettings.isHotLoadingEnabled = !devSettings.isHotLoadingEnabled;
    }]];
  }

  if (devSettings.isJSCSamplingProfilerAvailable) {
    // Note: bridge.jsContext is not implemented in the old bridge, so this code is
    // duplicated in ABI16_0_0RCTJSCExecutor
    [items addObject:[ABI16_0_0RCTDevMenuItem buttonItemWithTitle:@"Start / Stop JS Sampling Profiler" handler:^{
      [devSettings toggleJSCSamplingProfiler];
    }]];
  }

  [items addObject:[ABI16_0_0RCTDevMenuItem buttonItemWithTitleBlock:^NSString *{
    return (devSettings.isElementInspectorShown) ? @"Hide Inspector" : @"Show Inspector";
  } handler:^{
    [devSettings toggleElementInspector];
  }]];

  [items addObjectsFromArray:_extraMenuItems];
  return items;
}

ABI16_0_0RCT_EXPORT_METHOD(show)
{
  if (_actionSheet || !_bridge || ABI16_0_0RCTRunningInAppExtension()) {
    return;
  }

  NSString *title = [NSString stringWithFormat:@"ReactABI16_0_0 Native: Development (%@)", [_bridge class]];
  // On larger devices we don't have an anchor point for the action sheet
  UIAlertControllerStyle style = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? UIAlertControllerStyleActionSheet : UIAlertControllerStyleAlert;
  _actionSheet = [UIAlertController alertControllerWithTitle:title
                                                     message:@""
                                              preferredStyle:style];

  NSArray<ABI16_0_0RCTDevMenuItem *> *items = [self _menuItemsToPresent];
  for (ABI16_0_0RCTDevMenuItem *item in items) {
    [_actionSheet addAction:[UIAlertAction actionWithTitle:item.title
                                                     style:UIAlertActionStyleDefault
                                                   handler:[self alertActionHandlerForDevItem:item]]];
  }

  [_actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                   style:UIAlertActionStyleCancel
                                                 handler:[self alertActionHandlerForDevItem:nil]]];

  _presentedItems = items;
  [ABI16_0_0RCTPresentedViewController() presentViewController:_actionSheet animated:YES completion:nil];
}

- (ABI16_0_0RCTDevMenuAlertActionHandler)alertActionHandlerForDevItem:(ABI16_0_0RCTDevMenuItem *__nullable)item
{
  return ^(__unused UIAlertAction *action) {
    if (item) {
      [item callHandler];
    }

    self->_actionSheet = nil;
  };
}

#pragma mark - deprecated methods and properties

#define WARN_DEPRECATED_DEV_MENU_EXPORT() ABI16_0_0RCTLogWarn(@"Using deprecated method %s, use ABI16_0_0RCTDevSettings instead", __func__)

- (void)setShakeToShow:(BOOL)shakeToShow
{
  _bridge.devSettings.isShakeToShowDevMenuEnabled = shakeToShow;
}

- (BOOL)shakeToShow
{
  return _bridge.devSettings.isShakeToShowDevMenuEnabled;
}

ABI16_0_0RCT_EXPORT_METHOD(reload)
{
  WARN_DEPRECATED_DEV_MENU_EXPORT();
  [_bridge reload];
}

ABI16_0_0RCT_EXPORT_METHOD(debugRemotely:(BOOL)enableDebug)
{
  WARN_DEPRECATED_DEV_MENU_EXPORT();
  _bridge.devSettings.isDebuggingRemotely = enableDebug;
}

ABI16_0_0RCT_EXPORT_METHOD(setProfilingEnabled:(BOOL)enabled)
{
  WARN_DEPRECATED_DEV_MENU_EXPORT();
  _bridge.devSettings.isProfilingEnabled = enabled;
}

- (BOOL)profilingEnabled
{
  return _bridge.devSettings.isProfilingEnabled;
}

ABI16_0_0RCT_EXPORT_METHOD(setLiveReloadEnabled:(BOOL)enabled)
{
  WARN_DEPRECATED_DEV_MENU_EXPORT();
  _bridge.devSettings.isLiveReloadEnabled = enabled;
}

- (BOOL)liveReloadEnabled
{
  return _bridge.devSettings.isLiveReloadEnabled;
}

ABI16_0_0RCT_EXPORT_METHOD(setHotLoadingEnabled:(BOOL)enabled)
{
  WARN_DEPRECATED_DEV_MENU_EXPORT();
  _bridge.devSettings.isHotLoadingEnabled = enabled;
}

- (BOOL)hotLoadingEnabled
{
  return _bridge.devSettings.isHotLoadingEnabled;
}

@end

#else // Unavailable when not in dev mode

@implementation ABI16_0_0RCTDevMenu

- (void)show {}
- (void)reload {}
- (void)addItem:(NSString *)title handler:(dispatch_block_t)handler {}
- (void)addItem:(ABI16_0_0RCTDevMenu *)item {}
- (BOOL)isActionSheetShown { return NO; }

@end

@implementation ABI16_0_0RCTDevMenuItem

+ (instancetype)buttonItemWithTitle:(NSString *)title handler:(void(^)(void))handler {return nil;}
+ (instancetype)buttonItemWithTitleBlock:(NSString * (^)(void))titleBlock
                                 handler:(void(^)(void))handler {return nil;}

@end

#endif

@implementation  ABI16_0_0RCTBridge (ABI16_0_0RCTDevMenu)

- (ABI16_0_0RCTDevMenu *)devMenu
{
#if ABI16_0_0RCT_DEV
  return [self moduleForClass:[ABI16_0_0RCTDevMenu class]];
#else
  return nil;
#endif
}

@end
