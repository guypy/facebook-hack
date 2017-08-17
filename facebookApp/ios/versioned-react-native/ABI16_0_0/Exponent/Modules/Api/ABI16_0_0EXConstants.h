// Copyright 2015-present 650 Industries. All rights reserved.

#import <ReactABI16_0_0/ABI16_0_0RCTBridgeModule.h>

@interface ABI16_0_0EXConstants : NSObject <ABI16_0_0RCTBridgeModule>

- (instancetype)initWithProperties: (NSDictionary *)props;

+ (NSString *)getExpoClientVersion;

@end
