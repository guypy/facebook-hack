/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI12_0_0RCTModuleMethod.h"

#import <objc/message.h>

#import "ABI12_0_0RCTAssert.h"
#import "ABI12_0_0RCTBridge.h"
#import "ABI12_0_0RCTBridge+Private.h"
#import "ABI12_0_0RCTConvert.h"
#import "ABI12_0_0RCTLog.h"
#import "ABI12_0_0RCTParserUtils.h"
#import "ABI12_0_0RCTUtils.h"
#import "ABI12_0_0RCTProfile.h"

typedef BOOL (^ABI12_0_0RCTArgumentBlock)(ABI12_0_0RCTBridge *, NSUInteger, id);

@implementation ABI12_0_0RCTMethodArgument

- (instancetype)initWithType:(NSString *)type
                 nullability:(ABI12_0_0RCTNullability)nullability
                      unused:(BOOL)unused
{
  if (self = [super init]) {
    _type = [type copy];
    _nullability = nullability;
    _unused = unused;
  }
  return self;
}

@end

@implementation ABI12_0_0RCTModuleMethod
{
  Class _moduleClass;
  NSInvocation *_invocation;
  NSArray<ABI12_0_0RCTArgumentBlock> *_argumentBlocks;
  NSString *_methodSignature;
  SEL _selector;
}

@synthesize JSMethodName = _JSMethodName;

static void ABI12_0_0RCTLogArgumentError(ABI12_0_0RCTModuleMethod *method, NSUInteger index,
                                id valueOrType, const char *issue)
{
  ABI12_0_0RCTLogError(@"Argument %tu (%@) of %@.%@ %s", index, valueOrType,
              ABI12_0_0RCTBridgeModuleNameForClass(method->_moduleClass),
              method->_JSMethodName, issue);
}

ABI12_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

// returns YES if the selector ends in a colon (indicating that there is at
// least one argument, and maybe more selector parts) or NO if it doesn't.
static BOOL ABI12_0_0RCTParseSelectorPart(const char **input, NSMutableString *selector)
{
  NSString *selectorPart;
  if (ABI12_0_0RCTParseIdentifier(input, &selectorPart)) {
    [selector appendString:selectorPart];
  }
  ABI12_0_0RCTSkipWhitespace(input);
  if (ABI12_0_0RCTReadChar(input, ':')) {
    [selector appendString:@":"];
    ABI12_0_0RCTSkipWhitespace(input);
    return YES;
  }
  return NO;
}

static BOOL ABI12_0_0RCTParseUnused(const char **input)
{
  return ABI12_0_0RCTReadString(input, "__unused") ||
         ABI12_0_0RCTReadString(input, "__attribute__((unused))");
}

static ABI12_0_0RCTNullability ABI12_0_0RCTParseNullability(const char **input)
{
  if (ABI12_0_0RCTReadString(input, "nullable")) {
    return ABI12_0_0RCTNullable;
  } else if (ABI12_0_0RCTReadString(input, "nonnull")) {
    return ABI12_0_0RCTNonnullable;
  }
  return ABI12_0_0RCTNullabilityUnspecified;
}

static ABI12_0_0RCTNullability ABI12_0_0RCTParseNullabilityPostfix(const char **input)
{
  if (ABI12_0_0RCTReadString(input, "_Nullable")) {
    return ABI12_0_0RCTNullable;
  } else if (ABI12_0_0RCTReadString(input, "_Nonnull")) {
    return ABI12_0_0RCTNonnullable;
  }
  return ABI12_0_0RCTNullabilityUnspecified;
}

