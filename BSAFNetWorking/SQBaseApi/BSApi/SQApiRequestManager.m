//
//  SQApiRequestManager.m
//  SQBJ-IOS
//
//  Created by 一枫 on 2018/8/25.
//  Copyright © 2018年 SQBJ. All rights reserved.
//

#import "SQApiRequestManager.h"
#import <AFNetworking/UIProgressView+AFNetworking.h>

@interface SQApiRequestManager ()

@property (nonatomic,strong)NSMutableURLRequest *currentRequest;      //当前请求的URLRequest
@property (nonatomic,copy)NSString *url;                              //请求url
@property (nonatomic,strong)NSDictionary *parameter;                  //请求参数

@end

@implementation SQApiRequestManager


+(instancetype)requestWithUrl:(NSString *)url parameter:(NSDictionary *)parameter requestMethod:(NSString *)requestMethod{
    
    return [[self alloc]initRequestWithUrl:url parameter:parameter requestMethod:requestMethod];
}

-(instancetype)initRequestWithUrl:(NSString *)url parameter:(NSDictionary *)parameter requestMethod:(NSString *)requestMethod{
    
    self = [super init];
    if (self) {
       
        _sessionManager = [[AFHTTPSessionManager alloc]init];
        //请求设置
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        _sessionManager.requestSerializer.timeoutInterval = 45;
//        if ([url hasSuffix:@"https://"]) {
//            [_sessionManager setSecurityPolicy:[self customSecurityPolicy]];
//        }

        //请求响应设置
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json", @"text/javascript",@"text/xml",@"multipart/form-data", nil];

        //参数全局接收
        //对URL进行UTF8编码处理中文
        NSString *encodeUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)url,(CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",NULL,kCFStringEncodingUTF8));
        self.url = encodeUrl;
        self.parameter = parameter;
        
        self.headerParam = [NSMutableDictionary dictionary];
        self.requestMethod = requestMethod;
        self.isBodyRequest = NO;
    }
    return self;
}

/**
 设置请求头
 */
-(void)setRequestHeader{
    __weak typeof(self)weakSelf = self;
    [self.headerParam enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [weakSelf.currentRequest setValue:weakSelf.headerParam[key] forHTTPHeaderField:key];
    }];
}


-(void)startRequestWithSuccess:(SQApiSuccessBlock)successBlock failure:(SQApiFailureBlock)failure{
    
    self.successBlock = successBlock;
    self.failureBlock = failure;
    [self initRequest];
    [self startRequest];
}

-(void)initRequest{
    if (!self.currentRequest) {
        self.currentRequest = [[AFJSONRequestSerializer serializer] requestWithMethod:_requestMethod URLString:self.url parameters:self.isBodyRequest?nil:self.parameter error:nil];
    }
    if (self.isBodyRequest) {
        //将参数转为data
        NSError *error = nil;
        NSData *paramData = [NSJSONSerialization dataWithJSONObject:self.parameter options:NSJSONWritingPrettyPrinted|NSJSONReadingMutableContainers error:&error];
        if (!error) {
            //将body体进行U8编码，在转data
            NSString *paramString = [[NSString alloc] initWithData:paramData encoding:NSUTF8StringEncoding];
            NSData *body  =[paramString dataUsingEncoding:NSUTF8StringEncoding];
            
            [self.currentRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [self.currentRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [self.currentRequest setHTTPBody:body];
            
        }else{
            NSLog(@"body体为空");
        }
    }
}

#pragma mark - 发起普通网络请求

-(void)startRequest{

    [self setRequestHeader];
    
    //如果是表单格式,则将requestSerializer设置成AFHTTPRequestSerializer不是json
    if ([self.headerParam[@"Content-Type"] isEqualToString:@"application/x-www-form-urlencoded"]) {
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    //发起请求
    [[_sessionManager dataTaskWithRequest:self.currentRequest uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
       
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode == 200) {
            SQApiResponse *response = [SQApiResponse responseWithObject:responseObject];
            self.successBlock(response);
        }else{
            
            //将error的UserInfo改造成 带有httpResponse.statusCode的UserInfo
            NSMutableDictionary *myUserInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            [myUserInfo setObject:@(httpResponse.statusCode) forKey:@"statusCode"];
            [myUserInfo setObject:@"网络请求错误，请检查网络是否可用" forKey:@"errorMsg"];

            NSError *myError = [[NSError alloc]initWithDomain:error.domain code:error.code userInfo:myUserInfo];
            SQApiResponseError *responseError = [SQApiResponseError responseErrorWithError:myError];
            responseError.errorMsg = @"网络请求错误，请检查网络是否可用";
            self.failureBlock(responseError);
        }
    }]resume];
}

#pragma mark - 文件下载

-(void)downloadTaskWithFilePath:(NSString *)filePath progress:(SQApiProgressBlock)progressBlock success:(SQApiSuccessBlock)successBlock failure:(SQApiFailureBlock)failure{
    
    if (!filePath || [filePath isEqualToString:@""]) {
        NSLog(@"----------------文件保存路径不能为空----------------");
        return;
    }
    
    self.progressBlock = progressBlock;
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];

    __weak typeof(self)weakSelf = self;
    [self.headerParam enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:weakSelf.headerParam[key] forHTTPHeaderField:key];
    }];
    
    NSURLSessionDownloadTask* downloadTask =[_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {

        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(downloadProgress);
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        return [NSURL fileURLWithPath:filePath isDirectory:NO];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (!error) {
            SQApiResponse *res = [SQApiResponse responseWithObject:response];
            successBlock(res);
        }else{
            SQApiResponseError *responseError = [SQApiResponseError responseErrorWithError:error];
            failure(responseError);
        }
    }];
    
    [downloadTask resume];
}

#pragma mark - 文件上传

-(void)uploadTaskWithIdentifier:(NSString *)identifier filePath:(NSString *)filePath progress:(SQApiProgressBlock)progressBlock success:(SQApiSuccessBlock)successBlock failure:(SQApiFailureBlock)failure{
    
    NSURL *fileUrl = [NSURL URLWithString:filePath];
    
    [_sessionManager POST:self.url parameters:self.parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:fileUrl name:identifier error:nil];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progressBlock(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SQApiResponse *res = [SQApiResponse responseWithObject:responseObject];
        successBlock(res);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SQApiResponseError *responseError = [SQApiResponseError responseErrorWithError:error];
        failure(responseError);
    }];
}

-(void)uploadTaskWithIdentifier:(NSString *)identifier fileData:(NSData *)fileData progress:(SQApiProgressBlock)progressBlock success:(SQApiSuccessBlock)successBlock failure:(SQApiFailureBlock)failure{
    
    [_sessionManager POST:self.url parameters:self.parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFormData:fileData name:identifier];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progressBlock(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SQApiResponse *res = [SQApiResponse responseWithObject:responseObject];
        successBlock(res);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SQApiResponseError *responseError = [SQApiResponseError responseErrorWithError:error];
        failure(responseError);
    }];
    
}


#pragma mark - 设置HTTPS证书验证
- (AFSecurityPolicy *)customSecurityPolicy{
    //先导入证书，找到证书的路径
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"证书名字" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    if (certData.length<=0) {
        return nil;
    }

    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.validatesDomainName = NO;
    NSSet *set = [[NSSet alloc] initWithObjects:certData, nil];
    securityPolicy.pinnedCertificates = set;
    
    return securityPolicy;
}



@end
