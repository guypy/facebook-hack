/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

//Internally we reference a separate library. See https://github.com/facebook/ReactABI12_0_0-native/pull/9544
#if __has_include(<CSSLayout/ABI12_0_0CSSLayout.h>)
#import <CSSLayout/ABI12_0_0CSSLayout.h>
#else
#import "ABI12_0_0CSSLayout.h"
#endif

#import "ABI12_0_0RCTAnimationType.h"
#import "ABI12_0_0RCTBorderStyle.h"
#import "ABI12_0_0RCTTextDecorationLineType.h"
#import "ABI12_0_0RCTDefines.h"
#import "ABI12_0_0RCTLog.h"
#import "ABI12_0_0RCTPointerEvents.h"

/**
 * This class provides a collection of conversion functions for mapping
 * JSON objects to native types and classes. These are useful when writing
 * custom ABI12_0_0RCTViewManager setter methods.
 */
@interface ABI12_0_0RCTConvert : NSObject

+ (id)id:(id)json;

+ (BOOL)BOOL:(id)json;
+ (double)double:(id)json;
+ (float)float:(id)json;
+ (int)int:(id)json;

+ (int64_t)int64_t:(id)json;
+ (uint64_t)uint64_t:(id)json;

+ (NSInteger)NSInteger:(id)json;
+ (NSUInteger)NSUInteger:(id)json;

+ (NSArray *)NSArray:(id)json;
+ (NSDictionary *)NSDictionary:(id)json;
+ (NSString *)NSString:(id)json;
+ (NSNumber *)NSNumber:(id)json;

+ (NSSet *)NSSet:(id)json;
+ (NSData *)NSData:(id)json;
+ (NSIndexSet *)NSIndexSet:(id)json;

+ (NSURL *)NSURL:(id)json;
+ (NSURLRequest *)NSURLRequest:(id)json;

typedef NSURL ABI12_0_0RCTFileURL;
+ (ABI12_0_0RCTFileURL *)ABI12_0_0RCTFileURL:(id)json;

+ (NSDate *)NSDate:(id)json;
+ (NSTimeZone *)NSTimeZone:(id)json;
+ (NSTimeInterval)NSTimeInterval:(id)json;

+ (NSLineBreakMode)NSLineBreakMode:(id)json;
+ (NSTextAlignment)NSTextAlignment:(id)json;
+ (NSUnderlineStyle)NSUnderlineStyle:(id)json;
+ (NSWritingDirection)NSWritingDirection:(id)json;
+ (UITextAutocapitalizationType)UITextAutocapitalizationType:(id)json;
+ (UITextFieldViewMode)UITextFieldViewMode:(id)json;
+ (UIKeyboardType)UIKeyboardType:(id)json;
+ (UIKeyboardAppearance)UIKeyboardAppearance:(id)json;
+ (UIReturnKeyType)UIReturnKeyType:(id)json;
#if !TARGET_OS_TV
+ (UIDataDetectorTypes)UIDataDetectorTypes:(id)json;
#endif

+ (UIViewContentMode)UIViewContentMode:(id)json;
#if !TARGET_OS_TV
+ (UIBarStyle)UIBarStyle:(id)json;
#endif

+ (CGFloat)CGFloat:(id)json;
+ (CGPoint)CGPoint:(id)json;
+ (CGSize)CGSize:(id)json;
+ (CGRect)CGRect:(id)json;
+ (UIEdgeInsets)UIEdgeInsets:(id)json;

+ (CGLineCap)CGLineCap:(id)json;
+ (CGLineJoin)CGLineJoin:(id)json;

+ (CATransform3D)CATransform3D:(id)json;
+ (CGAffineTransform)CGAffineTransform:(id)json;

+ (UIColor *)UIColor:(id)json;
+ (CGColorRef)CGColor:(id)json CF_RETURNS_NOT_RETAINED;

+ (NSArray<NSArray *> *)NSArrayArray:(id)json;
+ (NSArray<NSString *> *)NSStringArray:(id)json;
+ (NSArray<NSArray<NSString *> *> *)NSStringArrayArray:(id)json;
+ (NSArray<NSDictionary *> *)NSDictionaryArray:(id)json;
+ (NSArray<NSURL *> *)NSURLArray:(id)json;
+ (NSArray<ABI12_0_0RCTFileURL *> *)ABI12_0_0RCTFileURLArray:(id)json;
+ (NSArray<NSNumber *> *)NSNumberArray:(id)json;
+ (NSArray<UIColor *> *)UIColorArray:(id)json;

typedef NSArray CGColorArray;
+ (CGColorArray *)CGColorArray:(id)json;

/**
 * Convert a JSON object to a Plist-safe equivalent by stripping null values.
 */
typedef id NSPropertyList;
+ (NSPropertyList)NSPropertyList:(id)json;

typedef BOOL css_backface_visibility_t;
+ (ABI12_0_0CSSOverflow)ABI12_0_0CSSOverflow:(id)json;
+ (css_backface_visibility_t)css_backface_visibility_t:(id)json;
+ (ABI12_0_0CSSFlexDirection)ABI12_0_0CSSFlexDirection:(id)json;
+ (ABI12_0_0CSSJustify)ABI12_0_0CSSJustify:(id)json;
+ (ABI12_0_0CSSAlign)ABI12_0_0CSSAlign:(id)json;
+ (ABI12_0_0CSSPositionType)ABI12_0_0CSSPositionType:(id)json;
+ (ABI12_0_0CSSWrapType)ABI12_0_0CSSWrapType:(id)json;

