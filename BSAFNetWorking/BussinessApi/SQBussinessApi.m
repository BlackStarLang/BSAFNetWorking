//
//  SQBussinessApi.m
//  SQBJ-IOS
//
//  Created by 一枫 on 2018/9/6.
//  Copyright © 2018年 SQBJ. All rights reserved.
//

#import "SQBussinessApi.h"
#import "SQNetStatusObserver.h"

static NSMutableArray *SQ_REQUEST_WAITARR = nil;         //社区半径token刷新时，等待请求的请求池
static BOOL SQ_TOKEN_LOCK = NO;                          //社区半径token刷新时，对token接口上锁，防止多次请求


@interface SQBussinessApi () <SQNetStatusObserverDelegate>

@property(nonatomic,copy,readonly) NSString *url;        //请求地址

@property(nonatomic,assign) AFNetworkReachabilityStatus netWorkStatus;        //当前网络状态

@end

/**
 社区半径业务API
 */
@implementation SQBussinessApi

+(instancetype)initRequestSQBussinessApiWithUrl:(NSString *)url parameter:(NSDictionary *)parameter requestMethod:(NSString *)requestMethod{
    
    return [[self alloc]initRequestWithUrl:url parameter:parameter requestMethod:requestMethod];
}


-(instancetype)initRequestWithUrl:(NSString *)url parameter:(NSDictionary *)parameter requestMethod:(NSString *)requestMethod{
    
    self = [super init];
    if (self) {
        
        if (!SQ_REQUEST_WAITARR) {
            SQ_REQUEST_WAITARR = [NSMutableArray array];
        }
        
        self.requestManager = [SQApiRequestManager requestWithUrl:url parameter:parameter requestMethod:requestMethod];
        self.netWorkStatus = 2;
        [SQNetStatusObserver shareNetStatusObserver].netStatusDelegate = self;
        
        self.allowRequest = YES;
        _needSQBJToken = YES;
        _url = url;
    }
    return self;
}

-(void)netWorkStatus:(AFNetworkReachabilityStatus)netWorkStatus{
    self.netWorkStatus = netWorkStatus;
}

/**
 设置非默认请求头
 
 @param header 请求头
 @param needToken 是否需要token，不设置则默认需要token
 */
-(void)setBussinessHeader:(NSDictionary *)header needToken:(BOOL)needToken{
    __weak typeof(self)weakSelf = self;
    [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [weakSelf.requestManager.headerParam setObject:obj forKey:key];
    }];
    _needSQBJToken = needToken;
}


-(void)setNeedSQBJToken:(BOOL)needSQBJToken{
    _needSQBJToken = needSQBJToken;
}


/**
 设置请求头
 */
-(void)setBussinessHeader{
    
    [self.requestManager.headerParam setObject:@"SQBJ-IOS" forKey:@"API-Client-Type"];
    [self.requestManager.headerParam setObject:@"2ee3b63f52cd0f226e76707e09447de799e43f7f" forKey:@"API-Client-ID"];
    
    [self.requestManager.headerParam setObject:@"3400" forKey:@"API-App-Version-Code"];
    [self.requestManager.headerParam setObject:@"3.4.0" forKey:@"API-App-Version"];
    
    [self.requestManager.headerParam setObject:@"NO" forKey:@"API-App-Is-Simulator"];
    
    [self.requestManager.headerParam setObject:@"" forKey:@"API-App-Community-Ext-ID"];
    [self.requestManager.headerParam setObject:@"" forKey:@"API-App-Community-ID"];
    
    //逻辑，如果有token就先给，如果明确要求：_needSQBJToken=no，在把token清掉，因为很多接口设计为：有token就给，没有token就不给（如首页数据接口）
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"ACCESS_TOKEN"]) {
        [self.requestManager.headerParam setObject:@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1Mzg4OTc2NDQsIm9wZW5faWQiOiJiZWUwNWNkMS1hYmY4LTRkMTEtOGFiYS1iYTg2NjQ5ODg5ODEiLCJ1c2VyX25hbWUiOiIxODIxMDQ0MjM0OSIsImp0aSI6ImQxMWQzMTk5LTNiN2ItNDA5Ni05MjU4LTMxYzg3YzQwNzA3NyIsImNsaWVudF9pZCI6InNxYmotc2VydmVyIiwic2NvcGUiOlsiU1FCSi1BTEwiXX0.emUJ-uJuLriZcsuEaNMWm-B7m1aUcEgz4J08VKBIellw_VWiPYiNomA8p8Lcu1wu0D0_fE5CAyYPy5RIGbrTvvA86Z5FLjMOxIT0X9GSRJe0PqavmcyFZmCKklItnt1XmWluRCs-miTVCrJqC25pray-DLz6YNpiJExIyyBgF5jFk0p4R8eg_l8Qj0KU_TRMJabzmz7F7z609lLfkBWpN5UrWRbB0HoCDifVztTWziPNQo-ETtROo7DGwKDAtsL2lAJQYwY1sbu_Ji4u4F6mE5YmTzUEyuZHgVG1xtixA1axBmn3WckHw_to9PuOMmNQ7VomUXI67IzLbA9aXWlr6Q" forKey:@"API-Access-Token"];
    }
    
    if (_needSQBJToken) {
        self.allowRequest = NO;
        [self getSQBJToken];
    }else{
        [self.requestManager.headerParam removeObjectForKey:@"API-Access-Token"];
        self.allowRequest = YES;
    }
}



