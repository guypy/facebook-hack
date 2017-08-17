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
#import <ReactABI16_0_0/ABI16_0_0RCTRootView.h>
#import <YogaABI16_0_0/ABI16_0_0Yoga.h>

@class ABI16_0_0RCTSparseArray;

typedef NS_ENUM(NSUInteger, ABI16_0_0RCTUpdateLifecycle) {
  ABI16_0_0RCTUpdateLifecycleUninitialized = 0,
  ABI16_0_0RCTUpdateLifecycleComputed,
  ABI16_0_0RCTUpdateLifecycleDirtied,
};

typedef void (^ABI16_0_0RCTApplierBlock)(NSDictionary<NSNumber *, UIView *> *viewRegistry);

/**
 * ShadowView tree mirrors ABI16_0_0RCT view tree. Every node is highly stateful.
 * 1. A node is in one of three lifecycles: uninitialized, computed, dirtied.
 * 1. ABI16_0_0RCTBridge may call any of the padding/margin/width/height/top/left setters. A setter would dirty
 *    the node and all of its ancestors.
 * 2. At the end of each Bridge transaction, we call collectUpdatedFrames:widthConstraint:heightConstraint
 *    at the root node to recursively lay out the entire hierarchy.
 * 3. If a node is "computed" and the constraint passed from above is identical to the constraint used to
 *    perform the last computation, we skip laying out the subtree entirely.
 */
@interface ABI16_0_0RCTShadowView : NSObject <ABI16_0_0RCTComponent>

/**
 * ABI16_0_0RCTComponent interface.
 */
- (NSArray<ABI16_0_0RCTShadowView *> *)ReactABI16_0_0Subviews NS_REQUIRES_SUPER;
- (ABI16_0_0RCTShadowView *)ReactABI16_0_0Superview NS_REQUIRES_SUPER;
- (void)insertReactABI16_0_0Subview:(ABI16_0_0RCTShadowView *)subview atIndex:(NSInteger)atIndex NS_REQUIRES_SUPER;
- (void)removeReactABI16_0_0Subview:(ABI16_0_0RCTShadowView *)subview NS_REQUIRES_SUPER;

@property (nonatomic, weak, readonly) ABI16_0_0RCTShadowView *superview;
@property (nonatomic, assign, readonly) ABI16_0_0YGNodeRef yogaNode;
@property (nonatomic, copy) NSString *viewName;
@property (nonatomic, strong) UIColor *backgroundColor; // Used to propagate to children
@property (nonatomic, copy) ABI16_0_0RCTDirectEventBlock onLayout;

/**
 * isNewView - Used to track the first time the view is introduced into the hierarchy.  It is initialized YES, then is
 * set to NO in ABI16_0_0RCTUIManager after the layout pass is done and all frames have been extracted to be applied to the
 * corresponding UIViews.
 */
@property (nonatomic, assign, getter=isNewView) BOOL newView;

/**
 * isHidden - ABI16_0_0RCTUIManager uses this to determine whether or not the UIView should be hidden. Useful if the
 * ShadowView determines that its UIView will be clipped and wants to hide it.
 */
@property (nonatomic, assign, getter=isHidden) BOOL hidden;

/**
 * Computed layout direction for the view backed to Yoga node value.
 */
@property (nonatomic, assign, readonly) UIUserInterfaceLayoutDirection effectiveLayoutDirection;

/**
 * Position and dimensions.
 * Defaults to { 0, 0, NAN, NAN }.
 */
@property (nonatomic, assign) ABI16_0_0YGValue top;
@property (nonatomic, assign) ABI16_0_0YGValue left;
@property (nonatomic, assign) ABI16_0_0YGValue bottom;
@property (nonatomic, assign) ABI16_0_0YGValue right;

@property (nonatomic, assign) ABI16_0_0YGValue width;
@property (nonatomic, assign) ABI16_0_0YGValue height;

