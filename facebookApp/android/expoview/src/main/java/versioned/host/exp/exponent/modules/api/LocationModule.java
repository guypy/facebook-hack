// Copyright 2015-present 650 Industries. All rights reserved.

package versioned.host.exp.exponent.modules.api;

import android.content.pm.PackageManager;
import android.hardware.GeomagneticField;
import android.location.Location;
import android.os.Build;
import android.support.v4.content.ContextCompat;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.SystemClock;
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter;

import host.exp.exponent.utils.ScopedContext;
import host.exp.exponent.utils.TimeoutObject;
import io.nlopez.smartlocation.OnLocationUpdatedListener;
import io.nlopez.smartlocation.SmartLocation;
import io.nlopez.smartlocation.location.config.LocationAccuracy;
import io.nlopez.smartlocation.location.config.LocationParams;
import io.nlopez.smartlocation.location.utils.LocationState;

public class LocationModule extends ReactContextBaseJavaModule implements LifecycleEventListener, SensorEventListener {

  private ScopedContext mScopedContext;
  private LocationParams mLocationParams;
  private OnLocationUpdatedListener mOnLocationUpdatedListener;
  private SensorManager mSensorManager;
  private GeomagneticField mGeofield;

  private float[] mGravity;
  private float[] mGeomagnetic;
  private int mHeadingId;
  private float mLastAzimut = 0;
  private int mAccuracy = 0;
  private long mLastUpdate = 0;

  private static final double DEGREE_DELTA = 0.0355; // in radians, about 2 degrees
  private static final float TIME_DELTA = 50; // in milliseconds

  public LocationModule(ReactApplicationContext reactContext, ScopedContext scopedContext) {
    super(reactContext);
    reactContext.addLifecycleEventListener(this);

    mScopedContext = scopedContext;
  }

  @Override
  public String getName() {
    return "ExponentLocation";
  }

  private static WritableMap locationToMap(Location location) {
    WritableMap map = Arguments.createMap();
    WritableMap coords = Arguments.createMap();
    coords.putDouble("latitude", location.getLatitude());
    coords.putDouble("longitude", location.getLongitude());
    coords.putDouble("altitude", location.getAltitude());
    coords.putDouble("accuracy", location.getAccuracy());
    coords.putDouble("heading", location.getBearing());
    coords.putDouble("speed", location.getSpeed());
    map.putMap("coords", coords);
    map.putDouble("timestamp", location.getTime());
    map.putBoolean("mocked", location.isFromMockProvider());

    return map;
  }

