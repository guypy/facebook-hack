#import "ABI12_0_0RCTBridge.h"
#import "ABI12_0_0EXBarCodeScanner.h"
#import "ABI12_0_0EXBarCodeScannerManager.h"
#import "ABI12_0_0RCTEventDispatcher.h"
#import "ABI12_0_0RCTLog.h"
#import "ABI12_0_0RCTUtils.h"

#import "UIView+ReactABI12_0_0.h"

#import <AVFoundation/AVFoundation.h>

@interface ABI12_0_0EXBarCodeScanner ()

@property (nonatomic, weak) ABI12_0_0EXBarCodeScannerManager *manager;
@property (nonatomic, weak) ABI12_0_0RCTBridge *bridge;
@property (nonatomic, copy) ABI12_0_0RCTDirectEventBlock onBarCodeRead;

@end

@implementation ABI12_0_0EXBarCodeScanner

- (id)initWithManager:(ABI12_0_0EXBarCodeScannerManager *)manager bridge:(ABI12_0_0RCTBridge *)bridge
{
  if (self = [super init]) {
    self.manager = manager;
    self.bridge = bridge;
    [self.manager initializeCaptureSessionInput:AVMediaTypeVideo];
    [self.manager startSession];
    [self changePreviewOrientation:[UIApplication sharedApplication]
                                       .statusBarOrientation];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(orientationChanged:)
               name:UIDeviceOrientationDidChangeNotification
             object:nil];
  }
  return self;
}

- (void)onRead:(NSDictionary *)event
{
  if (_onBarCodeRead) {
    _onBarCodeRead(event);
  }
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.manager.previewLayer.frame = self.bounds;
  [self setBackgroundColor:[UIColor blackColor]];
  [self.layer insertSublayer:self.manager.previewLayer atIndex:0];
}

- (void)insertReactABI12_0_0Subview:(UIView *)view atIndex:(NSInteger)atIndex
{
  [self insertSubview:view atIndex:atIndex + 1];
  [super insertReactABI12_0_0Subview:view atIndex:atIndex];
  return;
}

- (void)removeReactABI12_0_0Subview:(UIView *)subview
{
  [subview removeFromSuperview];
  [super removeReactABI12_0_0Subview:subview];
  return;
}

- (void)removeFromSuperview
{
  [self.manager stopSession];
  [super removeFromSuperview];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIDeviceOrientationDidChangeNotification
              object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
  UIInterfaceOrientation orientation =
      [[UIApplication sharedApplication] statusBarOrientation];
  [self changePreviewOrientation:orientation];
}

- (void)changePreviewOrientation:(NSInteger)orientation
{
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    __strong typeof(self) strongSelf = weakSelf;
    if (strongSelf && strongSelf.manager.previewLayer.connection.isVideoOrientationSupported) {
      strongSelf.manager.previewLayer.connection.videoOrientation = orientation;
    }
  });
}

@end
