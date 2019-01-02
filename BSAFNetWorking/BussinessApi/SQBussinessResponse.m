//
//  SQBussinessResponse.m
//  SQBJ-IOS
//
//  Created by 一枫 on 2018/9/7.
//  Copyright © 2018年 SQBJ. All rights reserved.
//

#import "SQBussinessResponse.h"

@implementation SQBussinessResponse

+(instancetype)responseWithObject:(id)responseObject{
    
    return [[self alloc]initBussinessDataWithObject:responseObject];
}


/**
 解析数据，若返回错误，解析错误信息和错误码
 
 @param responseObject 要解析的数据
 */
-(instancetype)initBussinessDataWithObject:(id)responseObject{
    self = [super init];
    if (self) {
        self.responseObject = responseObject;
        if ([responseObject objectForKey:@"success"]) {
            _isSuccess = [[responseObject objectForKey:@"success"]boolValue];
            if (!_isSuccess) {
                _errorCode = [responseObject objectForKey:@"code"];
                _errorMsg =  [NSString stringWithFormat:@"%@", [responseObject objectForKey:@"errorMsg"]];
            }
        }
    }
    return self;
}

@end



#pragma 接口错误数据
@implementation SQBussinessResponseError

+(instancetype)responseErrorWithError:(NSError *)error{

    return [super responseErrorWithError:error];
}

@end

