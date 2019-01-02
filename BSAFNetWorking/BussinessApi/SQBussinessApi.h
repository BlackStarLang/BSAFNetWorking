//
//  SQBussinessApi.h
//  SQBJ-IOS
//
//  Created by 一枫 on 2018/9/6.
//  Copyright © 2018年 SQBJ. All rights reserved.
//

#import "SQApiRequestManager.h"
#import "SQApiRequestManager.h"
#import "SQBussinessResponse.h"

/**
 社区半径接口api
 */

typedef void(^SQBussinessApiSuccessBlock) (SQBussinessResponse *response);
typedef void(^SQBussinessApiFailureBlock) (SQBussinessResponseError *response);



@interface SQBussinessApi : SQApiRequestManager 

@property(nonatomic,strong)SQApiRequestManager *requestManager;                 //当前请求基类
@property(nonatomic,assign)BOOL allowRequest;                                   //是否允许发送请求
@property(nonatomic,assign)BOOL needSQBJToken;                                  //是否需要社区半径accessToken

@property(nonatomic,copy)SQBussinessApiSuccessBlock bussinessSuccessBlock;      //成功的回调
@property(nonatomic,copy)SQBussinessApiFailureBlock bussinessFailureBlock;      //失败的回调


/**
 社区半径接口调用网络API

 @param url url
 @param parameter 参数
 @param requestMethod 请求方式
 */
+(instancetype)initRequestSQBussinessApiWithUrl:(NSString*)url parameter:(NSDictionary*)parameter requestMethod:(NSString*)requestMethod;



/**
 设置请额外的求头（非公共请求头，一些接口可能需要特殊的头部信息）
 公共请求头：请参照setBussinessHeader 方法里的公共头部
 
 @param header 请求头字典
 @param needToken 是否需要token
 */
-(void)setBussinessHeader:(NSDictionary*)header needToken:(BOOL)needToken;



/**
 社区半径接口调用网络API回调

 @param successBlock 成功回调
 @param failure 失败回调
 */
-(void)startRequestWithSuccess:(SQBussinessApiSuccessBlock)successBlock failure:(SQBussinessApiFailureBlock)failure;


@end
