
#import <UIKit/UIKit.h>

#import <ReactABI15_0_0/ABI15_0_0RCTConvert.h>
#import <ReactABI15_0_0/ABI15_0_0RCTEventEmitter.h>

@interface ABI15_0_0RCTConvert (ABI15_0_0EXStatusBar)

#if !TARGET_OS_TV
+ (UIStatusBarStyle)UIStatusBarStyle:(id)json;
+ (UIStatusBarAnimation)UIStatusBarAnimation:(id)json;
#endif

@end

@interface ABI15_0_0EXStatusBarManager : ABI15_0_0RCTEventEmitter

@end
