 //
//  YJYRequstManager.m
//  YiYiProject
//
//  Created by lichaowei on 15/6/16.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "YJYRequstManager.h"

@implementation YJYRequstManager
{
    AFHTTPRequestOperationManager *_requestManager;
    NSMutableDictionary *_requstRecordDictionary;//记录请求字典
}

+ (id)shareInstance
{
    static dispatch_once_t once_t;
    static YJYRequstManager *manager = nil;
    dispatch_once(&once_t, ^{
        
        manager = [[YJYRequstManager alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _requestManager = [AFHTTPRequestOperationManager manager];
        _requestManager.operationQueue.maxConcurrentOperationCount = 5;
        _requstRecordDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

/**
 *  网络请求
 *
 *  @param method            YJYRequstMethod get\post
 *  @param paramsDic         参数字典
 *  @param constructingBlock 上传图片时需要在此处理
 *  @param completionBlock
 *  @param failBlock
 *
 *  @return AFHTTPRequestOperation
 */
- (AFHTTPRequestOperation *)requestWithMethod:(YJYRequstMethod)method
                      api:(NSString *)apiString
                   parameters:(NSDictionary *)paramsDic
    constructingBodyBlock:(AFConstructingBlock)constructingBlock
                   completion:(AFResultBlock)completionBlock
                    failBlock:(AFResultBlock)failBlock
{
    //判断网络是否可用
    if (![LTools NetworkReachable]) {
        
        NSString *erroInfo = @"网络不可用,请检查网络";
        NSDictionary *result = @{Erro_Info: erroInfo,
                                 Erro_Code:[NSString stringWithFormat:@"%d",Erro_NetworkUnReachable]};
        failBlock(result);
        [self showErroInfo:erroInfo];

        return nil;
    }
    
    //显示菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *serverUrl = SERVER_URL;
    
    if (method == YJYRequstMethodGet_goHealth ||
        method == YJYRequstMethodPost_goHealth)
    {
        serverUrl = GoHealthServerUrl;
        serverUrl = @"";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"application/json; charset=utf-8", nil];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 15.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
//    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *requestOpertation;
    
    __weak typeof(self)weakSelf = self;
    
    //自定义请求
    if (method == YJYRequstMethodCustom) {
        
        NSURLRequest *request = paramsDic[CUSTOM_REQUEST];
        
        if (request && [request isKindOfClass:[NSURLRequest class]]) {
            
            requestOpertation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
            
            [requestOpertation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [weakSelf successOperation:operation completion:completionBlock failBlock:failBlock];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [weakSelf failureOperation:operation error:error failtBlock:failBlock];
            }];
            
            [manager.operationQueue addOperation:requestOpertation];
        }
        
    }else
    {
        serverUrl = [NSString stringWithFormat:@"%@%@",serverUrl,apiString];
        
        if (method == YJYRequstMethodGet ||
            method == YJYRequstMethodGet_goHealth)
        {
            NSArray *allkeys = [paramsDic allKeys];
            NSMutableString *url = [NSMutableString stringWithString:serverUrl];
    
            for (NSString *key in allkeys) {
                NSString *param = [NSString stringWithFormat:@"&%@=%@",key,paramsDic[key]];
                [url appendString:param];
            }

            DDLOG(@"Method:get url:%@",url);
            
        }else if (method == YJYRequstMethodPost ||
                  method == YJYRequstMethodPost_goHealth)
        {
            DDLOG(@"Method:post url:%@",serverUrl);
            DDLOG(@"post params:%@",paramsDic);
        }
        
        if (method == YJYRequstMethodGet ||
            method == YJYRequstMethodGet_goHealth) {
            
            requestOpertation = [manager GET:serverUrl parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [weakSelf successOperation:operation completion:completionBlock failBlock:failBlock];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [weakSelf failureOperation:operation error:error failtBlock:failBlock];
            }];
            
        }else if (method == YJYRequstMethodPost){
            
            if (constructingBlock) {
                
                
                requestOpertation = [manager POST:serverUrl parameters:paramsDic
                                     
                          constructingBodyWithBlock:constructingBlock
                                     
                                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                
                                                [weakSelf successOperation:operation completion:completionBlock failBlock:failBlock];
                                                
                                            }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                
                                                [weakSelf failureOperation:operation error:error failtBlock:failBlock];
                                                
                                            }];
            }else
            {
                requestOpertation = [manager POST:serverUrl parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [weakSelf successOperation:operation completion:completionBlock failBlock:failBlock];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [weakSelf failureOperation:operation error:error failtBlock:failBlock];
                    
                }];
 
            }
            
        }
        else if (method == YJYRequstMethodPost_goHealth)
        {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://101.200.188.142/api/v1/user/thirdLogin"]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=utf-8"forHTTPHeaderField:@"Content-Type"];
            NSString *json = (NSString *)paramsDic;
            NSData *JSONData = [json dataUsingEncoding:NSUTF8StringEncoding];
            int length = (int)json.length;
            [request setValue:NSStringFromInt(length) forHTTPHeaderField:@"Content-length"];
            [request setHTTPBody:JSONData];
            
           AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                [weakSelf successOperation:operation completion:completionBlock failBlock:failBlock];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [weakSelf failureOperation:operation error:error failtBlock:failBlock];
            }];
            
            [manager.operationQueue addOperation:operation];
        }

    }
    
    // operation userInfo处理
    NSDictionary *tempUserInfo = @{@"method":NSStringFromInt(method)};
    NSDictionary *userInfo = requestOpertation.userInfo;
    NSMutableDictionary *newUserInfo;
    if (userInfo) {
        newUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    }else
    {
        newUserInfo = [NSMutableDictionary dictionary];
    }
    requestOpertation.userInfo = [newUserInfo addObject:tempUserInfo];;
    
    [self addOperation:requestOpertation];
    
    return requestOpertation;
}