/**
 开始请求数据
 */
-(void)startRequestWithSuccess:(SQBussinessApiSuccessBlock)successBlock failure:(SQBussinessApiFailureBlock)failure{
    
    //发起请求时，设置header
    [self setBussinessHeader];
    
    if (self.netWorkStatus == 0|| self.netWorkStatus == -1) {
        SQBussinessResponseError *bussError = [[SQBussinessResponseError alloc]init];
        bussError.statusCode = 99999;
        bussError.errorCode = 99999;
        bussError.errorMsg = @"当前网络不可用";
        failure(bussError);
        self.allowRequest = NO;
    }
    
    if (!self.allowRequest) {
        return;
    }
    
    //开始请求
    [self.requestManager startRequestWithSuccess:^(SQApiResponse *response) {
        
        SQBussinessResponse *bussResponse = [SQBussinessResponse responseWithObject:response.responseObject];
        
        if (bussResponse.isSuccess) {
            successBlock(bussResponse);
        }else{
            [self handleErrorWithBussinessResponse:bussResponse failure:failure];
        }
        
    } failure:^(SQApiResponseError *error) {
        
        SQBussinessResponseError *bussError = (SQBussinessResponseError*)error;
        
        failure(bussError);
    }];
}



/**
 200状态码下的错误信息回调处理
 
 @param bussResponse 后天返回的错误信息模型
 */
-(void)handleErrorWithBussinessResponse:(SQBussinessResponse*)bussResponse failure:(SQBussinessApiFailureBlock)failure{
    if ([bussResponse.errorCode isEqualToString:@"AU0002"]) {
        
        [self getSQBJToken];
        
    }else if([bussResponse.errorCode isEqualToString:@"AU0001"]){
        //跳到登录页面
        NSLog(@"身份信息无效，需重新登录");
        failure = nil;
    }else{
        //社区半径后台错误，statusCode = 200 ,提供errorMsg 供展示
        NSError *error = [[NSError alloc]initWithDomain:self.url code:200 userInfo:@{@"errorType":@"SQBJ_INNER_ERROR",@"errorMsg":bussResponse.errorMsg}];
        
        SQBussinessResponseError * responseError = [SQBussinessResponseError responseErrorWithError:error];
        //统一错误信息格式，社区半径系统内部错误
        NSDictionary *errorData = @{@"errorType":@"SQBJ_INNER_ERROR",@"errorMsg":bussResponse.errorMsg,@"statusCode":@(200),@"errorCode":bussResponse.errorCode};
        NSMutableDictionary *errorDic = [NSMutableDictionary dictionaryWithDictionary:errorData];
        responseError.errorDic = errorDic;
        responseError.errorMsg = bussResponse.errorMsg?:@"系统内部异常，请稍后重试";
        
        failure(responseError);
    }
}


/**
 刷新token
 */
-(void)getSQBJToken{
    
    if (![SQ_REQUEST_WAITARR containsObject:self]) {
        [SQ_REQUEST_WAITARR addObject:self];
    }
    if (SQ_TOKEN_LOCK) {
        return;
    }
    SQ_TOKEN_LOCK = YES;
    
    NSString *url = [NSString stringWithFormat:@"%@/login/refresh?userOpenId=%@",@"",@""];
    SQBussinessApi *request = [SQBussinessApi initRequestSQBussinessApiWithUrl:url parameter:nil requestMethod:REQUEST_GET];
    [request startRequestWithSuccess:^(SQBussinessResponse *response) {
        SQ_TOKEN_LOCK = NO;
        
        [SQ_REQUEST_WAITARR enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != request) {
                SQBussinessApi *objRequest = obj;
                objRequest.allowRequest = YES;
                [@[objRequest] makeObjectsPerformSelector:@selector(startRequest)];
            }
        }];
        [SQ_REQUEST_WAITARR removeAllObjects];
        
    } failure:^(SQApiResponseError *error) {
        SQ_TOKEN_LOCK = NO;
        [SQ_REQUEST_WAITARR removeAllObjects];
        //跳入登录界面
        NSLog(@"身份信息无效，需重新登录");
        
    }];
}



@end
