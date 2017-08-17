//
//  NSObject+RNBranch.h
//  ABI18_0_0RNBranch
//
//  Created by Jimmy Dee on 1/26/17.
//  Copyright © 2017 Branch Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABI18_0_0RNBranchProperty;

@interface NSObject(ABI18_0_0RNBranch)

+ (NSDictionary<NSString *, ABI18_0_0RNBranchProperty *> *)supportedProperties;

- (void)setSupportedPropertiesWithMap:(NSDictionary *)map;

@end
