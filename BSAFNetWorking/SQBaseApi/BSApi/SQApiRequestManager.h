//
//  SQApiRequestManager.h
//  SQBJ-IOS
//
//  Created by 一枫 on 2018/8/25.
//  Copyright © 2018年 SQBJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "SQApiResponse.h"

#define REQUEST_GET         @"GET"
#define REQUEST_POST        @"POST"
#define REQUEST_PUT         @"PUT"
#define REQUEST_DELETE      @"DELETE"


/**
 基础网络请求
 */
@class SQApiResponse;

typedef void(^SQApiSuccessBlock) (SQApiResponse *response);                 //成功的回调
typedef void(^SQApiFailureBlock) (SQApiResponseError *error);               //失败回调
typedef void(^SQApiProgressBlock) (NSProgress *uploadProgress);             //请求进度
typedef void(^SQDownLoadCompleteBlock) (NSURL *filePath, NSError *error);   //下载任务回调

/**
 请求基类
 */
@interface SQApiRequestManager : NSObject

//block 声明
@property (nonatomic, copy) SQApiSuccessBlock successBlock;         //成功回调
@property (nonatomic, copy) SQApiFailureBlock failureBlock;         //失败回调
@property (nonatomic, copy) SQApiProgressBlock progressBlock;       //下载进度回调

//api基类和任务
@property (nonatomic, readonly) AFHTTPSessionManager *sessionManager;

//其他参数
@property (nonatomic, assign) BOOL isBodyRequest;                     //是否是body体请求
@property(nonatomic,strong) NSMutableDictionary *headerParam;         //请求头
@property(nonatomic,copy) NSString *requestMethod;                    //请求方式


/**
 初始化方法

 @param url 请求的url
 @param parameter 请求参数
 @param requestMethod 请求方式  get、post等
 */
+(instancetype)requestWithUrl:(NSString*)url parameter:(NSDictionary*)parameter requestMethod:(NSString*)requestMethod;


/**
 发送请求，用于拦截网络后重新分发调用的
 */
-(void)startRequest;


/**
 发送请求

 @param successBlock 成功回调
 @param failure 失败回调
 */
-(void)startRequestWithSuccess:(SQApiSuccessBlock)successBlock failure:(SQApiFailureBlock)failure;



/**
 下载文件请求

 @param filePath 要下载到的路径，需要带有名称如：download/file/my.txt
 @param progressBlock 下载进度
 @param successBlock 下载成功回调
 @param failure 下载失败回调
 */
-(void)downloadTaskWithFilePath:(NSString *)filePath progress:(SQApiProgressBlock)progressBlock success:(SQApiSuccessBlock)successBlock failure:(SQApiFailureBlock)failure;


/**
 上传文件请求 filePath 方式

 @param identifier 上传文件给后台的参数
 @param filePath  需要上传文件的路径
 @param progressBlock 上传进度
 @param successBlock 上传成功回调
 @param failure 上传失败回调
 */
-(void)uploadTaskWithIdentifier:(NSString *)identifier filePath:(NSString *)filePath progress:(SQApiProgressBlock)progressBlock success:(SQApiSuccessBlock)successBlock failure:(SQApiFailureBlock)failure;

/**
 上传文件请求 data 方式
 
 @param identifier 上传文件给后台的参数
 @param fileData  需要上传文件的data
 @param progressBlock 上传进度
 @param successBlock 上传成功回调
 @param failure 上传失败回调
 */
-(void)uploadTaskWithIdentifier:(NSString *)identifier fileData:(NSData *)fileData progress:(SQApiProgressBlock)progressBlock success:(SQApiSuccessBlock)successBlock failure:(SQApiFailureBlock)failure;

@end
