// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI12_0_0EXAppState.h"
#import "ABI12_0_0EXConstants.h"
#import "ABI12_0_0EXDisabledDevLoadingView.h"
#import "ABI12_0_0EXDisabledDevMenu.h"
#import "ABI12_0_0EXDisabledRedBox.h"
#import "ABI12_0_0EXFileSystem.h"
#import "ABI12_0_0EXFrameExceptionsManager.h"
#import "ABI12_0_0EXKernelModule.h"
#import "ABI12_0_0EXLinkingManager.h"
#import "ABI12_0_0EXNotifications.h"
#import "ABI12_0_0EXUnversioned.h"
#import "ABI12_0_0EXVersionManager.h"
#import "ABI12_0_0EXAmplitude.h"
#import "ABI12_0_0EXSegment.h"
#import "ABI12_0_0EXStatusBarManager.h"
#import "ABI12_0_0EXUtil.h"

#import "ABI12_0_0RCTAssert.h"
#import "ABI12_0_0RCTBridge.h"
#import "ABI12_0_0RCTBridge+Private.h"
#import "ABI12_0_0RCTDevMenu.h"
#import "ABI12_0_0RCTDevMenu+Device.h"
#import "ABI12_0_0RCTEventDispatcher.h"
#import "ABI12_0_0RCTLog.h"
#import "ABI12_0_0RCTModuleData.h"
#import "ABI12_0_0RCTUtils.h"

#import <objc/message.h>

typedef NSMutableDictionary <NSString *, NSMutableArray<NSValue *> *> ABI12_0_0EXClassPointerMap;

static ABI12_0_0EXClassPointerMap *ABI12_0_0EXVersionedOnceTokens;
ABI12_0_0EXClassPointerMap *ABI12_0_0EXGetVersionedOnceTokens(void);
ABI12_0_0EXClassPointerMap *ABI12_0_0EXGetVersionedOnceTokens(void)
{
  return ABI12_0_0EXVersionedOnceTokens;
}

@interface ABI12_0_0EXVersionManager ()

// is this the first time this ABI has been touched at runtime?
@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation ABI12_0_0EXVersionManager

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
  // manually send a "start loading" notif, since the real one happened uselessly inside the ABI12_0_0RCTBatchedBridge constructor
  [[NSNotificationCenter defaultCenter]
   postNotificationName:ABI12_0_0RCTJavaScriptWillStartLoadingNotification object:bridge];
}

- (void)bridgeFinishedLoading
{

}

- (void)bridgeDidForeground
{
  if (_isFirstLoad) {
    // reverse the ABI12_0_0RCT-triggered first swap, so the ABI12_0_0RCT implementation is back in its original place
    [self swapSystemMethods];
    _isFirstLoad = NO; // in case the same VersionManager instance is used between multiple bridge loads
  } else {
    // some state is shared between bridges, for example status bar
    [self resetSharedState];
  }

  // now modify system behavior with no swap
  [self setSystemMethods];
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
  [self resetOnceTokens];
}

- (void)showDevMenuForBridge:(id)bridge
{
  [[self _devMenuInstanceForBridge:bridge] show];
}

- (void)disableRemoteDebuggingForBridge:(id)bridge
{
  ABI12_0_0RCTDevMenu *devMenuInstance = [self _devMenuInstanceForBridge:bridge];
  if ([devMenuInstance respondsToSelector:@selector(setExecutorClass:)]) {
    [devMenuInstance performSelector:@selector(setExecutorClass:) withObject:nil];
  }
}

- (void)toggleElementInspectorForBridge:(id)bridge
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [((ABI12_0_0RCTBridge *)bridge).eventDispatcher sendDeviceEventWithName:@"toggleElementInspector" body:nil];
#pragma clang diagnostic pop
}

+ (void)registerOnceToken:(dispatch_once_t *)token forClass:(NSString *)someClass
{
  ABI12_0_0EXClassPointerMap *onceTokens = ABI12_0_0EXGetVersionedOnceTokens();
  if (!onceTokens[someClass]) {
    [onceTokens setObject:[NSMutableArray array] forKey:someClass];
  }
  NSMutableArray<NSValue *> *tokensForClass = onceTokens[someClass];
  for (NSValue *val in tokensForClass) {
    dispatch_once_t *existing = [val pointerValue];
    if (existing == token)
      return;
  }
  [tokensForClass addObject:[NSValue valueWithPointer:token]];
}


#pragma mark - internal

- (ABI12_0_0RCTDevMenu *)_devMenuInstanceForBridge:(id)bridge
{
  if ([bridge respondsToSelector:@selector(batchedBridge)]) {
    bridge = [bridge batchedBridge];
  }
  ABI12_0_0RCTModuleData *data = [bridge moduleDataForName:@"DevMenu"];
  if (data) {
    return [data instance];
  }
  return nil;
}

- (void)configureABIWithFatalHandler:(void (^)(NSError *))fatalHandler
                         logFunction:(void (^)(NSInteger, NSInteger, NSString *, NSNumber *, NSString *))logFunction
                        logThreshold:(NSInteger)threshold
{
  if (ABI12_0_0EXVersionedOnceTokens == nil) {
    // first time initializing this RN version at runtime
    _isFirstLoad = YES;
  }
  ABI12_0_0EXVersionedOnceTokens = [NSMutableDictionary dictionary];
  ABI12_0_0RCTSetFatalHandler(fatalHandler);
  ABI12_0_0RCTSetLogThreshold(threshold);
  ABI12_0_0RCTSetLogFunction(logFunction);
}

