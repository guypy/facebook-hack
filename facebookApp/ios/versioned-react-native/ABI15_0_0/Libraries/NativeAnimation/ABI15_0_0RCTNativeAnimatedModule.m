/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
#import "ABI15_0_0RCTNativeAnimatedModule.h"

#import "ABI15_0_0RCTNativeAnimatedNodesManager.h"

typedef void (^AnimatedOperation)(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager);

@implementation ABI15_0_0RCTNativeAnimatedModule
{
  ABI15_0_0RCTNativeAnimatedNodesManager *_nodesManager;
  NSMutableArray<AnimatedOperation> *_operations;
}

ABI15_0_0RCT_EXPORT_MODULE();

- (void)invalidate
{
  [_nodesManager stopAnimationLoop];
}

- (void)dealloc
{
  [self.bridge.eventDispatcher removeDispatchObserver:self];
}

- (dispatch_queue_t)methodQueue
{
  return ABI15_0_0RCTGetUIManagerQueue();
}

- (void)setBridge:(ABI15_0_0RCTBridge *)bridge
{
  [super setBridge:bridge];

  _nodesManager = [[ABI15_0_0RCTNativeAnimatedNodesManager alloc] initWithUIManager:self.bridge.uiManager];
  _operations = [NSMutableArray new];

  [bridge.eventDispatcher addDispatchObserver:self];
}

#pragma mark -- API

ABI15_0_0RCT_EXPORT_METHOD(createAnimatedNode:(nonnull NSNumber *)tag
                  config:(NSDictionary<NSString *, id> *)config)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager createAnimatedNode:tag config:config];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(connectAnimatedNodes:(nonnull NSNumber *)parentTag
                  childTag:(nonnull NSNumber *)childTag)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager connectAnimatedNodes:parentTag childTag:childTag];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(disconnectAnimatedNodes:(nonnull NSNumber *)parentTag
                  childTag:(nonnull NSNumber *)childTag)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager disconnectAnimatedNodes:parentTag childTag:childTag];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(startAnimatingNode:(nonnull NSNumber *)animationId
                  nodeTag:(nonnull NSNumber *)nodeTag
                  config:(NSDictionary<NSString *, id> *)config
                  endCallback:(ABI15_0_0RCTResponseSenderBlock)callBack)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager startAnimatingNode:animationId nodeTag:nodeTag config:config endCallback:callBack];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(stopAnimation:(nonnull NSNumber *)animationId)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager stopAnimation:animationId];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(setAnimatedNodeValue:(nonnull NSNumber *)nodeTag
                  value:(nonnull NSNumber *)value)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager setAnimatedNodeValue:nodeTag value:value];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(setAnimatedNodeOffset:(nonnull NSNumber *)nodeTag
                  offset:(nonnull NSNumber *)offset)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager setAnimatedNodeOffset:nodeTag offset:offset];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(flattenAnimatedNodeOffset:(nonnull NSNumber *)nodeTag)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager flattenAnimatedNodeOffset:nodeTag];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(extractAnimatedNodeOffset:(nonnull NSNumber *)nodeTag)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager extractAnimatedNodeOffset:nodeTag];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(connectAnimatedNodeToView:(nonnull NSNumber *)nodeTag
                  viewTag:(nonnull NSNumber *)viewTag)
{
  NSString *viewName = [self.bridge.uiManager viewNameForReactABI15_0_0Tag:viewTag];
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager connectAnimatedNodeToView:nodeTag viewTag:viewTag viewName:viewName];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(disconnectAnimatedNodeFromView:(nonnull NSNumber *)nodeTag
                  viewTag:(nonnull NSNumber *)viewTag)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager disconnectAnimatedNodeFromView:nodeTag viewTag:viewTag];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(dropAnimatedNode:(nonnull NSNumber *)tag)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager dropAnimatedNode:tag];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(startListeningToAnimatedNodeValue:(nonnull NSNumber *)tag)
{
  __weak id<ABI15_0_0RCTValueAnimatedNodeObserver> valueObserver = self;
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager startListeningToAnimatedNodeValue:tag valueObserver:valueObserver];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(stopListeningToAnimatedNodeValue:(nonnull NSNumber *)tag)
{
  __weak id<ABI15_0_0RCTValueAnimatedNodeObserver> valueObserver = self;
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager stopListeningToAnimatedNodeValue:tag valueObserver:valueObserver];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(addAnimatedEventToView:(nonnull NSNumber *)viewTag
                  eventName:(nonnull NSString *)eventName
                  eventMapping:(NSDictionary<NSString *, id> *)eventMapping)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager addAnimatedEventToView:viewTag eventName:eventName eventMapping:eventMapping];
  }];
}

ABI15_0_0RCT_EXPORT_METHOD(removeAnimatedEventFromView:(nonnull NSNumber *)viewTag
                  eventName:(nonnull NSString *)eventName)
{
  [_operations addObject:^(ABI15_0_0RCTNativeAnimatedNodesManager *nodesManager) {
    [nodesManager removeAnimatedEventFromView:viewTag eventName:eventName];
  }];
}

#pragma mark -- Batch handling

- (void)batchDidComplete
{
  NSArray *operations = _operations;
  _operations = [NSMutableArray new];

  dispatch_async(dispatch_get_main_queue(), ^{
    [operations enumerateObjectsUsingBlock:^(AnimatedOperation operation, NSUInteger i, BOOL *stop) {
      operation(self->_nodesManager);
    }];
    [self->_nodesManager updateAnimations];
  });
}

#pragma mark -- Events

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onAnimatedValueUpdate"];
}

- (void)animatedNode:(ABI15_0_0RCTValueAnimatedNode *)node didUpdateValue:(CGFloat)value
{
  [self sendEventWithName:@"onAnimatedValueUpdate"
                     body:@{@"tag": node.nodeTag, @"value": @(value)}];
}

- (void)eventDispatcherWillDispatchEvent:(id<ABI15_0_0RCTEvent>)event
{
  // Native animated events only work for events dispatched from the main queue.
  if (!ABI15_0_0RCTIsMainQueue()) {
    return;
  }
  return [_nodesManager handleAnimatedEvent:event];
}

@end
