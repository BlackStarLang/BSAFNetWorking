# 该代码仅用于测试、学习使用（ps:个人做第一个pod的测试样例), 代码功能不完善，写法规范度低
# BSAFNetWorking
对 AFNetWorking 进行封装 <br/>
提供body体请求（setHTTPBody方式），提供表单格式方式请求（application/x-www-form-urlencoded） <br/>
提供文件上传、下载功能，进度回调 等基础功能 <br/>

Usage<br/>
两种方式
1. 直接下载导入 
2. pod 导入：pod 'BSAFNetWorking'

导入后 引入 #import <BSAFNetwroking.h>

```
//具体代码示例
NSString *url = [NSString stringWithFormat:@"https://www.apiopen.top/weatherApi?city=%@",cityName];
    
    SQApiRequestManager *manager = [SQApiRequestManager requestWithUrl:url parameter:nil requestMethod:REQUEST_GET];
    
    [manager startRequestWithSuccess:^(SQApiResponse *response) {
        
        NSLog(@"天气信息：%@",response.responseObject);
        WeatherModel *model = [[WeatherModel alloc]init];
        
        block(model,nil);
        
    } failure:^(SQApiResponseError *error) {
        block(nil,@"获取天气失败");
    }];
```