- (void)resetOnceTokens
{
  ABI12_0_0EXClassPointerMap *onceTokens = ABI12_0_0EXGetVersionedOnceTokens();
  [onceTokens enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull className, NSMutableArray<NSValue *> * _Nonnull tokensForClass, BOOL * _Nonnull stop) {
    for (NSValue *val in tokensForClass) {
      dispatch_once_t *existing = [val pointerValue];
      *existing = 0;
    }
  }];
}

- (void)swapSystemMethods
{
}

- (void)setSystemMethods
{
}

/**
 *  Expected params:
 *    ABI12_0_0EXFrame *frame
 *    NSDictionary *manifest
 *    NSDictionary *constants
 *    NSURL *initialUri
 *    @BOOL isDeveloper
 */
- (NSArray *)extraModulesWithParams:(NSDictionary *)params
{
  id frame = params[@"frame"];
  NSDictionary *manifest = params[@"manifest"];
  NSURL *initialUri = params[@"initialUri"];
  NSDictionary *constants = params[@"constants"];
  BOOL isDeveloper = [params[@"isDeveloper"] boolValue];
  NSString *experienceId = [manifest objectForKey:@"id"];

  NSMutableArray *extraModules = [NSMutableArray arrayWithArray:
                                  @[
                                    [[ABI12_0_0EXAppState alloc] init],
                                    [[ABI12_0_0EXConstants alloc] initWithProperties:constants],
                                    [[ABI12_0_0EXDisabledDevLoadingView alloc] init],
                                    [[ABI12_0_0EXFileSystem alloc] initWithExperienceId:experienceId],
                                    [[ABI12_0_0EXFrameExceptionsManager alloc] initWithDelegate:frame],
                                    [[ABI12_0_0EXLinkingManager alloc] initWithInitialUrl:initialUri],
                                    [[ABI12_0_0EXNotifications alloc] initWithExperienceId:experienceId],
                                    [[ABI12_0_0EXAmplitude alloc] initWithExperienceId:experienceId],
                                    [[ABI12_0_0EXSegment alloc] init],
                                    [[ABI12_0_0EXStatusBarManager alloc] init],
                                    [[ABI12_0_0EXUtil alloc] init],
                                    ]];

  if (isDeveloper) {
    [extraModules addObjectsFromArray:@[
                                        [[ABI12_0_0RCTDevMenu alloc] init],
                                        ]];
  } else {
    // user-facing (not debugging).
    // additionally disable ABI12_0_0RCTRedBox and ABI12_0_0RCTDevMenu
    [extraModules addObjectsFromArray:@[
                                        [[ABI12_0_0EXDisabledDevMenu alloc] init],
                                        [[ABI12_0_0EXDisabledRedBox alloc] init],
                                        ]];
  }
  return extraModules;
}

/**
 *  Expected params:
 *    ABI12_0_0EXKernel *kernel
 *    NSDictionary *launchOptions
 *    NSDictionary *constants
 *    NSURL *initialUriFromLaunchOptions
 *    NSArray *supportedSdkVersions
 *    id exceptionsManagerDelegate
 */
- (NSArray *)versionedModulesForKernelWithParams:(NSDictionary *)params
{
  NSURL *initialKernelUrl;
  NSDictionary *constants = params[@"constants"];
  
  // used by appetize - override the kernel initial url if there's something in NSUserDefaults
  NSString *launchUrlDefaultsKey = @"EXKernelLaunchUrlDefaultsKey";
  NSString *kernelInitialUrlDefaultsValue = [[NSUserDefaults standardUserDefaults] stringForKey:launchUrlDefaultsKey];
  if (kernelInitialUrlDefaultsValue) {
    initialKernelUrl = [NSURL URLWithString:kernelInitialUrlDefaultsValue];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:launchUrlDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  } else {
    NSURL *initialUriFromLaunchOptions = params[@"initialUriFromLaunchOptions"];
    initialKernelUrl = initialUriFromLaunchOptions;
  }

  NSMutableArray *modules = [NSMutableArray arrayWithArray:
                             @[
                               [[ABI12_0_0EXDisabledDevMenu alloc] init],
                               [[ABI12_0_0EXLinkingManager alloc] initWithInitialUrl:initialKernelUrl],
                               [[ABI12_0_0EXConstants alloc] initWithProperties:constants],
                               ]];
  ABI12_0_0EXKernelModule *kernel = [[ABI12_0_0EXKernelModule alloc] initWithVersions:params[@"supportedSdkVersions"]];
  kernel.delegate = params[@"kernel"];
  [modules addObject:kernel];
  
  id exceptionsManagerDelegate = params[@"exceptionsManagerDelegate"];
  if (exceptionsManagerDelegate) {
    ABI12_0_0RCTExceptionsManager *exceptionsManager = [[ABI12_0_0RCTExceptionsManager alloc] initWithDelegate:exceptionsManagerDelegate];
    [modules addObject:exceptionsManager];
  }
  
#if DEBUG
  // enable redbox only for debug builds
#else
  ABI12_0_0EXDisabledRedBox *disabledRedBox = [[ABI12_0_0EXDisabledRedBox alloc] init];
  [modules addObject:disabledRedBox];
#endif
  
  return modules;
}

+ (NSString *)escapedResourceName:(NSString *)name
{
  NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]";
  NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
  return [name stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