@property (nonatomic, assign) ABI16_0_0YGValue minWidth;
@property (nonatomic, assign) ABI16_0_0YGValue maxWidth;
@property (nonatomic, assign) ABI16_0_0YGValue minHeight;
@property (nonatomic, assign) ABI16_0_0YGValue maxHeight;

/**
 * Convenient alias to `width` and `height` in pixels.
 * Defaults to NAN in case of non-pixel dimention.
 */
@property (nonatomic, assign) CGSize size;

/**
 * Border. Defaults to { 0, 0, 0, 0 }.
 */
@property (nonatomic, assign) float borderWidth;
@property (nonatomic, assign) float borderTopWidth;
@property (nonatomic, assign) float borderLeftWidth;
@property (nonatomic, assign) float borderBottomWidth;
@property (nonatomic, assign) float borderRightWidth;

/**
 * Margin. Defaults to { 0, 0, 0, 0 }.
 */
@property (nonatomic, assign) ABI16_0_0YGValue margin;
@property (nonatomic, assign) ABI16_0_0YGValue marginVertical;
@property (nonatomic, assign) ABI16_0_0YGValue marginHorizontal;
@property (nonatomic, assign) ABI16_0_0YGValue marginTop;
@property (nonatomic, assign) ABI16_0_0YGValue marginLeft;
@property (nonatomic, assign) ABI16_0_0YGValue marginBottom;
@property (nonatomic, assign) ABI16_0_0YGValue marginRight;

/**
 * Padding. Defaults to { 0, 0, 0, 0 }.
 */
@property (nonatomic, assign) ABI16_0_0YGValue padding;
@property (nonatomic, assign) ABI16_0_0YGValue paddingVertical;
@property (nonatomic, assign) ABI16_0_0YGValue paddingHorizontal;
@property (nonatomic, assign) ABI16_0_0YGValue paddingTop;
@property (nonatomic, assign) ABI16_0_0YGValue paddingLeft;
@property (nonatomic, assign) ABI16_0_0YGValue paddingBottom;
@property (nonatomic, assign) ABI16_0_0YGValue paddingRight;

- (UIEdgeInsets)paddingAsInsets;

/**
 * Flexbox properties. All zero/disabled by default
 */
@property (nonatomic, assign) ABI16_0_0YGFlexDirection flexDirection;
@property (nonatomic, assign) ABI16_0_0YGJustify justifyContent;
@property (nonatomic, assign) ABI16_0_0YGAlign alignSelf;
@property (nonatomic, assign) ABI16_0_0YGAlign alignItems;
@property (nonatomic, assign) ABI16_0_0YGAlign alignContent;
@property (nonatomic, assign) ABI16_0_0YGPositionType position;
@property (nonatomic, assign) ABI16_0_0YGWrap flexWrap;
@property (nonatomic, assign) ABI16_0_0YGDisplay display;

@property (nonatomic, assign) float flexGrow;
@property (nonatomic, assign) float flexShrink;
@property (nonatomic, assign) ABI16_0_0YGValue flexBasis;

@property (nonatomic, assign) float aspectRatio;

- (void)setFlex:(float)flex;

/**
 * z-index, used to override sibling order in the view
 */
@property (nonatomic, assign) NSInteger zIndex;

/**
 * Interface direction (LTR or RTL)
 */
@property (nonatomic, assign) ABI16_0_0YGDirection direction;

/**
 * Clipping properties
 */
@property (nonatomic, assign) ABI16_0_0YGOverflow overflow;

/**
 * Computed position of the view.
 */
@property (nonatomic, assign, readonly) CGRect frame;

/**
 * Represents the natural size of the view, which is used when explicit size is not set or is ambiguous.
 * Defaults to `{UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric}`.
 */
@property (nonatomic, assign) CGSize intrinsicContentSize;

/**
 * Calculate property changes that need to be propagated to the view.
 * The applierBlocks set contains ABI16_0_0RCTApplierBlock functions that must be applied
 * on the main thread in order to update the view.
 */
