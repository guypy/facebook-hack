/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <MapKit/MapKit.h>

#import "ABI12_0_0RCTConvert.h"

@class ABI12_0_0RCTMapAnnotation;
@class ABI12_0_0RCTMapOverlay;

@interface ABI12_0_0RCTConvert (MapKit)

+ (MKCoordinateSpan)MKCoordinateSpan:(id)json;
+ (MKCoordinateRegion)MKCoordinateRegion:(id)json;
+ (MKMapType)MKMapType:(id)json;

+ (ABI12_0_0RCTMapAnnotation *)ABI12_0_0RCTMapAnnotation:(id)json;
+ (ABI12_0_0RCTMapOverlay *)ABI12_0_0RCTMapOverlay:(id)json;

+ (NSArray<ABI12_0_0RCTMapAnnotation *> *)ABI12_0_0RCTMapAnnotationArray:(id)json;
+ (NSArray<ABI12_0_0RCTMapOverlay *> *)ABI12_0_0RCTMapOverlayArray:(id)json;

@end