  private boolean isMissingPermissions() {
    return Build.VERSION.SDK_INT >= 23 &&
        ContextCompat.checkSelfPermission(getReactApplicationContext(), android.Manifest.permission.ACCESS_FINE_LOCATION ) != PackageManager.PERMISSION_GRANTED &&
        ContextCompat.checkSelfPermission(getReactApplicationContext(), android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED;
  }

  @ReactMethod
  public void getCurrentPositionAsync(final ReadableMap options, final Promise promise) {
    // Read options
    final Long timeout = options.hasKey("timeout") ? (long) options.getDouble("timeout") : null;
    boolean highAccuracy = options.hasKey("enableHighAccuracy") && options.getBoolean("enableHighAccuracy");

    // Check for permissions
    if (isMissingPermissions()) {
      promise.reject("E_LOCATION_UNAUTHORIZED", "Not authorized to use location services");
      return;
    }

    final LocationParams locationParams = highAccuracy ? LocationParams.NAVIGATION : LocationParams.BEST_EFFORT;
    // LocationControl has an internal map from Context -> LocationProvider, so each experience
    // will only have one instance of a LocationProvider.
    SmartLocation.LocationControl locationControl = SmartLocation.with(mScopedContext).location().oneFix().config(locationParams);

    if (!locationControl.state().isAnyProviderAvailable()) {
      promise.reject("E_LOCATION_SERVICES_DISABLED", "Location services are disabled");
    }

    // Have location cached already?
    if (options.hasKey("maximumAge")) {
      double maximumAge = options.getDouble("maximumAge");
      Location location = locationControl.getLastLocation();
      if (location != null && SystemClock.currentTimeMillis() - location.getTime() < maximumAge) {
        promise.resolve(locationToMap(location));
        return;
      }
    }

    final TimeoutObject timeoutObject = new TimeoutObject(timeout);
    timeoutObject.onTimeout(new TimeoutObject.TimeoutListener() {
      @Override
      public void onTimeout() {
        promise.reject("E_LOCATION_TIMEOUT", "Location request timed out.");
      }
    });
    timeoutObject.start();

    locationControl.start(new OnLocationUpdatedListener() {
      @Override
      public void onLocationUpdated(Location location) {
        if (timeoutObject.markDoneIfNotTimedOut()) {
          promise.resolve(locationToMap(location));
        }
      }
    });
  }

  private boolean startWatching() {
    if (mScopedContext == null || mLocationParams == null || mOnLocationUpdatedListener == null) {
      return false;
    }

    // LocationControl has an internal map from Context -> LocationProvider, so each experience
    // will only have one instance of a LocationProvider.
    SmartLocation.LocationControl locationControl = SmartLocation.with(mScopedContext).location().config(mLocationParams);
    if (!locationControl.state().isAnyProviderAvailable()) {
      return false;
    }
    locationControl.start(mOnLocationUpdatedListener);
    return true;
  }

  private void stopWatching() {
    if (mScopedContext == null || mLocationParams == null || mOnLocationUpdatedListener == null) {
      return;
    }

    SmartLocation.with(mScopedContext).location().stop();
  }

  @ReactMethod
  public void getProviderStatusAsync(final Promise promise) {
    if (mScopedContext == null) {
      promise.reject("E_CONTEXT_UNAVAILABLE", "Context is not available");
    }

    LocationState state = SmartLocation.with(mScopedContext).location().state();

    WritableMap map = Arguments.createMap();

    map.putBoolean("locationServicesEnabled", state.locationServicesEnabled()); // If location is off
    map.putBoolean("gpsAvailable", state.isGpsAvailable()); // If GPS provider is enabled
    map.putBoolean("networkAvailable", state.isNetworkAvailable()); // If network provider is enabled
    map.putBoolean("passiveAvailable", state.isPassiveAvailable()); // If passive provider is enabled

    promise.resolve(map);
  }

  // Start Compass Module

  @ReactMethod
  public void watchDeviceHeading(final int watchId, final Promise promise) {
    mSensorManager = (SensorManager) mScopedContext.getSystemService(ScopedContext.SENSOR_SERVICE);
    this.mHeadingId = watchId;
    startHeadingUpdate();
    promise.resolve(null);
  }

  public void startHeadingUpdate() {
    if (mSensorManager == null || mScopedContext == null) {
      return;
    }

    SmartLocation.LocationControl locationControl = SmartLocation.with(mScopedContext).location().oneFix().config(LocationParams.BEST_EFFORT);
    Location currLoc = locationControl.getLastLocation();
    if (currLoc != null) {
      mGeofield = new GeomagneticField(
          (float) currLoc.getLatitude(),
          (float) currLoc.getLongitude(),
          (float) currLoc.getAltitude(),
          System.currentTimeMillis());
    } else {
      locationControl.start(new OnLocationUpdatedListener() {
        @Override
        public void onLocationUpdated(Location location) {
          mGeofield = new GeomagneticField(
              (float) location.getLatitude(),
              (float) location.getLongitude(),
              (float) location.getAltitude(),
              System.currentTimeMillis());
        }
      });
    }
    mSensorManager.registerListener(this, mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD),
        SensorManager.SENSOR_DELAY_NORMAL);
    mSensorManager.registerListener(this, mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER), SensorManager.SENSOR_DELAY_NORMAL);
  }

  public void onSensorChanged(SensorEvent event) {
    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER)
      mGravity = event.values;
    if (event.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD)
      mGeomagnetic = event.values;
    if (mGravity != null && mGeomagnetic != null) {
      sendUpdate();
    }
  }

  private void sendUpdate() {
    float R[] = new float[9];
    float I[] = new float[9];
    boolean success = SensorManager.getRotationMatrix(R, I, mGravity, mGeomagnetic);
    if (success) {
      float orientation[] = new float[3];
      SensorManager.getOrientation(R, orientation);

      // Make sure Delta is big enough to warrant an update
      // Currently: 50ms and ~2 degrees of change (android has a lot of useless updates block up the sending)
      if ((Math.abs(orientation[0] - mLastAzimut)) > DEGREE_DELTA && (System.currentTimeMillis() - mLastUpdate) > TIME_DELTA) {
        mLastAzimut = orientation[0];
        mLastUpdate = System.currentTimeMillis();
        float magneticNorth = calcMagNorth(orientation[0]);
        float trueNorth = calcTrueNorth(magneticNorth);

        // Write data to send back to React
        WritableMap response = Arguments.createMap();
        response.putInt("watchId", this.mHeadingId);
        WritableMap heading = Arguments.createMap();
        heading.putDouble("trueHeading", trueNorth);
        heading.putDouble("magHeading", magneticNorth);
        heading.putInt("accuracy", mAccuracy);
        response.putMap("heading", heading);
        getReactApplicationContext().getJSModule(RCTDeviceEventEmitter.class).emit("Exponent.headingChanged", response);
      }
    }
  }

  private float calcMagNorth(float azimut) {
    float azimutDeg = (float) Math.toDegrees(azimut);
    return (azimutDeg + 360) % 360;
  }

  private float calcTrueNorth(float magNorth) {
    // Need to request geo location info to calculate true north
    if (isMissingPermissions() || mGeofield == null) {
      return -1;
    }
    return magNorth + mGeofield.getDeclination();
  }

  private void stopHeadingWatch() {
    if (mSensorManager == null) {
      return;
    }
    mSensorManager.unregisterListener(this);
  }

  private void destroyHeadingWatch() {
    stopHeadingWatch();
    mSensorManager = null;
    mGravity = null;
    mGeomagnetic = null;
    mGeofield = null;
    mHeadingId = 0;
    mLastAzimut = 0;
    mAccuracy = 0;
  }

  // Android returns 4 different values for accuracy
  // 3: high accuracy, 2: medium, 1: low, 0: none
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
    mAccuracy = accuracy;
  }
  // End Compass

  // TODO: Stop sending watchId from JS since we ignore it.
  @ReactMethod
  public void watchPositionImplAsync(final int watchId, final ReadableMap options, final Promise promise) {
    // Read options
    final boolean highAccuracy = options.hasKey("enableHighAccuracy") && options.getBoolean("enableHighAccuracy");
    final int timeInterval = options.hasKey("timeInterval") ? options.getInt("timeInterval") : 1000;
    final int distanceInterval = options.hasKey("distanceInterval") ? options.getInt("distanceInterval") : 100;

    // Check for permissions
    if (isMissingPermissions()) {
      promise.reject("E_LOCATION_UNAUTHORIZED", "Not authorized to use location services");
      return;
    }

    mLocationParams = (new LocationParams.Builder()).setAccuracy(highAccuracy ? LocationAccuracy.HIGH : LocationAccuracy.MEDIUM).setDistance(distanceInterval).setInterval(timeInterval).build();
    mOnLocationUpdatedListener = new OnLocationUpdatedListener() {
      @Override
      public void onLocationUpdated(Location location) {
        WritableMap response = Arguments.createMap();
        response.putInt("watchId", watchId);
        response.putMap("location", locationToMap(location));
        getReactApplicationContext().getJSModule(RCTDeviceEventEmitter.class)
            .emit("Exponent.locationChanged", response);
      }
    };

    if (startWatching()) {
      promise.resolve(null);
    } else {
      promise.reject("E_LOCATION_SERVICES_DISABLED", "Location services are disabled");
    }
  }

  // TODO: Stop sending watchId from JS since we ignore it.
  @ReactMethod
  public void removeWatchAsync(final int watchId, final Promise promise) {
    if (isMissingPermissions()) {
      promise.reject("E_LOCATION_UNAUTHORIZED", "Not authorized to use location services");
      return;
    }

    // Check if we want to stop watching location or compass
    if (watchId == mHeadingId) {
      destroyHeadingWatch();
    } else {
      stopWatching();
      mLocationParams = null;
      mOnLocationUpdatedListener = null;
    }

    promise.resolve(null);
  }

  @Override
  public void onHostResume() {
    startWatching();
    startHeadingUpdate();
  }

  @Override
  public void onHostPause() {
    stopWatching();
    stopHeadingWatch();
  }

  @Override
  public void onHostDestroy() {
    stopWatching();
    stopHeadingWatch();
  }
}
