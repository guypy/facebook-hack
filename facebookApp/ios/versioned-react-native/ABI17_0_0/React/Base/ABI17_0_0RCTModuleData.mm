/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI17_0_0RCTModuleData.h"

#import <objc/runtime.h>

#include <mutex>

#import "ABI17_0_0RCTBridge.h"
#import "ABI17_0_0RCTBridge+Private.h"
#import "ABI17_0_0RCTModuleMethod.h"
#import "ABI17_0_0RCTLog.h"
#import "ABI17_0_0RCTProfile.h"
#import "ABI17_0_0RCTUtils.h"

@implementation ABI17_0_0RCTModuleData
{
  NSDictionary<NSString *, id> *_constantsToExport;
  NSString *_queueName;
  __weak ABI17_0_0RCTBridge *_bridge;
  std::mutex _instanceLock;
  BOOL _setupComplete;
}

@synthesize methods = _methods;
@synthesize instance = _instance;
@synthesize methodQueue = _methodQueue;

- (void)setUp
{
  _implementsBatchDidComplete = [_moduleClass instancesRespondToSelector:@selector(batchDidComplete)];
  _implementsPartialBatchDidFlush = [_moduleClass instancesRespondToSelector:@selector(partialBatchDidFlush)];

  static IMP objectInitMethod;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    objectInitMethod = [NSObject instanceMethodForSelector:@selector(init)];
  });

  // If a module overrides `init` then we must assume that it expects to be
  // initialized on the main thread, because it may need to access UIKit.
  _requiresMainQueueSetup = !_instance &&
  [_moduleClass instanceMethodForSelector:@selector(init)] != objectInitMethod;

  // If a module overrides `constantsToExport` then we must assume that it
  // must be called on the main thread, because it may need to access UIKit.
  _hasConstantsToExport = [_moduleClass instancesRespondToSelector:@selector(constantsToExport)];
}

- (instancetype)initWithModuleClass:(Class)moduleClass
                             bridge:(ABI17_0_0RCTBridge *)bridge
{
  if ((self = [super init])) {
    _bridge = bridge;
    _moduleClass = moduleClass;
    [self setUp];
  }
  return self;
}

- (instancetype)initWithModuleInstance:(id<ABI17_0_0RCTBridgeModule>)instance
                                bridge:(ABI17_0_0RCTBridge *)bridge
{
  if ((self = [super init])) {
    _bridge = bridge;
    _instance = instance;
    _moduleClass = [instance class];
    [self setUp];
  }
  return self;
}

ABI17_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init);

#pragma mark - private setup methods

- (void)setUpInstanceAndBridge
{
  ABI17_0_0RCT_PROFILE_BEGIN_EVENT(ABI17_0_0RCTProfileTagAlways, @"[ABI17_0_0RCTModuleData setUpInstanceAndBridge] [_instanceLock lock]", @{ @"moduleClass": NSStringFromClass(_moduleClass) });
  {
    std::unique_lock<std::mutex> lock(_instanceLock);

    if (!_setupComplete && _bridge.valid) {
      if (!_instance) {
        if (ABI17_0_0RCT_DEBUG && _requiresMainQueueSetup) {
          ABI17_0_0RCTAssertMainQueue();
        }
        ABI17_0_0RCT_PROFILE_BEGIN_EVENT(ABI17_0_0RCTProfileTagAlways, @"[ABI17_0_0RCTModuleData setUpInstanceAndBridge] [_moduleClass new]",  @{ @"moduleClass": NSStringFromClass(_moduleClass) });
        _instance = [_moduleClass new];
        ABI17_0_0RCT_PROFILE_END_EVENT(ABI17_0_0RCTProfileTagAlways, @"");
        if (!_instance) {
          // Module init returned nil, probably because automatic instantatiation
          // of the module is not supported, and it is supposed to be passed in to
          // the bridge constructor. Mark setup complete to avoid doing more work.
          _setupComplete = YES;
          ABI17_0_0RCTLogWarn(@"The module %@ is returning nil from its constructor. You "
                     "may need to instantiate it yourself and pass it into the "
                     "bridge.", _moduleClass);
        }
      }

      if (_instance && ABI17_0_0RCTProfileIsProfiling()) {
        ABI17_0_0RCTProfileHookInstance(_instance);
      }

      // Bridge must be set before methodQueue is set up, as methodQueue
      // initialization requires it (View Managers get their queue by calling
      // self.bridge.uiManager.methodQueue)
      [self setBridgeForInstance];
    }

    [self setUpMethodQueue];
  }
  ABI17_0_0RCT_PROFILE_END_EVENT(ABI17_0_0RCTProfileTagAlways, @"");

  // This is called outside of the lock in order to prevent deadlock issues
  // because the logic in `finishSetupForInstance` can cause
  // `moduleData.instance` to be accessed re-entrantly.
  if (_bridge.moduleSetupComplete) {
    [self finishSetupForInstance];
  } else {
    // If we're here, then the module is completely initialized,
    // except for what finishSetupForInstance does.  When the instance
    // method is called after moduleSetupComplete,
    // finishSetupForInstance will run.  If _requiresMainQueueSetup
    // is true, getting the instance will block waiting for the main
    // thread, which could take a while if the main thread is busy
    // (I've seen 50ms in testing).  So we clear that flag, since
    // nothing in finishSetupForInstance needs to be run on the main
    // thread.
    _requiresMainQueueSetup = NO;
  }
}

