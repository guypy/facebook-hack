//
//  ABI18_0_0AIRGoogleMapCallout.h
//  AirMaps
//
//  Created by Gil Birman on 9/6/16.
//
//

#import <UIKit/UIKit.h>
#import <ReactABI18_0_0/ABI18_0_0RCTView.h>

@interface ABI18_0_0AIRGoogleMapCallout : UIView
@property (nonatomic, assign) BOOL tooltip;
@property (nonatomic, copy) ABI18_0_0RCTBubblingEventBlock onPress;
@end
