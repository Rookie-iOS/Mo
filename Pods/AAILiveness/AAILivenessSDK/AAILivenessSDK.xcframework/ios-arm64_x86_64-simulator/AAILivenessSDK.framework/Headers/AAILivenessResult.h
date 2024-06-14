//
//  AAILivenessResult.h
//  AAILivenessSDK
//
//  Created by advance on 2022/10/28.
//  Copyright © 2022 Advance.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AAILivenessResult : NSObject

/// The best quality face image captured by the SDK.
///
/// Note that the default image size is 600x600. You can call `[AAILivenessSDK configResultPictureSize:]` method to customize the size of the image.
/// 
/// @Note This is a distant image.
@property(nonatomic, strong, readonly) UIImage *img;

/// A square image containing only the face area, image size is 300x300.
@property(nonatomic, strong, readonly) UIImage *fullFaceImg;

/// LivenessId. This value can be used to call the anti-spoofing api.
@property(nonatomic, strong, readonly) NSString *livenessId;

@property(nonatomic, strong, readonly, nullable) UIImage *highestQualityOriginSquareImage;

@property(nonatomic, readonly) CGFloat uploadImgCostMillSeconds;

@property(nonatomic, strong, nullable) NSString *transactionId;

/// Base64 string list. It will contain one image for each action, and two images of the best quality.
///
/// @warning Starting from version 3.0.4, this method is no longer available. You can use '[result getImgBase64Str]' and '[result getNearBase64Str]' methods to compose the image sequence.
- (NSArray<NSString *> * _Nullable)imageSequenceList __attribute__((unavailable("Starting from version 3.0.4, this method is no longer available. You can use '[result getImgBase64Str]' and '[result getNearBase64Str]' methods to compose the image sequence.")));

/// Return the base64 string corresponding to the 'img'(distant image) property.
///
/// Internally, this function simply converts the 'img' property to a base64 string.
- (NSString * _Nullable)getImgBase64Str;

/// Return the base64 string corresponding to the near image with the best quality.
- (NSString * _Nullable)getNearBase64Str;

@end

NS_ASSUME_NONNULL_END
