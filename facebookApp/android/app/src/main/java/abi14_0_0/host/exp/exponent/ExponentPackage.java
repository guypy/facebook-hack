// Copyright 2015-present 650 Industries. All rights reserved.

package abi14_0_0.host.exp.exponent;

import abi14_0_0.com.facebook.react.ReactPackage;
import abi14_0_0.com.facebook.react.bridge.JavaScriptModule;
import abi14_0_0.com.facebook.react.bridge.NativeModule;
import abi14_0_0.com.facebook.react.bridge.ReactApplicationContext;
import abi14_0_0.com.facebook.react.uimanager.ViewManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import host.exp.exponent.ExponentManifest;
import host.exp.exponent.analytics.EXL;
import host.exp.exponent.kernel.ExponentKernelModuleProvider;
import abi14_0_0.host.exp.exponent.modules.api.AccelerometerModule;
import abi14_0_0.host.exp.exponent.modules.api.AmplitudeModule;
import abi14_0_0.host.exp.exponent.modules.api.AudioModule;
import abi14_0_0.host.exp.exponent.modules.api.ConstantsModule;
import abi14_0_0.host.exp.exponent.modules.api.ContactsModule;
import abi14_0_0.host.exp.exponent.modules.api.CryptoModule;
import abi14_0_0.host.exp.exponent.modules.api.FabricModule;
import abi14_0_0.host.exp.exponent.modules.api.FacebookModule;
import abi14_0_0.host.exp.exponent.modules.api.FileSystemModule;
import abi14_0_0.host.exp.exponent.modules.api.FingerprintModule;
import abi14_0_0.host.exp.exponent.modules.api.FontLoaderModule;
import abi14_0_0.host.exp.exponent.modules.api.GoogleModule;
import abi14_0_0.host.exp.exponent.modules.api.GyroscopeModule;
import abi14_0_0.host.exp.exponent.modules.api.ImageCropperModule;
import abi14_0_0.host.exp.exponent.modules.api.ImagePickerModule;
import abi14_0_0.host.exp.exponent.modules.api.KeepAwakeModule;
import abi14_0_0.host.exp.exponent.modules.api.KeyboardModule;
import abi14_0_0.host.exp.exponent.modules.api.LocationModule;
import abi14_0_0.host.exp.exponent.modules.api.NotificationsModule;
import abi14_0_0.host.exp.exponent.modules.api.PermissionsModule;
import abi14_0_0.host.exp.exponent.modules.api.RNViewShotModule;
import abi14_0_0.host.exp.exponent.modules.api.SegmentModule;
import abi14_0_0.host.exp.exponent.modules.api.ShakeModule;
import abi14_0_0.host.exp.exponent.modules.api.URLHandlerModule;
import abi14_0_0.host.exp.exponent.modules.api.UtilModule;
import abi14_0_0.host.exp.exponent.modules.api.WebBrowserModule;
import abi14_0_0.host.exp.exponent.modules.api.components.LinearGradientManager;
import abi14_0_0.host.exp.exponent.modules.api.components.VideoViewManager;
import abi14_0_0.host.exp.exponent.modules.api.components.barcodescanner.BarCodeScannerModule;
import abi14_0_0.host.exp.exponent.modules.api.components.barcodescanner.BarCodeScannerViewManager;
import abi14_0_0.host.exp.exponent.modules.api.components.lottie.LottiePackage;
import abi14_0_0.host.exp.exponent.modules.api.components.maps.MapsPackage;
import abi14_0_0.host.exp.exponent.modules.api.components.svg.RNSvgPackage;
import abi14_0_0.host.exp.exponent.modules.api.gl.GLViewManager;
import abi14_0_0.host.exp.exponent.modules.internal.ExponentAsyncStorageModule;
import abi14_0_0.host.exp.exponent.modules.internal.ExponentIntentModule;
import abi14_0_0.host.exp.exponent.modules.internal.ExponentUnsignedAsyncStorageModule;
import abi14_0_0.host.exp.exponent.modules.test.ExponentTestNativeModule;

public class ExponentPackage implements ReactPackage {

  private static final String TAG = ExponentPackage.class.getSimpleName();

  private final boolean mIsKernel;
  private final Map<String, Object> mExperienceProperties;
  private final JSONObject mManifest;

  private ExponentPackage(boolean isKernel, Map<String, Object> experienceProperties, JSONObject manifest) {
    mIsKernel = isKernel;
    mExperienceProperties = experienceProperties;
    mManifest = manifest;
  }