/**
 *  处理请求success结果
 *
 *  @param operation       AFHTTPRequestOperation
 *  @param completionBlock 成功Block
 *  @param failBlock       失败Block
 */
- (void)successOperation:(AFHTTPRequestOperation *)operation
              completion:(AFResultBlock)completionBlock
               failBlock:(AFResultBlock)failBlock
{
    //隐藏菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *key = [self requestHashKey:operation];
    _requstRecordDictionary[key] = operation;
    
    NSData *data = operation.responseData;
    if (data.length == 0){
        
        NSDictionary *failDic = @{Erro_Info:Alert_ServerErroInfo,
                                  Erro_Code:NSStringFromInt(Erro_ServerException)};
        failBlock(failDic);
        DDLOG(@"%@:%@",Alert_ServerErroInfo,operation.responseString);
        return;
    }
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    @WeakObj(self);
    if ([result isKindOfClass:[NSDictionary class]])
    {
        YJYRequstMethod method = [operation.userInfo[@"method"] intValue];
        int erroCode = 0;//错误code
        int successCode = 0;//正确code
        
        if (method == YJYRequstMethodGet_goHealth ||
            method == YJYRequstMethodPost_goHealth) {
            erroCode = [[result objectForKey:@"code"]intValue];
            successCode = 200;
        }else
        {
            erroCode = [[result objectForKey:@"errorcode"]intValue];
            successCode = 0;
        }
        
        NSString *erroInfo = [result objectForKey:@"msg"];
        
        if (erroCode == successCode) { //无错误,请求数据成功
            
            completionBlock(result);

        }else //代表请求结果有错误,或者特殊操作结果
        {
            //大于2000的可以正常提示错误,小于2000的为内部错误 参数错误等
            if (erroCode >= EnableErroLogCode) {
                
                failBlock(result);
                [Weakself showErroInfo:erroInfo];
                
            }else
            {
                DDLOG(@"errcode:%d erroInfo:%@",erroCode,erroInfo);
                
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:result];
                if (!erroInfo) {
                    [params safeSetString:Alert_ServerErroInfo_Inner forKey:erroInfo];
                }
                failBlock(result);
            }
        }
    }
    
    [self removeOperation:operation];
    completionBlock = nil;
    failBlock = nil;
}

/**
 *  处理请求failure结果
 *
 *  @param operation AFHTTPRequestOperation
 *  @param error     错误NSError
 *  @param failBlock 失败Block
 */
- (void)failureOperation:(AFHTTPRequestOperation *)operation
                    error:(NSError *)error
              failtBlock:(AFResultBlock)failBlock
{
    //隐藏菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    DDLOG(@"failure:%@ Url:%@",operation.responseString,operation.request.URL);
    NSString *errInfo = @"网络有问题,请检查网络";
    switch (error.code) {
        case NSURLErrorNotConnectedToInternet:
            
            errInfo = @"无网络连接";
            break;
        case NSURLErrorTimedOut:
            
            errInfo = @"网络连接超时";
            break;
        case 3840:
            errInfo = Alert_ServerErroInfo;
            break;
        default:
            break;
    }
    
    NSDictionary *failDic = @{Erro_Info: errInfo,
                              Erro_Code:NSStringFromInt((int)error.code)};
    failBlock(failDic);
    
    [self removeOperation:operation];
    [self showErroInfo:errInfo];
    
    failBlock = nil;

}

- (void)removeBlock
{
    
}

/**
 *  显示错误提示
 *
 *  @param errInfo
 */
- (void)showErroInfo:(NSString *)errInfo
{
    UIView *view = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [LTools showMBProgressWithText:errInfo addToView:view];
}

/**
 *  获取operation的hash值
 *
 *  @param operation LTools 对象
 *
 *  @return 返回一个字符串作为可以
 */
- (NSString *)requestHashKey:(id)operation {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

/**
 *  记录网络请求
 *
 *  @param operation
 */
- (void)addOperationOther:(id)operation {
    if (operation != nil) {
        NSString *key = [self requestHashKey:operation];
        @synchronized(self) {
            _requstRecordDictionary[key] = operation;
        }
    }
}

/**
 *  移除网络请求
 *
 *  @param operation
 */
- (void)removeOperationOther:(id)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        AFHTTPRequestOperation *operation = _requstRecordDictionary[key];
        [operation cancel];
        [_requstRecordDictionary removeObjectForKey:key];
    }
}


/**
 *  记录网络请求
 *
 *  @param operation
 */
- (void)addOperation:(AFHTTPRequestOperation *)operation {
    if (operation != nil) {
        NSString *key = [self requestHashKey:operation];
        @synchronized(self) {
            _requstRecordDictionary[key] = operation;
        }
    }
}

/**
 *  移除网络请求
 *
 *  @param operation
 */
- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        
        AFHTTPRequestOperation *operation = _requstRecordDictionary[key];
        [operation cancel];
        [_requstRecordDictionary removeObjectForKey:key];
    }
}

@end