SEL ABI12_0_0RCTParseMethodSignature(NSString *, NSArray<ABI12_0_0RCTMethodArgument *> **);
SEL ABI12_0_0RCTParseMethodSignature(NSString *methodSignature, NSArray<ABI12_0_0RCTMethodArgument *> **arguments)
{
  const char *input = methodSignature.UTF8String;
  ABI12_0_0RCTSkipWhitespace(&input);

  NSMutableArray *args;
  NSMutableString *selector = [NSMutableString new];
  while (ABI12_0_0RCTParseSelectorPart(&input, selector)) {
    if (!args) {
      args = [NSMutableArray new];
    }

    // Parse type
    if (ABI12_0_0RCTReadChar(&input, '(')) {
      ABI12_0_0RCTSkipWhitespace(&input);

      BOOL unused = ABI12_0_0RCTParseUnused(&input);
      ABI12_0_0RCTSkipWhitespace(&input);

      ABI12_0_0RCTNullability nullability = ABI12_0_0RCTParseNullability(&input);
      ABI12_0_0RCTSkipWhitespace(&input);

      NSString *type = ABI12_0_0RCTParseType(&input);
      ABI12_0_0RCTSkipWhitespace(&input);
      if (nullability == ABI12_0_0RCTNullabilityUnspecified) {
        nullability = ABI12_0_0RCTParseNullabilityPostfix(&input);
      }
      [args addObject:[[ABI12_0_0RCTMethodArgument alloc] initWithType:type
                                                  nullability:nullability
                                                       unused:unused]];
      ABI12_0_0RCTSkipWhitespace(&input);
      ABI12_0_0RCTReadChar(&input, ')');
      ABI12_0_0RCTSkipWhitespace(&input);
    } else {
      // Type defaults to id if unspecified
      [args addObject:[[ABI12_0_0RCTMethodArgument alloc] initWithType:@"id"
                                                  nullability:ABI12_0_0RCTNullable
                                                       unused:NO]];
    }

    // Argument name
    ABI12_0_0RCTParseIdentifier(&input, NULL);
    ABI12_0_0RCTSkipWhitespace(&input);
  }

  *arguments = [args copy];
  return NSSelectorFromString(selector);
}

- (instancetype)initWithMethodSignature:(NSString *)methodSignature
                           JSMethodName:(NSString *)JSMethodName
                            moduleClass:(Class)moduleClass
{
  if (self = [super init]) {
    _moduleClass = moduleClass;
    _methodSignature = [methodSignature copy];
    _JSMethodName = [JSMethodName copy];
  }

  return self;
}

