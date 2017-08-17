/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <ReactABI16_0_0/ABI16_0_0RCTComponent.h>

@class ABI16_0_0RCTShadowView;

@interface UIView (ReactABI16_0_0) <ABI16_0_0RCTComponent>

/**
 * ABI16_0_0RCTComponent interface.
 */
- (NSArray<UIView *> *)ReactABI16_0_0Subviews NS_REQUIRES_SUPER;
- (UIView *)ReactABI16_0_0Superview NS_REQUIRES_SUPER;
- (void)insertReactABI16_0_0Subview:(UIView *)subview atIndex:(NSInteger)atIndex NS_REQUIRES_SUPER;
- (void)removeReactABI16_0_0Subview:(UIView *)subview NS_REQUIRES_SUPER;

/**
 * Layout direction of the view.
 * Internally backed to `semanticContentAttribute` property.
 * Defaults to `LeftToRight` in case of ambiguity.
 */
@property (nonatomic, assign) UIUserInterfaceLayoutDirection ReactABI16_0_0LayoutDirection;

/**
 * z-index, used to override sibling order in didUpdateReactABI16_0_0Subviews.
 */
@property (nonatomic, assign) NSInteger ReactABI16_0_0ZIndex;

/**
 * The ReactABI16_0_0Subviews array, sorted by zIndex. This value is cached and
 * automatically recalculated if views are added or removed.
 */
@property (nonatomic, copy, readonly) NSArray<UIView *> *sortedReactABI16_0_0Subviews;

/**
 * Updates the subviews array based on the ReactABI16_0_0Subviews. Default behavior is
 * to insert the sortedReactABI16_0_0Subviews into the UIView.
 */
- (void)didUpdateReactABI16_0_0Subviews;

/**
 * Used by the UIIManager to set the view frame.
 * May be overriden to disable animation, etc.
 */
- (void)ReactABI16_0_0SetFrame:(CGRect)frame;

/**
 * Used to improve performance when compositing views with translucent content.
 */
- (void)ReactABI16_0_0SetInheritedBackgroundColor:(UIColor *)inheritedBackgroundColor;

/**
 * This method finds and returns the containing view controller for the view.
 */
- (UIViewController *)ReactABI16_0_0ViewController;

/**
 * This method attaches the specified controller as a child of the
 * the owning view controller of this view. Returns NO if no view
 * controller is found (which may happen if the view is not currently
 * attached to the view hierarchy).
 */
- (void)ReactABI16_0_0AddControllerToClosestParent:(UIViewController *)controller;

/**
 * Responder overrides - to be deprecated.
 */
- (void)ReactABI16_0_0WillMakeFirstResponder;
- (void)ReactABI16_0_0DidMakeFirstResponder;
- (BOOL)ReactABI16_0_0RespondsToTouch:(UITouch *)touch;

#if ABI16_0_0RCT_DEV

/**
 Tools for debugging
 */

@property (nonatomic, strong, setter=_DEBUG_setReactABI16_0_0ShadowView:) ABI16_0_0RCTShadowView *_DEBUG_ReactABI16_0_0ShadowView;

#endif

@end
