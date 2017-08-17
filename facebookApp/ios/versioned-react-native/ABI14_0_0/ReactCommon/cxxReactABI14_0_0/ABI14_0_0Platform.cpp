// Copyright 2004-present Facebook. All Rights Reserved.

#include "ABI14_0_0Platform.h"

namespace facebook {
namespace ReactABI14_0_0 {

namespace ReactABI14_0_0Marker {
LogMarker logMarker;
};

namespace WebWorkerUtil {
WebWorkerQueueFactory createWebWorkerThread;
LoadScriptFromAssets loadScriptFromAssets;
LoadScriptFromNetworkSync loadScriptFromNetworkSync;
};

namespace PerfLogging {
InstallNativeHooks installNativeHooks;
};

namespace JSNativeHooks {
Hook loggingHook = nullptr;
Hook nowHook = nullptr;
}

} }
