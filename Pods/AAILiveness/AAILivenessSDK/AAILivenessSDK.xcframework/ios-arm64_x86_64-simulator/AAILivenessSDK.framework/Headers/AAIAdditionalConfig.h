//
//  AAIAdditionalConfig.h
//  AAILivenessSDK
//
//  Created by advance on 2022/11/17.
//  Copyright © 2022 Advance.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AAILivenessSDK/AAIDetectionConstant.h>

NS_ASSUME_NONNULL_BEGIN

@interface AAIAdditionalConfig : NSObject

/// The color of the round border in the avatar preview area. Default is clear color.
/// @warning This property only works on version 2.x.x
@property(nonatomic) UIColor *roundBorderColor;

/// The color of the ellipse dashed line that appears during the liveness detection. Default is white color.
/// @warning This property only works on version 2.x.x
@property(nonatomic) UIColor *ellipseLineColor;

/// The color of the ellipse border in 3D mode(near/distant mode). Default is 0x5CC414.
@property(nonatomic, nullable) UIColor *ellipseBorderCol3D;

/// The color of the inner ellipse animation line of the 3D mode(near/distant mode). Default is 0x5CC414.
@property(nonatomic, nullable) UIColor *innerEllipseLineCol3D;

/// The difficulty of liveness detection. Default is AAIDetectionLevelNormal.
@property(nonatomic) AAIDetectionLevel detectionLevel;

/// In versions prior to SDK v3.0.0, this value only represents the timeout duration during the preparation stage.
///
/// From SDK v3.0.0 and later, this value actually represents the timeout duration in 3D mode(near/distant mode).
/// This time duration does not include network request duration.
///
/// @warning The range of values should be [10s, 60s], default is 50s.
///
@property(nonatomic) NSInteger prepareTimeoutInterval;

/// The SDK can have different operating modes, such as silent detection mode, default mode(action mode). Default is 'AAILDOperatingModeSilent'.
@property(nonatomic, readonly) AAILDOperatingMode operatingMode;

@end

NS_ASSUME_NONNULL_END