- (void)setBridgeForInstance
{
  if ([_instance respondsToSelector:@selector(bridge)] && _instance.bridge != _bridge) {
    ABI17_0_0RCT_PROFILE_BEGIN_EVENT(ABI17_0_0RCTProfileTagAlways, @"[ABI17_0_0RCTModuleData setBridgeForInstance]", nil);
    @try {
      [(id)_instance setValue:_bridge forKey:@"bridge"];
    }
    @catch (NSException *exception) {
      ABI17_0_0RCTLogError(@"%@ has no setter or ivar for its bridge, which is not "
                  "permitted. You must either @synthesize the bridge property, "
                  "or provide your own setter method.", self.name);
    }
    ABI17_0_0RCT_PROFILE_END_EVENT(ABI17_0_0RCTProfileTagAlways, @"");
  }
}

- (void)finishSetupForInstance
{
  if (!_setupComplete && _instance) {
    ABI17_0_0RCT_PROFILE_BEGIN_EVENT(ABI17_0_0RCTProfileTagAlways, @"[ABI17_0_0RCTModuleData finishSetupForInstance]", nil);
    _setupComplete = YES;
    [_bridge registerModuleForFrameUpdates:_instance withModuleData:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:ABI17_0_0RCTDidInitializeModuleNotification
                                                        object:_bridge
                                                      userInfo:@{@"module": _instance}];
    ABI17_0_0RCT_PROFILE_END_EVENT(ABI17_0_0RCTProfileTagAlways, @"");
  }
}

- (void)setUpMethodQueue
{
  if (_instance && !_methodQueue && _bridge.valid) {
    ABI17_0_0RCT_PROFILE_BEGIN_EVENT(ABI17_0_0RCTProfileTagAlways, @"[ABI17_0_0RCTModuleData setUpMethodQueue]", nil);
    BOOL implementsMethodQueue = [_instance respondsToSelector:@selector(methodQueue)];
    if (implementsMethodQueue && _bridge.valid) {
      _methodQueue = _instance.methodQueue;
    }
    if (!_methodQueue && _bridge.valid) {
      // Create new queue (store queueName, as it isn't retained by dispatch_queue)
      _queueName = [NSString stringWithFormat:@"com.facebook.ReactABI17_0_0.%@Queue", self.name];
      _methodQueue = dispatch_queue_create(_queueName.UTF8String, DISPATCH_QUEUE_SERIAL);

      // assign it to the module
      if (implementsMethodQueue) {
        @try {
          [(id)_instance setValue:_methodQueue forKey:@"methodQueue"];
        }
        @catch (NSException *exception) {
          ABI17_0_0RCTLogError(@"%@ is returning nil for its methodQueue, which is not "
                      "permitted. You must either return a pre-initialized "
                      "queue, or @synthesize the methodQueue to let the bridge "
                      "create a queue for you.", self.name);
        }
      }
    }
    ABI17_0_0RCT_PROFILE_END_EVENT(ABI17_0_0RCTProfileTagAlways, @"");
  }
}

#pragma mark - public getters

- (BOOL)hasInstance
{
  return _instance != nil;
}

- (id<ABI17_0_0RCTBridgeModule>)instance
{
  if (!_setupComplete) {
    ABI17_0_0RCT_PROFILE_BEGIN_EVENT(ABI17_0_0RCTProfileTagAlways, ([NSString stringWithFormat:@"[ABI17_0_0RCTModuleData instanceForClass:%@]", _moduleClass]), nil);
    if (_requiresMainQueueSetup) {
      // The chances of deadlock here are low, because module init very rarely
      // calls out to other threads, however we can't control when a module might
      // get accessed by client code during bridge setup, and a very low risk of
      // deadlock is better than a fairly high risk of an assertion being thrown.
      ABI17_0_0RCT_PROFILE_BEGIN_EVENT(ABI17_0_0RCTProfileTagAlways, @"[ABI17_0_0RCTModuleData instance] main thread setup", nil);

      if (!ABI17_0_0RCTIsMainQueue()) {
        ABI17_0_0RCTLogWarn(@"ABI17_0_0RCTBridge required dispatch_sync to load %@. This may lead to deadlocks", _moduleClass);
      }

      ABI17_0_0RCTUnsafeExecuteOnMainQueueSync(^{
        [self setUpInstanceAndBridge];
      });
      ABI17_0_0RCT_PROFILE_END_EVENT(ABI17_0_0RCTProfileTagAlways, @"");
    } else {
      [self setUpInstanceAndBridge];
    }
    ABI17_0_0RCT_PROFILE_END_EVENT(ABI17_0_0RCTProfileTagAlways, @"");
  }
  return _instance;
}

