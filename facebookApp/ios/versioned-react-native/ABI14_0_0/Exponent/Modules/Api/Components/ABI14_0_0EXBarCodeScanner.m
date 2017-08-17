#import <ReactABI14_0_0/ABI14_0_0RCTBridge.h>
#import "ABI14_0_0EXBarCodeScanner.h"
#import "ABI14_0_0EXBarCodeScannerManager.h"
#import <ReactABI14_0_0/ABI14_0_0RCTEventDispatcher.h>
#import <ReactABI14_0_0/ABI14_0_0RCTLog.h>
#import <ReactABI14_0_0/ABI14_0_0RCTUtils.h>

#import <ReactABI14_0_0/UIView+ReactABI14_0_0.h>

#import <AVFoundation/AVFoundation.h>

@interface ABI14_0_0EXBarCodeScanner ()

@property (nonatomic, weak) ABI14_0_0EXBarCodeScannerManager *manager;
@property (nonatomic, weak) ABI14_0_0RCTBridge *bridge;
@property (nonatomic, copy) ABI14_0_0RCTDirectEventBlock onBarCodeRead;

@end

@implementation ABI14_0_0EXBarCodeScanner

- (id)initWithManager:(ABI14_0_0EXBarCodeScannerManager *)manager bridge:(ABI14_0_0RCTBridge *)bridge
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

- (void)insertReactABI14_0_0Subview:(UIView *)view atIndex:(NSInteger)atIndex
{
  [self insertSubview:view atIndex:atIndex + 1];
  [super insertReactABI14_0_0Subview:view atIndex:atIndex];
  return;
}

- (void)removeReactABI14_0_0Subview:(UIView *)subview
{
  [subview removeFromSuperview];
  [super removeReactABI14_0_0Subview:subview];
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