- (void)processMethodSignature
{
  NSArray<ABI12_0_0RCTMethodArgument *> *arguments;
  _selector = ABI12_0_0RCTParseMethodSignature(_methodSignature, &arguments);
  ABI12_0_0RCTAssert(_selector, @"%@ is not a valid selector", _methodSignature);

  // Create method invocation
  NSMethodSignature *methodSignature = [_moduleClass instanceMethodSignatureForSelector:_selector];
  ABI12_0_0RCTAssert(methodSignature, @"%@ is not a recognized Objective-C method.", _methodSignature);
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
  invocation.selector = _selector;
  _invocation = invocation;

  // Process arguments
  NSUInteger numberOfArguments = methodSignature.numberOfArguments;
  NSMutableArray<ABI12_0_0RCTArgumentBlock> *argumentBlocks =
    [[NSMutableArray alloc] initWithCapacity:numberOfArguments - 2];

#define ABI12_0_0RCT_ARG_BLOCK(_logic) \
[argumentBlocks addObject:^(__unused ABI12_0_0RCTBridge *bridge, NSUInteger index, id json) { \
  _logic \
  [invocation setArgument:&value atIndex:(index) + 2]; \
  return YES; \
}];

/**
 * Explicitly copy the block and retain it, since NSInvocation doesn't retain them.
 */
#define ABI12_0_0RCT_BLOCK_ARGUMENT(block...) \
  id value = json ? [block copy] : (id)^(__unused NSArray *_){}; \
  CFBridgingRetain(value)

  __weak ABI12_0_0RCTModuleMethod *weakSelf = self;
  void (^addBlockArgument)(void) = ^{
    ABI12_0_0RCT_ARG_BLOCK(
      if (ABI12_0_0RCT_DEBUG && json && ![json isKindOfClass:[NSNumber class]]) {
        ABI12_0_0RCTLogArgumentError(weakSelf, index, json, "should be a function");
        return NO;
      }

      ABI12_0_0RCT_BLOCK_ARGUMENT(^(NSArray *args) {
        [bridge enqueueCallback:json args:args];
      });
    )
  };

  for (NSUInteger i = 2; i < numberOfArguments; i++) {
    const char *objcType = [methodSignature getArgumentTypeAtIndex:i];
    BOOL isNullableType = NO;
    ABI12_0_0RCTMethodArgument *argument = arguments[i - 2];
    NSString *typeName = argument.type;
    SEL selector = ABI12_0_0RCTConvertSelectorForType(typeName);
    if ([ABI12_0_0RCTConvert respondsToSelector:selector]) {
      switch (objcType[0]) {

#define ABI12_0_0RCT_CASE(_value, _type) \
        case _value: { \
          _type (*convert)(id, SEL, id) = (typeof(convert))objc_msgSend; \
          ABI12_0_0RCT_ARG_BLOCK( _type value = convert([ABI12_0_0RCTConvert class], selector, json); ) \
          break; \
        }

        ABI12_0_0RCT_CASE(_C_CHR, char)
        ABI12_0_0RCT_CASE(_C_UCHR, unsigned char)
        ABI12_0_0RCT_CASE(_C_SHT, short)
        ABI12_0_0RCT_CASE(_C_USHT, unsigned short)
        ABI12_0_0RCT_CASE(_C_INT, int)
        ABI12_0_0RCT_CASE(_C_UINT, unsigned int)
        ABI12_0_0RCT_CASE(_C_LNG, long)
        ABI12_0_0RCT_CASE(_C_ULNG, unsigned long)
        ABI12_0_0RCT_CASE(_C_LNG_LNG, long long)
        ABI12_0_0RCT_CASE(_C_ULNG_LNG, unsigned long long)
        ABI12_0_0RCT_CASE(_C_FLT, float)
        ABI12_0_0RCT_CASE(_C_DBL, double)
        ABI12_0_0RCT_CASE(_C_BOOL, BOOL)

#define ABI12_0_0RCT_NULLABLE_CASE(_value, _type) \
        case _value: { \
          isNullableType = YES; \
          _type (*convert)(id, SEL, id) = (typeof(convert))objc_msgSend; \
          ABI12_0_0RCT_ARG_BLOCK( _type value = convert([ABI12_0_0RCTConvert class], selector, json); ) \
          break; \
        }

        ABI12_0_0RCT_NULLABLE_CASE(_C_SEL, SEL)
        ABI12_0_0RCT_NULLABLE_CASE(_C_CHARPTR, const char *)
        ABI12_0_0RCT_NULLABLE_CASE(_C_PTR, void *)

        case _C_ID: {
          isNullableType = YES;
          id (*convert)(id, SEL, id) = (typeof(convert))objc_msgSend;
          ABI12_0_0RCT_ARG_BLOCK(
            id value = convert([ABI12_0_0RCTConvert class], selector, json);
            CFBridgingRetain(value);
          )
          break;
        }

        case _C_STRUCT_B: {

          NSMethodSignature *typeSignature = [ABI12_0_0RCTConvert methodSignatureForSelector:selector];
          NSInvocation *typeInvocation = [NSInvocation invocationWithMethodSignature:typeSignature];
          typeInvocation.selector = selector;
          typeInvocation.target = [ABI12_0_0RCTConvert class];

          [argumentBlocks addObject:^(__unused ABI12_0_0RCTBridge *bridge, NSUInteger index, id json) {
            void *returnValue = malloc(typeSignature.methodReturnLength);
            [typeInvocation setArgument:&json atIndex:2];
            [typeInvocation invoke];
            [typeInvocation getReturnValue:returnValue];
            [invocation setArgument:returnValue atIndex:index + 2];
            free(returnValue);
            return YES;
          }];
          break;
        }

        default: {
          static const char *blockType = @encode(typeof(^{}));
          if (!strcmp(objcType, blockType)) {
            addBlockArgument();
          } else {
            ABI12_0_0RCTLogError(@"Unsupported argument type '%@' in method %@.",
                        typeName, [self methodName]);
          }
        }
      }
    } else if ([typeName isEqualToString:@"ABI12_0_0RCTResponseSenderBlock"]) {
      addBlockArgument();
    } else if ([typeName isEqualToString:@"ABI12_0_0RCTResponseErrorBlock"]) {
      ABI12_0_0RCT_ARG_BLOCK(

        if (ABI12_0_0RCT_DEBUG && json && ![json isKindOfClass:[NSNumber class]]) {
          ABI12_0_0RCTLogArgumentError(weakSelf, index, json, "should be a function");
          return NO;
        }

        ABI12_0_0RCT_BLOCK_ARGUMENT(^(NSError *error) {
          [bridge enqueueCallback:json args:@[ABI12_0_0RCTJSErrorFromNSError(error)]];
        });
      )
    } else if ([typeName isEqualToString:@"ABI12_0_0RCTPromiseResolveBlock"]) {
      ABI12_0_0RCTAssert(i == numberOfArguments - 2,
                @"The ABI12_0_0RCTPromiseResolveBlock must be the second to last parameter in -[%@ %@]",
                _moduleClass, _methodSignature);
      ABI12_0_0RCT_ARG_BLOCK(
        if (ABI12_0_0RCT_DEBUG && ![json isKindOfClass:[NSNumber class]]) {
          ABI12_0_0RCTLogArgumentError(weakSelf, index, json, "should be a promise resolver function");
          return NO;
        }

        ABI12_0_0RCT_BLOCK_ARGUMENT(^(id result) {
          [bridge enqueueCallback:json args:result ? @[result] : @[]];
        });
      )
    } else if ([typeName isEqualToString:@"ABI12_0_0RCTPromiseRejectBlock"]) {
      ABI12_0_0RCTAssert(i == numberOfArguments - 1,
                @"The ABI12_0_0RCTPromiseRejectBlock must be the last parameter in -[%@ %@]",
                _moduleClass, _methodSignature);
      ABI12_0_0RCT_ARG_BLOCK(
        if (ABI12_0_0RCT_DEBUG && ![json isKindOfClass:[NSNumber class]]) {
          ABI12_0_0RCTLogArgumentError(weakSelf, index, json, "should be a promise rejecter function");
          return NO;
        }

        ABI12_0_0RCT_BLOCK_ARGUMENT(^(NSString *code, NSString *message, NSError *error) {
          NSDictionary *errorJSON = ABI12_0_0RCTJSErrorFromCodeMessageAndNSError(code, message, error);
          [bridge enqueueCallback:json args:@[errorJSON]];
        });
      )
    } else {

      // Unknown argument type
      ABI12_0_0RCTLogError(@"Unknown argument type '%@' in method %@. Extend ABI12_0_0RCTConvert"
                  " to support this type.", typeName, [self methodName]);
    }

    if (ABI12_0_0RCT_DEBUG) {

      ABI12_0_0RCTNullability nullability = argument.nullability;
      if (!isNullableType) {
        if (nullability == ABI12_0_0RCTNullable) {
          ABI12_0_0RCTLogArgumentError(weakSelf, i - 2, typeName, "is marked as "
                              "nullable, but is not a nullable type.");
        }
        nullability = ABI12_0_0RCTNonnullable;
      }

      /**
       * Special case - Numbers are not nullable in Android, so we
       * don't support this for now. In future we may allow it.
       */
      if ([typeName isEqualToString:@"NSNumber"]) {
        BOOL unspecified = (nullability == ABI12_0_0RCTNullabilityUnspecified);
        if (!argument.unused && (nullability == ABI12_0_0RCTNullable || unspecified)) {
          ABI12_0_0RCTLogArgumentError(weakSelf, i - 2, typeName,
            [unspecified ? @"has unspecified nullability" : @"is marked as nullable"
             stringByAppendingString: @" but ReactABI12_0_0 requires that all NSNumber "
             "arguments are explicitly marked as `nonnull` to ensure "
             "compatibility with Android."].UTF8String);
        }
        nullability = ABI12_0_0RCTNonnullable;
      }

      if (nullability == ABI12_0_0RCTNonnullable) {
        ABI12_0_0RCTArgumentBlock oldBlock = argumentBlocks[i - 2];
        argumentBlocks[i - 2] = ^(ABI12_0_0RCTBridge *bridge, NSUInteger index, id json) {
          if (json != nil) {
            if (!oldBlock(bridge, index, json)) {
              return NO;
            }
            if (isNullableType) {
              // Check converted value wasn't null either, as method probably
              // won't gracefully handle a nil vallue for a nonull argument
              void *value;
              [invocation getArgument:&value atIndex:index + 2];
              if (value == NULL) {
                return NO;
              }
            }
            return YES;
          }
          ABI12_0_0RCTLogArgumentError(weakSelf, index, typeName, "must not be null");
          return NO;
        };
      }
    }
  }

  _argumentBlocks = [argumentBlocks copy];
}