+ (ABI12_0_0RCTPointerEvents)ABI12_0_0RCTPointerEvents:(id)json;
+ (ABI12_0_0RCTAnimationType)ABI12_0_0RCTAnimationType:(id)json;
+ (ABI12_0_0RCTBorderStyle)ABI12_0_0RCTBorderStyle:(id)json;
+ (ABI12_0_0RCTTextDecorationLineType)ABI12_0_0RCTTextDecorationLineType:(id)json;

@end

@interface ABI12_0_0RCTConvert (Deprecated)

/**
 * Use lightweight generics syntax instead, e.g. NSArray<NSString *>
 */
typedef NSArray NSArrayArray __deprecated_msg("Use NSArray<NSArray *>");
typedef NSArray NSStringArray __deprecated_msg("Use NSArray<NSString *>");
typedef NSArray NSStringArrayArray __deprecated_msg("Use NSArray<NSArray<NSString *> *>");
typedef NSArray NSDictionaryArray __deprecated_msg("Use NSArray<NSDictionary *>");
typedef NSArray NSURLArray __deprecated_msg("Use NSArray<NSURL *>");
typedef NSArray ABI12_0_0RCTFileURLArray __deprecated_msg("Use NSArray<ABI12_0_0RCTFileURL *>");
typedef NSArray NSNumberArray __deprecated_msg("Use NSArray<NSNumber *>");
typedef NSArray UIColorArray __deprecated_msg("Use NSArray<UIColor *>");

/**
 * Synchronous image loading is generally a bad idea for performance reasons.
 * If you need to pass image references, try to use `ABI12_0_0RCTImageSource` and then
 * `ABI12_0_0RCTImageLoader` instead of converting directly to a UIImage.
 */
+ (UIImage *)UIImage:(id)json;
+ (CGImageRef)CGImage:(id)json CF_RETURNS_NOT_RETAINED;

@end

/**
 * Underlying implementations of ABI12_0_0RCT_XXX_CONVERTER macros. Ignore these.
 */
ABI12_0_0RCT_EXTERN NSNumber *ABI12_0_0RCTConvertEnumValue(const char *, NSDictionary *, NSNumber *, id);
ABI12_0_0RCT_EXTERN NSNumber *ABI12_0_0RCTConvertMultiEnumValue(const char *, NSDictionary *, NSNumber *, id);
ABI12_0_0RCT_EXTERN NSArray *ABI12_0_0RCTConvertArrayValue(SEL, id);

/**
 * Get the converter function for the specified type
 */
ABI12_0_0RCT_EXTERN SEL ABI12_0_0RCTConvertSelectorForType(NSString *type);

/**
 * This macro is used for logging conversion errors. This is just used to
 * avoid repeating the same boilerplate for every error message.
 */
#define ABI12_0_0RCTLogConvertError(json, typeName) \
ABI12_0_0RCTLogError(@"JSON value '%@' of type %@ cannot be converted to %@", \
json, [json classForCoder], typeName)

/**
 * This macro is used for creating simple converter functions that just call
 * the specified getter method on the json value.
 */
#define ABI12_0_0RCT_CONVERTER(type, name, getter) \
ABI12_0_0RCT_CUSTOM_CONVERTER(type, name, [json getter])

/**
 * This macro is used for creating converter functions with arbitrary logic.
 */
#define ABI12_0_0RCT_CUSTOM_CONVERTER(type, name, code) \
+ (type)name:(id)json                          \
{                                              \
  if (!ABI12_0_0RCT_DEBUG) {                            \
    return code;                               \
  } else {                                     \
    @try {                                     \
      return code;                             \
    }                                          \
    @catch (__unused NSException *e) {         \
      ABI12_0_0RCTLogConvertError(json, @#type);        \
      json = nil;                              \
      return code;                             \
    }                                          \
  }                                            \
}

/**
 * This macro is similar to ABI12_0_0RCT_CONVERTER, but specifically geared towards
 * numeric types. It will handle string input correctly, and provides more
 * detailed error reporting if an invalid value is passed in.
 */
#define ABI12_0_0RCT_NUMBER_CONVERTER(type, getter) \
ABI12_0_0RCT_CUSTOM_CONVERTER(type, type, [ABI12_0_0RCT_DEBUG ? [self NSNumber:json] : json getter])

/**
 * This macro is used for creating converters for enum types.
 */
#define ABI12_0_0RCT_ENUM_CONVERTER(type, values, default, getter) \
+ (type)type:(id)json                                     \
{                                                         \
  static NSDictionary *mapping;                           \
  static dispatch_once_t onceToken;                       \
  dispatch_once(&onceToken, ^{                            \
    mapping = values;                                     \
  });                                                     \
  return [ABI12_0_0RCTConvertEnumValue(#type, mapping, @(default), json) getter]; \
}

/**
 * This macro is used for creating converters for enum types for
 * multiple enum values combined with | operator
 */
#define ABI12_0_0RCT_MULTI_ENUM_CONVERTER(type, values, default, getter) \
+ (type)type:(id)json                                     \
{                                                         \
  static NSDictionary *mapping;                           \
  static dispatch_once_t onceToken;                       \
  dispatch_once(&onceToken, ^{                            \
    mapping = values;                                     \
  });                                                     \
  return [ABI12_0_0RCTConvertMultiEnumValue(#type, mapping, @(default), json) getter]; \
}

/**
 * This macro is used for creating converter functions for typed arrays.
 */
#define ABI12_0_0RCT_ARRAY_CONVERTER(type)                      \
+ (NSArray<type *> *)type##Array:(id)json              \
{                                                      \
  return ABI12_0_0RCTConvertArrayValue(@selector(type:), json); \
}
