//
//  WebviewController.m
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "WebviewController.h"
#import "UIWebView+AFNetworking.h"
#import "ArticleListController.h"
#import "EditUserInfoViewController.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "AddPeopleViewController.h"
#import "UMSocial.h"

@interface WebviewController ()<UIWebViewDelegate,UIAlertViewDelegate,NJKWebViewProgressDelegate,UMSocialUIDelegate>
{
//    UIView *_progressview;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    NSString *_targetFamilyUid;
    NSString *_targetUid;
    
    NSString *_shareUrl;
    NSString *_shareContent;
    NSString *_shareTitle;
}

@property(nonatomic,retain)UIWebView *webView;
@property(nonatomic,retain)ResultView *failView;//结果view

@end

@implementation WebviewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.moreInfo) {
        self.rightImage = [UIImage imageNamed:@"ios7_refresh4139"];
        self.rightImage2 = [UIImage imageNamed:@"share3"];
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeDouble];
    }else
    {
        self.rightImageName = @"ios7_refresh4139.png";
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    }
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
//    self.webView.delegate = self;
    self.webView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:_webView];
    self.webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag; // 当拖动时移除键盘
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
//    _progressview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 3.f)];
//    _progressview.backgroundColor = RGBCOLOR(0, 188, 22);
//    [self.view addSubview:_progressview];
    
    if (self.guaHao) {
        
        [self networkForForGuahaoType:self.type];//挂号
        
        self.leftImageName = @"back";
        self.leftString2 = @"关闭";
        self.rightImageName = @"ios7_refresh4139.png";
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeDouble WithRightButtonType:MyViewControllerRightbuttonTypeOther];
        
        //导航栏左侧
        
        
               NSString *title = @"";
        switch (self.type) {
            case 1:
                title = @"预约挂号";
                break;
            case 2:
                // title = @"转诊预约";
                title = @"精准预约";
                break;
            case 3:
                //title = @"健康顾问团";
//                title = @"在线问诊";
                title = @"家庭医生";
                break;
            case 4:
                // title = @"公立医院主治医生";
//                title = @"免费咨询";
                title = @"咨询台";
                break;
            case 5:
                title = @"公立医院权威专家"; 
                break;
            case 6:
                //title = @"我的问诊";
                title = @"挂号问诊";
                break;
            case 7:
                //title = @"我的预约";
                title = @"挂号预约";
                break;
            case 8:
                //title = @"我的转诊";
                title = @"挂号转诊";
                break;
            case 9:
                title = @"我的关注";
                break;
            case 10:
                title = @"家庭联系人";
                break;
            case 11:
                title = @"家庭病例";
                break;
            case 12:
                //title = @"我的申请";
                title = @"挂号申请";
                break;
            case 13:
                title = @"医生随访";
                break;
            case 14:
                title = @"购药订单";
                break;
            case 20:
                title = @"专家问诊";
                break;
            default:
                break;
        }

        self.myTitle = title;

    }else
    {
        [self netWorkForUrl:self.webUrl];
        self.myTitle = self.navigationTitle ? :  @"健康资讯";

    }
}
//- (void)test:(CGFloat)x
//{
//    if (x >= 1.0) {
//        
//        [UIView animateWithDuration:0.5 animations:^{
//            _progressview.width = DEVICE_WIDTH * x;
//        } completion:^(BOOL finished) {
//            if (finished) {
//                
//                [_progressview removeFromSuperview];
//            }
//        }];
//    }else
//    {
//        _progressview.width = DEVICE_WIDTH * x;
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 创建视图

- (void)addFailView
{
    [_webView addSubview:self.failView];
    _failView.center = CGPointMake(_webView.width/2.f, _webView.height * 2/5.f);
}

- (void)removeFailView
{
    [self.failView removeFromSuperview];
    _failView = nil;
}

-(ResultView *)failView
{
    NSString *content;
    
    if (!_failView) {
        ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                        title:nil
                                                      content:content];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 140, 36);
        [btn addCornerRadius:5.f];
        btn.backgroundColor = DEFAULT_TEXTCOLOR;
        [btn setTitle:@"重新加载" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:@selector(clickToRefresh) forControlEvents:UIControlEventTouchUpInside];
        [result setBottomView:btn];
        
        result.backgroundColor = [UIColor whiteColor];
        _failView = result;
    }
    
    return _failView;
}

#pragma - mark 事件处理

- (void)clickToRefresh
{
    [self removeFailView];
    [self networkForForGuahaoType:self.type];
}

-(void)rightButtonTap:(UIButton *)sender
{
//    if (self.moreInfo) {
//        ArticleListController *article = [[ArticleListController alloc]init];
//        [self.navigationController pushViewController:article animated:YES];
//    }else
//    {
        [_webView reload];
//    }
}

-(void)rightButtonTap2:(UIButton *)sender
{
    [[MiddleTools shareInstance]shareFromViewController:self withImageUrl:self.extensionParams[Share_imageUrl]  shareTitle:self.extensionParams[Share_title] shareContent:self.extensionParams[Share_content] linkUrl:self.webUrl];
}

/**
 *  编辑本人信息
 */
- (void)clickToEditUserInfoIsFull:(BOOL)isFull
{
    EditUserInfoViewController *edit = [[EditUserInfoViewController alloc]init];
    edit.isFullUserInfo = isFull;
    [self.navigationController pushViewController:edit animated:YES];
}

/**
 *  编辑家人信息
 */
