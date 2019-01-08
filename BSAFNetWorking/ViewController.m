//
//  ViewController.m
//  BSAFNetWorking
//
//  Created by 一枫 on 2019/1/2.
//  Copyright © 2019 BlackStar. All rights reserved.
//

#import "ViewController.h"
#import "BSAFNetwroking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self normalRequest];
    [self downLoadRequest];
    
}

-(void)normalRequest{
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

-(void)downLoadRequest{
    
    //requestMethod 无用，随便传
    SQApiRequestManager *manager = [SQApiRequestManager requestWithUrl:@"https://qdcu01.baidupcs.com/file/15edb4d4a0fea954e90c1b56413268e5?bkt=p3-140015edb4d4a0fea954e90c1b56413268e5661c823e0000000744dc&fid=2502983666-250528-1052114395410946&time=1546856714&sign=FDTAXGERLQBHSKfW-DCb740ccc5511e5e8fedcff06b081203-XmP1KEyBEWe0Z3xZzVXmQJuN0A8%3D&to=65&size=476380&sta_dx=476380&sta_cs=0&sta_ft=jpg&sta_ct=6&sta_mt=6&fm2=MH%2CYangquan%2CAnywhere%2C%2Cbeijing%2Ccnc&ctime=1524466712&mtime=1524533841&resv0=cdnback&resv1=0&vuk=2502983666&iv=0&htype=&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=140015edb4d4a0fea954e90c1b56413268e5661c823e0000000744dc&sl=76480590&expires=8h&rt=sh&r=175517512&mlogid=156957960411409391&vbdid=135823164&fin=IMG_6573.jpg&fn=IMG_6573.jpg&rtype=1&dp-logid=156957960411409391&dp-callid=0.1.1&hps=1&tsl=80&csl=80&csign=JD3KwvY%2FO88pWYY6CiGZScTC2xA%3D&so=0&ut=6&uter=4&serv=0&uc=301613628&ti=cdac6978171239807c0793f9aa7e6b09b9c73887c9bb8143305a5e1275657320&by=themis" parameter:nil requestMethod:REQUEST_GET];
    
    [manager downloadTaskWithFilePath:@"/Users/BlackStar/Downloads/myHome.jpg" progress:^(NSProgress *uploadProgress) {
        
        NSString *com = [NSString stringWithFormat:@"%lld",uploadProgress.completedUnitCount];
        NSString *total = [NSString stringWithFormat:@"%lld",uploadProgress.totalUnitCount];

        NSLog(@"下载进度    :   %.2f",com.floatValue/total.floatValue);
        
    } success:^(SQApiResponse *response) {
        
        NSLog(@"接口请求成功结果");
        
    } failure:^(SQApiResponseError *error) {
        
        NSLog(@"接口错误：%@",error.errorDic);
    }];
}

@end