- (void)collectUpdatedProperties:(NSMutableSet<ABI16_0_0RCTApplierBlock> *)applierBlocks
                parentProperties:(NSDictionary<NSString *, id> *)parentProperties;

/**
 * Process the updated properties and apply them to view. Shadow view classes
 * that add additional propagating properties should override this method.
 */
- (NSDictionary<NSString *, id> *)processUpdatedProperties:(NSMutableSet<ABI16_0_0RCTApplierBlock> *)applierBlocks
                                          parentProperties:(NSDictionary<NSString *, id> *)parentProperties NS_REQUIRES_SUPER;

/**
 * Can be called by a parent on a child in order to calculate all views whose frame needs
 * updating in that branch. Adds these frames to `viewsWithNewFrame`. Useful if layout
 * enters a view where flex doesn't apply (e.g. Text) and then you want to resume flex
 * layout on a subview.
 */
- (void)collectUpdatedFrames:(NSMutableSet<ABI16_0_0RCTShadowView *> *)viewsWithNewFrame
                   withFrame:(CGRect)frame
                      hidden:(BOOL)hidden
            absolutePosition:(CGPoint)absolutePosition;

/**
 * Apply the CSS layout.
 * This method also calls `applyLayoutToChildren:` internally. The functionality
 * is split into two methods so subclasses can override `applyLayoutToChildren:`
 * while using default implementation of `applyLayoutNode:`.
 */
- (void)applyLayoutNode:(ABI16_0_0YGNodeRef)node
      viewsWithNewFrame:(NSMutableSet<ABI16_0_0RCTShadowView *> *)viewsWithNewFrame
       absolutePosition:(CGPoint)absolutePosition NS_REQUIRES_SUPER;

/**
 * Enumerate the child nodes and tell them to apply layout.
 */
- (void)applyLayoutToChildren:(ABI16_0_0YGNodeRef)node
            viewsWithNewFrame:(NSMutableSet<ABI16_0_0RCTShadowView *> *)viewsWithNewFrame
             absolutePosition:(CGPoint)absolutePosition;

/**
 * Return whether or not this node acts as a leaf node in the eyes of Yoga.
 * For example `ABI16_0_0RCTShadowText` has children which it does not want Yoga
 * to lay out so in the eyes of Yoga it is a leaf node.
 */
- (BOOL)isYogaLeafNode;

- (void)dirtyPropagation NS_REQUIRES_SUPER;
- (BOOL)isPropagationDirty;

- (void)dirtyText NS_REQUIRES_SUPER;
- (void)setTextComputed NS_REQUIRES_SUPER;
- (BOOL)isTextDirty;

/**
 * As described in ABI16_0_0RCTComponent protocol.
 */
- (void)didUpdateReactABI16_0_0Subviews NS_REQUIRES_SUPER;
- (void)didSetProps:(NSArray<NSString *> *)changedProps NS_REQUIRES_SUPER;

/**
 * Computes the recursive offset, meaning the sum of all descendant offsets -
 * this is the sum of all positions inset from parents. This is not merely the
 * sum of `top`/`left`s, as this function uses the *actual* positions of
 * children, not the style specified positions - it computes this based on the
 * resulting layout. It does not yet compensate for native scroll view insets or
 * transforms or anchor points.
 */
- (CGRect)measureLayoutRelativeToAncestor:(ABI16_0_0RCTShadowView *)ancestor;

/**
 * Checks if the current shadow view is a descendant of the provided `ancestor`
 */
- (BOOL)viewIsDescendantOf:(ABI16_0_0RCTShadowView *)ancestor;

@end

@interface ABI16_0_0RCTShadowView (Deprecated)

@property (nonatomic, assign, readonly) ABI16_0_0YGNodeRef cssNode
__deprecated_msg("Use `yogaNode` instead.");

- (BOOL)isCSSLeafNode
__deprecated_msg("Use `isYogaLeafNode` instead.");

@end
