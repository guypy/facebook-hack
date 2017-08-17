// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI15_0_0EXAppState.h"
#import "ABI15_0_0EXConstants.h"
#import "ABI15_0_0EXDevSettings.h"
#import "ABI15_0_0EXDisabledDevLoadingView.h"
#import "ABI15_0_0EXDisabledDevMenu.h"
#import "ABI15_0_0EXDisabledRedBox.h"
#import "ABI15_0_0EXFrameExceptionsManager.h"
#import "ABI15_0_0EXKernelModule.h"
#import "ABI15_0_0EXLinkingManager.h"
#import "ABI15_0_0EXVersionManager.h"
#import "ABI15_0_0EXScope.h"
#import "ABI15_0_0EXStatusBarManager.h"

#import <ReactABI15_0_0/ABI15_0_0RCTAssert.h>
#import <ReactABI15_0_0/ABI15_0_0RCTBridge.h>
#import <ReactABI15_0_0/ABI15_0_0RCTBridge+Private.h>
#import <ReactABI15_0_0/ABI15_0_0RCTDevMenu.h>
#import <ReactABI15_0_0/ABI15_0_0RCTDevSettings.h>
#import "ABI15_0_0RCTDevMenu+Device.h"
#import <ReactABI15_0_0/ABI15_0_0RCTLog.h>
#import <ReactABI15_0_0/ABI15_0_0RCTModuleData.h>
#import <ReactABI15_0_0/ABI15_0_0RCTUtils.h>

#import <objc/message.h>

static NSNumber *ABI15_0_0EXVersionManagerIsFirstLoad;

// this is needed because ABI15_0_0RCTPerfMonitor does not declare a public interface
// anywhere that we can import.
@interface ABI15_0_0RCTPerfMonitorDevSettingsHack <NSObject>

- (void)hide;
- (void)show;

@end

@interface ABI15_0_0EXVersionManager ()

// is this the first time this ABI has been touched at runtime?
@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation ABI15_0_0EXVersionManager

- (instancetype)initWithFatalHandler:(void (^)(NSError *))fatalHandler
                         logFunction:(void (^)(NSInteger, NSInteger, NSString *, NSNumber *, NSString *))logFunction
                        logThreshold:(NSInteger)threshold
{
  if (self = [super init]) {
    [self configureABIWithFatalHandler:fatalHandler logFunction:logFunction logThreshold:threshold];
  }
  return self;
}

- (void)bridgeWillStartLoading:(id)bridge
{
  // manually send a "start loading" notif, since the real one happened uselessly inside the ABI15_0_0RCTBatchedBridge constructor
  [[NSNotificationCenter defaultCenter]
   postNotificationName:ABI15_0_0RCTJavaScriptWillStartLoadingNotification object:bridge];
}

- (void)bridgeFinishedLoading
{

}

- (void)bridgeDidForeground
{
  if (_isFirstLoad) {
    _isFirstLoad = NO; // in case the same VersionManager instance is used between multiple bridge loads
  } else {
    // some state is shared between bridges, for example status bar
    [self resetSharedState];
  }
}

- (void)bridgeDidBackground
{
  [self saveSharedState];
}

- (void)saveSharedState
{

}

- (void)resetSharedState
{

}

- (void)invalidate
{

}

