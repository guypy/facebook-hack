// Copyright 2004-present Facebook. All Rights Reserved.

#include "ABI14_0_0JSCMemory.h"

#ifdef WITH_FB_MEMORY_PROFILING

#include <stdio.h>
#include <string.h>
#include <JavaScriptCore/API/JSProfilerPrivate.h>
#include <ABI14_0_0jschelpers/ABI14_0_0JSCHelpers.h>
#include <ABI14_0_0jschelpers/ABI14_0_0Value.h>

using namespace facebook::ReactABI14_0_0;

static JSValueRef nativeCaptureHeap(
    JSContextRef ctx,
    JSObjectRef function,
    JSObjectRef thisObject,
    size_t argumentCount,
    const JSValueRef arguments[],
    JSValueRef* exception) {
  if (argumentCount < 1) {
      if (exception) {
          *exception = Value::makeError(
            ctx,
            "nativeCaptureHeap requires the path to save the capture");
      }
      return Value::makeUndefined(ctx);
  }

  auto outputFilename = String::adopt(
    ctx, JSValueToStringCopy(ctx, arguments[0], exception));
  JSCaptureHeap(ctx, outputFilename.str().c_str(), exception);
  return Value::makeUndefined(ctx);
}

#endif // WITH_FB_MEMORY_PROFILING

namespace facebook {
namespace ReactABI14_0_0 {

void addNativeMemoryHooks(JSGlobalContextRef ctx) {
#ifdef WITH_FB_MEMORY_PROFILING
  installGlobalFunction(ctx, "nativeCaptureHeap", nativeCaptureHeap);
#endif // WITH_FB_MEMORY_PROFILING

}

} }
