//
//  SQBussinessResponse.h
//  SQBJ-IOS
//
//  Created by 一枫 on 2018/9/7.
//  Copyright © 2018年 SQBJ. All rights reserved.
//

#import "SQApiResponse.h"

@interface SQBussinessResponse : SQApiResponse

@property(nonatomic ,assign)BOOL isSuccess;               //请求是否成功

@property(nonatomic ,copy)NSString *errorCode;            //status:200下 后台返回的错误码
@property(nonatomic ,copy)NSString* errorMsg;             //status:200后台返回用于展示后台错误信息

@end



/**
 网络请求成功 statusCode !=200 时
 */
@interface SQBussinessResponseError : SQApiResponseError


@end