- (NSDictionary<NSString *, NSString *> *)devMenuItemsForBridge:(id)bridge
{
  ABI15_0_0RCTDevSettings *devSettings = [self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  NSMutableDictionary *items = [@{
    @"dev-reload": @{ @"label": @"Reload", @"isEnabled": @YES },
    @"dev-inspector": @{ @"label": @"Toggle Element Inspector", @"isEnabled": @YES },
  } mutableCopy];
  if (devSettings.isRemoteDebuggingAvailable) {
    items[@"dev-remote-debug"] = @{
      @"label": (devSettings.isDebuggingRemotely) ? @"Stop Remote Debugging" : @"Debug Remote JS",
      @"isEnabled": @YES
    };
  } else {
    items[@"dev-remote-debug"] =  @{ @"label": @"Remote Debugger Unavailable", @"isEnabled": @NO };
  }
  if (devSettings.isLiveReloadAvailable && !devSettings.isHotLoadingEnabled) {
    items[@"dev-live-reload"] = @{
      @"label": (devSettings.isLiveReloadEnabled) ? @"Disable Live Reload" : @"Enable Live Reload",
      @"isEnabled": @YES,
    };
    items[@"dev-profiler"] = @{
      @"label": (devSettings.isProfilingEnabled) ? @"Stop Systrace" : @"Start Systrace",
      @"isEnabled": @YES,
    };
  } else {
    items[@"dev-live-reload"] =  @{ @"label": @"Live Reload Unavailable", @"isEnabled": @NO };
  }
  if (devSettings.isHotLoadingAvailable && !devSettings.isLiveReloadEnabled) {
    items[@"dev-hmr"] = @{
      @"label": (devSettings.isHotLoadingEnabled) ? @"Disable Hot Reloading" : @"Enable Hot Reloading",
      @"isEnabled": @YES,
    };
  } else {
    items[@"dev-hmr"] =  @{ @"label": @"Hot Reloading Unavailable", @"isEnabled": @NO };
  }
  if (devSettings.isJSCSamplingProfilerAvailable) {
    items[@"dev-jsc-profiler"] = @{ @"label": @"Start / Stop JS Sampling Profiler", @"isEnabled": @YES };
  }
  id perfMonitor = [self _moduleInstanceForBridge:bridge named:@"PerfMonitor"];
  if (perfMonitor) {
    items[@"dev-perf-monitor"] = @{
      @"label": devSettings.isPerfMonitorShown ? @"Hide Perf Monitor" : @"Show Perf Monitor",
      @"isEnabled": @YES,
    };
  }

  return items;
}

- (void)selectDevMenuItemWithKey:(NSString *)key onBridge:(id)bridge
{
  ABI15_0_0RCTAssertMainThread();
  ABI15_0_0RCTDevSettings *devSettings = [self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  if ([key isEqualToString:@"dev-reload"]) {
    [bridge reload];
  } else if ([key isEqualToString:@"dev-remote-debug"]) {
    devSettings.isDebuggingRemotely = !devSettings.isDebuggingRemotely;
  } else if ([key isEqualToString:@"dev-live-reload"]) {
    devSettings.isLiveReloadEnabled = !devSettings.isLiveReloadEnabled;
  } else if ([key isEqualToString:@"dev-profiler"]) {
    devSettings.isProfilingEnabled = !devSettings.isProfilingEnabled;
  } else if ([key isEqualToString:@"dev-hmr"]) {
    devSettings.isHotLoadingEnabled = !devSettings.isHotLoadingEnabled;
  } else if ([key isEqualToString:@"dev-jsc-profiler"]) {
    [devSettings toggleJSCSamplingProfiler];
  } else if ([key isEqualToString:@"dev-inspector"]) {
    [devSettings toggleElementInspector];
  } else if ([key isEqualToString:@"dev-perf-monitor"]) {
    id perfMonitor = [self _moduleInstanceForBridge:bridge named:@"PerfMonitor"];
    if (perfMonitor) {
      if (devSettings.isPerfMonitorShown) {
        [perfMonitor hide];
        devSettings.isPerfMonitorShown = NO;
      } else {
        [perfMonitor show];
        devSettings.isPerfMonitorShown = YES;
      }
    }
  }
}

- (void)showDevMenuForBridge:(id)bridge
{
  ABI15_0_0RCTAssertMainThread();
  id devMenu = [self _moduleInstanceForBridge:bridge named:@"DevMenu"];
  // respondsToSelector: check is required because it's possible this bridge
  // was instantiated with a `disabledDevMenu` instance and the gesture preference was recently updated.
  if ([devMenu respondsToSelector:@selector(show)]) {
    [((ABI15_0_0RCTDevMenu *)devMenu) show];
  }
}

- (void)disableRemoteDebuggingForBridge:(id)bridge
{
  ABI15_0_0RCTDevSettings *devSettings = [self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  devSettings.isDebuggingRemotely = NO;
}

- (void)toggleElementInspectorForBridge:(id)bridge
{
  ABI15_0_0RCTDevSettings *devSettings = [self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  [devSettings toggleElementInspector];
}


#pragma mark - internal

- (id<ABI15_0_0RCTBridgeModule>)_moduleInstanceForBridge:(id)bridge named:(NSString *)name
{
  if ([bridge respondsToSelector:@selector(batchedBridge)]) {
    bridge = [bridge batchedBridge];
  }
  ABI15_0_0RCTModuleData *data = [bridge moduleDataForName:name];
  if (data) {
    return [data instance];
  }
  return nil;
}

- (void)configureABIWithFatalHandler:(void (^)(NSError *))fatalHandler
                         logFunction:(void (^)(NSInteger, NSInteger, NSString *, NSNumber *, NSString *))logFunction
                        logThreshold:(NSInteger)threshold
{
  if (ABI15_0_0EXVersionManagerIsFirstLoad == nil) {
    // first time initializing this RN version at runtime
    _isFirstLoad = YES;
  }
  ABI15_0_0EXVersionManagerIsFirstLoad = @(NO);
  ABI15_0_0RCTSetFatalHandler(fatalHandler);
  ABI15_0_0RCTSetLogThreshold(threshold);
  ABI15_0_0RCTSetLogFunction(logFunction);
}

/**
 *  Expected params:
 *    NSDictionary *manifest
 *    NSDictionary *constants
 *    NSURL *initialUri
 *    @BOOL isDeveloper
 *
 * Kernel-only:
 *    ABI15_0_0EXKernel *kernel
 *    NSArray *supportedSdkVersions
 *    id exceptionsManagerDelegate
 *
 * Frame-only:
 *    ABI15_0_0EXFrame *frame
 */
- (NSArray *)extraModulesWithParams:(NSDictionary *)params
{
  NSURL *initialUri = params[@"initialUri"];
  BOOL isDeveloper = [params[@"isDeveloper"] boolValue];
  ABI15_0_0EXScope *experienceScope = [[ABI15_0_0EXScope alloc] initWithParams:params];

  NSMutableArray *extraModules = [NSMutableArray arrayWithArray:
                                  @[
                                    experienceScope,
                                    [[ABI15_0_0EXAppState alloc] init],
                                    [[ABI15_0_0EXConstants alloc] initWithProperties:params[@"constants"]],
                                    [[ABI15_0_0EXDevSettings alloc] initWithExperienceId:experienceScope.experienceId isDevelopment:isDeveloper],
                                    [[ABI15_0_0EXDisabledDevLoadingView alloc] init],
                                    [[ABI15_0_0EXLinkingManager alloc] initWithInitialUrl:initialUri],
                                    [[ABI15_0_0EXStatusBarManager alloc] init],
                                    ]];
  if (params[@"frame"]) {
    [extraModules addObject:[[ABI15_0_0EXFrameExceptionsManager alloc] initWithDelegate:params[@"frame"]]];
  } else {
    id exceptionsManagerDelegate = params[@"exceptionsManagerDelegate"];
    if (exceptionsManagerDelegate) {
      ABI15_0_0RCTExceptionsManager *exceptionsManager = [[ABI15_0_0RCTExceptionsManager alloc] initWithDelegate:exceptionsManagerDelegate];
      [extraModules addObject:exceptionsManager];
    } else {
      ABI15_0_0RCTLogWarn(@"No exceptions manager provided when building extra modules for bridge.");
    }
  }
  
  if (params[@"kernel"]) {
    ABI15_0_0EXKernelModule *kernel = [[ABI15_0_0EXKernelModule alloc] initWithVersions:params[@"supportedSdkVersions"]];
    kernel.delegate = params[@"kernel"];
    [extraModules addObject:kernel];
  }
  if (params[@"kernel"] && isDeveloper) {
    // kernel enables default ABI15_0_0RCTDevMenu
    [extraModules addObject:[[ABI15_0_0RCTDevMenu alloc] init]];
  } else {
    // non-kernel, or non-development kernel, uses expo menu instead of ABI15_0_0RCTDevMenu
    [extraModules addObject:[[ABI15_0_0EXDisabledDevMenu alloc] init]];
  }
  if (!isDeveloper) {
    // user-facing (not debugging).
    // additionally disable ABI15_0_0RCTRedBox
    [extraModules addObject:[[ABI15_0_0EXDisabledRedBox alloc] init]];
  }
  return extraModules;
}

+ (NSString *)escapedResourceName:(NSString *)name
{
  NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]";
  NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
  return [name stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
