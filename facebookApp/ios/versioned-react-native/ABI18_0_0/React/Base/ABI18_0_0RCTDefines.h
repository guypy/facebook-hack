/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#if __OBJC__
#  import <Foundation/Foundation.h>
#endif

/**
 * Make global functions usable in C++
 */
#if defined(__cplusplus)
#define ABI18_0_0RCT_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define ABI18_0_0RCT_EXTERN extern __attribute__((visibility("default")))
#endif

/**
 * The ABI18_0_0RCT_DEBUG macro can be used to exclude error checking and logging code
 * from release builds to improve performance and reduce binary size.
 */
#ifndef ABI18_0_0RCT_DEBUG
#if DEBUG
#define ABI18_0_0RCT_DEBUG 1
#else
#define ABI18_0_0RCT_DEBUG 0
#endif
#endif

/**
 * The ABI18_0_0RCT_DEV macro can be used to enable or disable development tools
 * such as the debug executors, dev menu, red box, etc.
 */
#ifndef ABI18_0_0RCT_DEV
#if DEBUG
#define ABI18_0_0RCT_DEV 1
#else
#define ABI18_0_0RCT_DEV 0
#endif
#endif

#if ABI18_0_0RCT_DEV
#define ABI18_0_0RCT_IF_DEV(...) __VA_ARGS__
#else
#define ABI18_0_0RCT_IF_DEV(...)
#endif

#ifndef ABI18_0_0RCT_PROFILE
#define ABI18_0_0RCT_PROFILE ABI18_0_0RCT_DEV
#endif

/**
 * By default, only raise an NSAssertion in debug mode
 * (custom assert functions will still be called).
 */
#ifndef ABI18_0_0RCT_NSASSERT
#define ABI18_0_0RCT_NSASSERT ABI18_0_0RCT_DEBUG
#endif

/**
 * Concat two literals. Supports macro expansions,
 * e.g. ABI18_0_0RCT_CONCAT(foo, __FILE__).
 */
#define ABI18_0_0RCT_CONCAT2(A, B) A ## B
#define ABI18_0_0RCT_CONCAT(A, B) ABI18_0_0RCT_CONCAT2(A, B)

/**
 * Throw an assertion for unimplemented methods.
 */
#define ABI18_0_0RCT_NOT_IMPLEMENTED(method) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wmissing-method-return-type\"") \
_Pragma("clang diagnostic ignored \"-Wunused-parameter\"") \
ABI18_0_0RCT_EXTERN NSException *_ABI18_0_0RCTNotImplementedException(SEL, Class); \
method NS_UNAVAILABLE { @throw _ABI18_0_0RCTNotImplementedException(_cmd, [self class]); } \
_Pragma("clang diagnostic pop")

  #define ABI18_0_0EX_REMOVE_VERSION(string) (([string hasPrefix:@"ABI18_0_0"]) ? [string stringByReplacingCharactersInRange:(NSRange){0,@"ABI18_0_0".length} withString:@""] : string)
