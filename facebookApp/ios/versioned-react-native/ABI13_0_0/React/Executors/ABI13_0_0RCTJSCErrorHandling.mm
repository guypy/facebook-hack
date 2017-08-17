/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#include "ABI13_0_0RCTJSCErrorHandling.h"

#import <ABI13_0_0jschelpers/ABI13_0_0JavaScriptCore.h>

#import "ABI13_0_0RCTAssert.h"
#import "ABI13_0_0RCTJSStackFrame.h"

NSString *const ABI13_0_0RCTJSExceptionUnsymbolicatedStackTraceKey = @"ABI13_0_0RCTJSExceptionUnsymbolicatedStackTraceKey";

NSError *ABI13_0_0RCTNSErrorFromJSError(JSValue *exception)
{
  NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
  userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"Unhandled JS Exception: %@", [exception[@"name"] toString] ?: @"Unknown"];
  NSString *const exceptionMessage = [exception[@"message"] toString];
  if ([exceptionMessage length]) {
    userInfo[NSLocalizedFailureReasonErrorKey] = exceptionMessage;
  }
  NSString *const stack = [exception[@"stack"] toString];
  if ([stack length]) {
    NSArray<ABI13_0_0RCTJSStackFrame *> *const unsymbolicatedFrames = [ABI13_0_0RCTJSStackFrame stackFramesWithLines:stack];
    userInfo[ABI13_0_0RCTJSStackTraceKey] = unsymbolicatedFrames;
  }
  return [NSError errorWithDomain:ABI13_0_0RCTErrorDomain code:1 userInfo:userInfo];
}

NSError *ABI13_0_0RCTNSErrorFromJSErrorRef(JSValueRef exceptionRef, JSGlobalContextRef ctx)
{
  JSContext *context = [JSC_JSContext(ctx) contextWithJSGlobalContextRef:ctx];
  JSValue *exception = [JSC_JSValue(ctx) valueWithJSValueRef:exceptionRef inContext:context];
  return ABI13_0_0RCTNSErrorFromJSError(exception);
}
