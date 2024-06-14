//
//  AAILivenessFailedResult.h
//  AAILivenessUI
//
//  Created by advance on 2023/4/17.
//  Copyright © 2023 Advance.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// This class is used to convert the NSDictionary errorInfo to an AAILivenessFailedResult object, which is convenient for you to process error information.
@interface AAILivenessFailedResult : NSObject

/// The error codes are as follows:
///
/// @code
/// PREPARE_TIMEOUT  // Timeout during the preparation stage
/// ACTION_TIMEOUT   // Timeout during the motion stage
/// MUTI_FACE        // Multiple faces detected during the motion stage
/// FACE_MISSING     // Face is missing during the motion stage
/// MUCH_ACTION      // Multiple motions detected during the motion stage
/// USER_GIVE_UP     // The user clicked the top left back button during the detection process
/// NO_RESPONSE      // Network request failed
/// UNDEFINED        // Other undefined errors
/// ...(Other server-side error codes)
/// @endcode
///
@property(nonatomic, copy, readonly) NSString *errorCode;

@property(nonatomic, copy, readonly) NSString *errorMsg;

/// The transaction id. Only not empty when a server-side error occurs; otherwise, it is always an empty string.
@property(nonatomic, copy, readonly) NSString *transactionId;

@property(nonatomic, copy, readonly) NSString *rawErrorCode;

/// Convert the NSDictionary errorInfo to an AAILivenessFailedResult object.
+ (AAILivenessFailedResult *)resultWithErrorInfo:(NSDictionary *)errorInfo;

@end

NS_ASSUME_NONNULL_END
