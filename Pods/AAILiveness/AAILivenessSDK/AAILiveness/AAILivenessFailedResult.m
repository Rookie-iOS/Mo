//
//  AAILivenessFailedResult.m
//  AAILivenessUI
//
//  Created by advance on 2023/4/17.
//  Copyright © 2023 Advance.ai. All rights reserved.
//

#import "AAILivenessFailedResult.h"

#define AAIIsNullOrEmpty(value) ((value == nil) || (value.length == 0))

@implementation AAILivenessFailedResult

+ (AAILivenessFailedResult *)resultWithErrorInfo:(NSDictionary *)errorInfo
{
    return [[AAILivenessFailedResult alloc] initWithErrorInfo:errorInfo];
}

- (instancetype)initWithErrorInfo:(NSDictionary *)errorInfo
{
    self = [super init];
    if (self) {
        [self parseErrorInfo:errorInfo];
    }
    return self;
}

- (void)parseErrorInfo:(NSDictionary *)errorInfo
{
    NSString *rawErrorCode = errorInfo[@"key"];
    NSString *finalErrorCode = @"";
    NSString *rawErrorMsg = @"";
    NSString *tid = @"";
    
    if (AAIIsNullOrEmpty(rawErrorCode)) {
        tid = errorInfo[@"transactionId"];
        if (AAIIsNullOrEmpty(tid)) {
            // Network error
            tid = @"";
            finalErrorCode = @"no_response";
            
            rawErrorMsg = errorInfo[@"message"];
            if (AAIIsNullOrEmpty(rawErrorMsg)) {
                rawErrorMsg = @"network request failed";
            }
        } else {
            // Server side error
            finalErrorCode = errorInfo[@"rawCode"];
            rawErrorMsg = errorInfo[@"message"];
        }
        
    } else {
        // SDK error
        NSDictionary *map = @{
            @"fail_reason_prepare_timeout": @"prepare_timeout",
            @"fail_reason_timeout": @"action_timeout",
            @"fail_reason_muti_face": @"muti_face",
            @"fail_reason_facemiss_blink_mouth": @"face_missing",
            @"fail_reason_facemiss_pos_yaw": @"face_missing",
            @"fail_reason_much_action": @"much_action",
            @"user_give_up": @"user_give_up"
        };
        
        finalErrorCode = map[rawErrorCode];
        rawErrorMsg = errorInfo[@"state"];
    }
    
    if (finalErrorCode == nil) {
        finalErrorCode = @"undefined";
    }
    if (rawErrorCode == nil) {
        rawErrorCode = @"undefined";
    }
    if (rawErrorMsg == nil) {
        rawErrorMsg = @"";
    }
    if (tid == nil) {
        tid = @"";
    }
    
    _errorCode = [finalErrorCode uppercaseString];
    _rawErrorCode = rawErrorCode;
    _errorMsg = rawErrorMsg;
    _transactionId = tid;
}

@end