- (SEL)selector
{
  if (_selector == NULL) {
    ABI12_0_0RCT_PROFILE_BEGIN_EVENT(ABI12_0_0RCTProfileTagAlways, @"", (@{ @"module": NSStringFromClass(_moduleClass),
                                                          @"method": _methodSignature }));
    [self processMethodSignature];
    ABI12_0_0RCT_PROFILE_END_EVENT(ABI12_0_0RCTProfileTagAlways, @"");
  }
  return _selector;
}

- (NSString *)JSMethodName
{
  NSString *methodName = _JSMethodName;
  if (methodName.length == 0) {
    methodName = _methodSignature;
    NSRange colonRange = [methodName rangeOfString:@":"];
    if (colonRange.location != NSNotFound) {
      methodName = [methodName substringToIndex:colonRange.location];
    }
    methodName = [methodName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    ABI12_0_0RCTAssert(methodName.length, @"%@ is not a valid JS function name, please"
              " supply an alternative using ABI12_0_0RCT_REMAP_METHOD()", _methodSignature);
  }
  return methodName;
}

- (ABI12_0_0RCTFunctionType)functionType
{
  if ([_methodSignature rangeOfString:@"ABI12_0_0RCTPromise"].length) {
    return ABI12_0_0RCTFunctionTypePromise;
  } else {
    return ABI12_0_0RCTFunctionTypeNormal;
  }
}

- (id)invokeWithBridge:(ABI12_0_0RCTBridge *)bridge
                module:(id)module
             arguments:(NSArray *)arguments
{
  if (_argumentBlocks == nil) {
    [self processMethodSignature];
  }

  if (ABI12_0_0RCT_DEBUG) {
    // Sanity check
    ABI12_0_0RCTAssert([module class] == _moduleClass, @"Attempted to invoke method \
              %@ on a module of class %@", [self methodName], [module class]);

    // Safety check
    if (arguments.count != _argumentBlocks.count) {
      NSInteger actualCount = arguments.count;
      NSInteger expectedCount = _argumentBlocks.count;

      // Subtract the implicit Promise resolver and rejecter functions for implementations of async functions
      if (self.functionType == ABI12_0_0RCTFunctionTypePromise) {
        actualCount -= 2;
        expectedCount -= 2;
      }

      ABI12_0_0RCTLogError(@"%@.%@ was called with %zd arguments, but expects %zd. \
                  If you haven\'t changed this method yourself, this usually means that \
                  your versions of the native code and JavaScript code are out of sync. \
                  Updating both should make this error go away.",
                  ABI12_0_0RCTBridgeModuleNameForClass(_moduleClass), _JSMethodName,
                  actualCount, expectedCount);
      return nil;
    }
  }

  // Set arguments
  NSUInteger index = 0;
  for (id json in arguments) {
    ABI12_0_0RCTArgumentBlock block = _argumentBlocks[index];
    if (!block(bridge, index, ABI12_0_0RCTNilIfNull(json))) {
      // Invalid argument, abort
      ABI12_0_0RCTLogArgumentError(self, index, json,
                          "could not be processed. Aborting method call.");
      return nil;
    }
    index++;
  }

  // Invoke method
  [_invocation invokeWithTarget:module];

  ABI12_0_0RCTAssert(
    @encode(ABI12_0_0RCTArgumentBlock)[0] == _C_ID,
    @"Block type encoding has changed, it won't be released. A check for the block"
     "type encoding (%s) has to be added below.",
    @encode(ABI12_0_0RCTArgumentBlock)
  );

  index = 2;
  for (NSUInteger length = _invocation.methodSignature.numberOfArguments; index < length; index++) {
    if ([_invocation.methodSignature getArgumentTypeAtIndex:index][0] == _C_ID) {
      __unsafe_unretained id value;
      [_invocation getArgument:&value atIndex:index];

      if (value) {
        CFRelease((__bridge CFTypeRef)value);
      }
    }
  }

  return nil;
}

- (NSString *)methodName
{
  if (_selector == NULL) {
    [self processMethodSignature];
  }
  return [NSString stringWithFormat:@"-[%@ %@]", _moduleClass,
          NSStringFromSelector(_selector)];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<%@: %p; exports %@ as %@()>",
          [self class], self, [self methodName], self.JSMethodName];
}

@end