  public ExponentPackage(Map<String, Object> experienceProperties, JSONObject manifest) {
    mIsKernel = false;
    mExperienceProperties = experienceProperties;
    mManifest = manifest;
  }

  public static ExponentPackage kernelExponentPackage(JSONObject manifest) {
    Map<String, Object> kernelExperienceProperties = new HashMap<>();
    return new ExponentPackage(true, kernelExperienceProperties, manifest);
  }


  @Override
  public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
    boolean isVerified = false;
    if (mManifest != null) {
      isVerified = mManifest.optBoolean(ExponentManifest.MANIFEST_IS_VERIFIED_KEY);
    }

    List<NativeModule> nativeModules = new ArrayList<>(Arrays.<NativeModule>asList(
        new URLHandlerModule(reactContext),
        new ConstantsModule(reactContext, mExperienceProperties, mManifest),
        new ShakeModule(reactContext),
        new FontLoaderModule(reactContext),
        new KeyboardModule(reactContext),
        new UtilModule(reactContext, mExperienceProperties),
        new ExponentIntentModule(reactContext, mExperienceProperties)
    ));

    if (mIsKernel) {
      // Never need this in versioned code. Comment this out if this is in an abi package
      //nativeModules.add((NativeModule) ExponentKernelModuleProvider.newInstance(reactContext));
    }

    if (isVerified) {
      try {
        String experienceId = mManifest.getString(ExponentManifest.MANIFEST_ID_KEY);
        String experienceIdEncoded = URLEncoder.encode(experienceId, "UTF-8");

        nativeModules.add(new ExponentAsyncStorageModule(reactContext, mManifest));
        nativeModules.add(new AccelerometerModule(reactContext));
        nativeModules.add(new GyroscopeModule(reactContext));
        nativeModules.add(new NotificationsModule(reactContext, mManifest, mExperienceProperties));
        nativeModules.add(new ContactsModule(reactContext));
        nativeModules.add(new FileSystemModule(reactContext, mManifest));
        nativeModules.add(new LocationModule(reactContext));
        nativeModules.add(new CryptoModule(reactContext));
        nativeModules.add(new ImagePickerModule(reactContext));
        nativeModules.add(new FacebookModule(reactContext));
        nativeModules.add(new FabricModule(reactContext, mExperienceProperties));
        nativeModules.add(new FingerprintModule(reactContext));
        nativeModules.add(new GoogleModule(reactContext, mExperienceProperties));
        nativeModules.add(new PermissionsModule(reactContext));
        nativeModules.add(new AmplitudeModule(reactContext, experienceIdEncoded));
        nativeModules.add(new SegmentModule(reactContext, experienceIdEncoded));
        nativeModules.add(new BarCodeScannerModule(reactContext));
        nativeModules.add(new RNViewShotModule(reactContext));
        nativeModules.add(new KeepAwakeModule(reactContext));
        nativeModules.add(new ExponentTestNativeModule(reactContext));
        nativeModules.add(new WebBrowserModule(reactContext));
        nativeModules.add(new AudioModule(reactContext));
      } catch (JSONException e) {
        EXL.e(TAG, e.toString());
      } catch (UnsupportedEncodingException e) {
        EXL.e(TAG, e.toString());
      }
    } else {
      nativeModules.add(new ExponentUnsignedAsyncStorageModule(reactContext));
    }
    nativeModules.add(new ImageCropperModule(reactContext));

    return nativeModules;
  }

  @Override
  public List<Class<? extends JavaScriptModule>> createJSModules() {
    return Collections.emptyList();
  }

  @Override
  public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
    List<ViewManager> viewManagers = new ArrayList<>(Arrays.<ViewManager>asList(
        new LinearGradientManager(),
        new VideoViewManager(),
        new BarCodeScannerViewManager(),
        new GLViewManager()
    ));

    // Add view manager from 3rd party library packages.
    addViewManagersFromPackages(reactContext, viewManagers, Arrays.<ReactPackage>asList(
      new RNSvgPackage(),
      new MapsPackage(),
      new LottiePackage()
    ));

    return viewManagers;
  }

  private void addViewManagersFromPackages(ReactApplicationContext reactContext,
                                           List<ViewManager> viewManagers,
                                           List<ReactPackage> packages) {
    for (ReactPackage pack : packages) {
      viewManagers.addAll(pack.createViewManagers(reactContext));
    }
  }
}
