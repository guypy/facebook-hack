// Copyright 2015-present 650 Industries. All rights reserved.

#import <ReactABI18_0_0/ABI18_0_0RCTBridge.h>
#import <ReactABI18_0_0/ABI18_0_0RCTBridgeModule.h>

/**
 * Provides a place to put variables scoped per-experience that are
 * easily accessible from all native modules through `self.bridge.exScope`
 */

@interface ABI18_0_0EXScope : NSObject <ABI18_0_0RCTBridgeModule>

// TODO: audit this interface once we formalize kernelspace module logic.
@property (nonatomic, readonly) NSURL *initialUri;
@property (nonatomic, readonly) NSString *experienceId;
@property (nonatomic, readonly) NSString *documentDirectory;
@property (nonatomic, readonly) NSString *cachesDirectory;
@property (nonatomic, readonly) NSString *apnsToken;
@property (nonatomic, readonly) NSString *appOwnership;

- (instancetype)initWithParams:(NSDictionary *)params;

- (NSString *)scopedPathWithPath:(NSString *)path withOptions:(NSDictionary *)options;

@end

@interface ABI18_0_0RCTBridge (ABI18_0_0EXScope)

@property (nonatomic, readonly) ABI18_0_0EXScope *experienceScope;

@end