- (NSString *)name
{
  return ABI17_0_0RCTBridgeModuleNameForClass(_moduleClass);
}

- (NSArray<id<ABI17_0_0RCTBridgeMethod>> *)methods
{
  if (!_methods) {
    NSMutableArray<id<ABI17_0_0RCTBridgeMethod>> *moduleMethods = [NSMutableArray new];

    if ([_moduleClass instancesRespondToSelector:@selector(methodsToExport)]) {
      [moduleMethods addObjectsFromArray:[self.instance methodsToExport]];
    }

    unsigned int methodCount;
    Class cls = _moduleClass;
    while (cls && cls != [NSObject class] && cls != [NSProxy class]) {
      Method *methods = class_copyMethodList(object_getClass(cls), &methodCount);

      for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if ([NSStringFromSelector(selector) hasPrefix:@"__rct_export__"]) {
          IMP imp = method_getImplementation(method);
          NSArray<NSString *> *entries =
            ((NSArray<NSString *> *(*)(id, SEL))imp)(_moduleClass, selector);
          id<ABI17_0_0RCTBridgeMethod> moduleMethod =
            [[ABI17_0_0RCTModuleMethod alloc] initWithMethodSignature:entries[1]
                                                JSMethodName:entries[0]
                                                 moduleClass:_moduleClass];

          [moduleMethods addObject:moduleMethod];
        }
      }

      free(methods);
      cls = class_getSuperclass(cls);
    }

    _methods = [moduleMethods copy];
  }
  return _methods;
}

- (void)gatherConstants
{
  if (_hasConstantsToExport && !_constantsToExport) {
    ABI17_0_0RCT_PROFILE_BEGIN_EVENT(ABI17_0_0RCTProfileTagAlways, ([NSString stringWithFormat:@"[ABI17_0_0RCTModuleData gatherConstants] %@", _moduleClass]), nil);
    (void)[self instance];
    if (!ABI17_0_0RCTIsMainQueue()) {
      ABI17_0_0RCTLogWarn(@"Required dispatch_sync to load constants for %@. This may lead to deadlocks", _moduleClass);
    }

    ABI17_0_0RCTUnsafeExecuteOnMainQueueSync(^{
      self->_constantsToExport = [self->_instance constantsToExport] ?: @{};
    });
    ABI17_0_0RCT_PROFILE_END_EVENT(ABI17_0_0RCTProfileTagAlways, @"");
  }
}

- (NSArray *)config
{
  [self gatherConstants];
  __block NSDictionary<NSString *, id> *constants = _constantsToExport;
  _constantsToExport = nil; // Not needed anymore

  if (constants.count == 0 && self.methods.count == 0) {
    return (id)kCFNull; // Nothing to export
  }

  ABI17_0_0RCT_PROFILE_BEGIN_EVENT(ABI17_0_0RCTProfileTagAlways, ([NSString stringWithFormat:@"[ABI17_0_0RCTModuleData config] %@", _moduleClass]), nil);

  NSMutableArray<NSString *> *methods = self.methods.count ? [NSMutableArray new] : nil;
  NSMutableArray<NSNumber *> *promiseMethods = nil;
  NSMutableArray<NSNumber *> *syncMethods = nil;

  for (id<ABI17_0_0RCTBridgeMethod> method in self.methods) {
    if (method.functionType == ABI17_0_0RCTFunctionTypePromise) {
      if (!promiseMethods) {
        promiseMethods = [NSMutableArray new];
      }
      [promiseMethods addObject:@(methods.count)];
    }
    else if (method.functionType == ABI17_0_0RCTFunctionTypeSync) {
      if (!syncMethods) {
        syncMethods = [NSMutableArray new];
      }
      [syncMethods addObject:@(methods.count)];
    }
    [methods addObject:method.JSMethodName];
  }

  NSArray *config = @[
    self.name,
    ABI17_0_0RCTNullIfNil(constants),
    ABI17_0_0RCTNullIfNil(methods),
    ABI17_0_0RCTNullIfNil(promiseMethods),
    ABI17_0_0RCTNullIfNil(syncMethods)
  ];
  ABI17_0_0RCT_PROFILE_END_EVENT(ABI17_0_0RCTProfileTagAlways, ([NSString stringWithFormat:@"[ABI17_0_0RCTModuleData config] %@", _moduleClass]));
  return config;
}

- (dispatch_queue_t)methodQueue
{
  (void)[self instance];
  return _methodQueue;
}

- (void)invalidate
{
  _methodQueue = nil;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<%@: %p; name=\"%@\">", [self class], self, self.name];
}

@end