- (void)editOtherPeople
{
    AddPeopleViewController *add = [[AddPeopleViewController alloc]init];
    add.actionStyle = ACTIONSTYLE_DetailByFamily_uid;
    add.family_uid = _targetFamilyUid;
    [add setUpdateParamsBlock:^(NSDictionary *params){
        
        NSLog(@"params %@",params);
        //        [weakTable showRefreshHeader:YES];
    }];
    
    [self.navigationController pushViewController:add animated:YES];
    
}


-(void)leftButtonTap:(UIButton *)sender
{
    if (_webView.canGoBack) {
        [_webView goBack];
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma - mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self leftButtonTap:nil];
    }
    
    if (buttonIndex == 1) {
        
        if (alertView.tag >= 100) {
            
            [self addFailView];
            
            if ([_targetFamilyUid integerValue] > 0) {
                
                [self editOtherPeople];
            }else
            {
                [self clickToEditUserInfoIsFull:YES];
            }
        }
    }
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    DDLOG(@"progress %f",progress);
}


#pragma mark - UIWebviewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"navigationType %ld",(long)navigationType);
    NSLog(@"request %@",request.URL.relativeString);
    
    NSString *relativeUrl = request.URL.relativeString;
    
    //单品链接
    if ([relativeUrl rangeOfString:@"product_id"].length > 0) {
        
        NSArray *arr = [relativeUrl componentsSeparatedByString:@":"];
        if (arr.count > 1) {
            NSString *productId = [arr lastObject];
            [MiddleTools pushToProductDetailWithProductId:productId viewController:self extendParams:nil];
            
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DDLOG(@"erro %@",webView.request);

    if (self.updateParamsBlock) {
        self.updateParamsBlock(@{@"result":[NSNumber numberWithBool:YES]});//加载完成
    }
    
//    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//
//    _shareTitle = title;
//    
//    NSString *imageUrl = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].getAttribute('src')"];
//    
//    NSLog(@"image %@ %@",title,imageUrl);
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    DDLOG(@"erro %@",error.userInfo);
    if (error) {
        
        NSString *failUrl = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
        
        if (failUrl && [failUrl isEqualToString:self.webUrl]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:Alert_ServerErroInfo delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma - mark 网络请求

- (void)netWorkForUrl:(NSString *)webUrl
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:webUrl]];
    [self.webView loadRequest:request];
}

- (void)networkForForGuahaoType:(int)type
{
    //专家问诊
    if (type == 20) {
        
        NSString *authcode = [UserInfo getAuthkey];
        if (authcode == nil) {
            return;
        }
        if ([LTools isEmpty:self.detail_url]) {
            DDLOG(@"医生信息不合法");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"未找到您访问的专家" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        NSDictionary *params = @{@"authcode":authcode,
                                 @"detail_url":self.detail_url};
        NSString *api = Guahao_doctorDetail;
        __weak typeof(self)weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
            NSLog(@"success result %@",result);
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            [weakSelf parseGuaHaoResult:result];
            
        } failBlock:^(NSDictionary *result) {
            
            NSLog(@"fail result %@",result);
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            [weakSelf parseGuaHaoResult:result];

        }];
        
        return;
    }
    
//authcode 必传
//target 用户动作标号 必传  例：预约挂号传递1
    NSString *authcode = [UserInfo getAuthkey];
    if (authcode == nil) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetString:authcode forKey:@"authcode"];
    [params safeSetString:NSStringFromInt(type) forKey:@"target"];
    [params safeSetString:self.familyuid forKey:@"family_uid"];

    NSString *api = Guahao_Appoint;
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakSelf parseGuaHaoResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakSelf parseGuaHaoResult:result];

    }];
}


- (void)parseGuaHaoResult:(NSDictionary *)result
{
    int errcode = [result[@"errorcode"]intValue];
    _targetFamilyUid = result[@"family_uid"];
    _targetUid = result[@"uid"];
    NSString *msg = result[@"msg"];
    switch (errcode) {
        case 0://成功
        {
            NSString *weburl = @"";
            //医生详情
            if (_type == 20) {
                weburl = result[@"doctor_url"];
            }else
            {
                weburl = result[@"target_url"];
            }
            self.webUrl = weburl;
            [self netWorkForUrl:weburl];
        }
            break;
        case 1000://target不能为空
        case 1001://target不在指定范围内  1~14
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 1002://用户信息不存在
        case 1003://用户账号异常(已删除等原因)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 1004://用户真实姓名,手机号,身份证号信息缺失(用户资料不全，因为挂号网必须要这些信息)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"去完善", nil];
            alert.tag = 100;
            [alert show];
        }
            break;
        case 1005://挂号网返回来的信息，如身份证号格式错误，挂号网对身份证验证比较严格，网上有严格验证身份证的代码 http://www.cnblogs.com/bossikill/p/3679926.html,重复提交等
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"去修改", nil];
            alert.tag = 100;
            [alert show];
            
//            返回响应码：1030, '转诊预约最大数量只能是3次'
        }
            break;
        case 1030://'转诊预约最大数量只能是3次'
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    //        如果成功，target_url: 表示挂号网的跳转地址
    //        返回信息
    //        0      成功
    //        1000   target不能为空
    //        1001   target不在指定范围内  1~14
    //        1002   用户信息不存在
    //        1003   用户账号异常(已删除等原因)
    //        1004   用户真实姓名,手机号,身份证号信息缺失(用户资料不全，因为挂号网必须要这些信息)
    //        1005   挂号网返回来的信息，
    //        如身份证号格式错误，挂号网对身份证验证比较严格，网上有严格验证身份证的代码 http://www.cnblogs.com/bossikill/p/3679926.html
    //        重复提交等
    

}

@end
