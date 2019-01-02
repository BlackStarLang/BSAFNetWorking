//
//  ViewController.m
//  BSAFNetWorking
//
//  Created by 一枫 on 2019/1/2.
//  Copyright © 2019 BlackStar. All rights reserved.
//

#import "ViewController.h"
#import "SQApiRequestManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     说明: BussinessApi 为我司业务 网络请求类，
     一般使用基类来说不能完美的服务于公司业务，还需要再次封装一次，
     这里将BussinessApi 代码给了出来是为了给开发者一个明确的使用示例，可以忽略
     */
    
    
    //以下示例代码为基类调用方法
    
    NSString *url = @"https://api.apiopen.top/EmailSearch";
    NSDictionary *parameter = @{@"number":@"1012002"};
    
    SQApiRequestManager *manager = [SQApiRequestManager requestWithUrl:url parameter:parameter requestMethod:REQUEST_GET];
    
    /*
     设置header 代码案例
     实际上是可以不设置的，常用的请求头都是内置的，除非改变他的值
     例如：contentType = application/x-www-form-urlencoded
     这里只是用来做例子
     */
    [manager.headerParam setObject:@"application/json" forKey:@"contentType"];
    
    /*
     如果是body体请求
     manager.isBodyRequest = YES;
     */
    
    //发送请求
    [manager startRequestWithSuccess:^(SQApiResponse *response) {
    
        NSLog(@"openAPI快递信息接口查询结果：%@",response.responseObject);
   
    } failure:^(SQApiResponseError *error) {
    
        NSLog(@"openAPI接口错误：%@",error.errorDic);
    }];
}


@end
