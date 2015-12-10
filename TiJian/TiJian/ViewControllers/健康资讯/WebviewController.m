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

@interface WebviewController ()<UIWebViewDelegate>
{
    UIView *_progressview;
}

@property(nonatomic,retain)UIWebView *webView;

@end

@implementation WebviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"健康资讯";
    
    if (self.moreInfo) {
        self.rightImageName = @"article_more";
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    }else
    {
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    }
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    self.webView.delegate = self;
    self.webView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:_webView];
    
    _progressview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 3.f)];
    _progressview.backgroundColor = RGBCOLOR(0, 188, 22);
    [self.view addSubview:_progressview];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]];
    [self.webView loadRequest:request progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"bytesWritten:%ld totalBytesWritten:%ld totalBytesExpectedToWrite:%lld",bytesWritten,(unsigned long)totalBytesWritten,totalBytesExpectedToWrite);
        
        [self test:(totalBytesWritten/totalBytesExpectedToWrite)];
        
    } success:^NSString *(NSHTTPURLResponse *response, NSString *HTML) {
        
        return HTML;
        
    } failure:^(NSError *error) {
        NSLog(@"erro %@",error);
        [LTools alertText:@"页面访问出现错误" viewController:self];
        [self leftButtonTap:nil];
    }];
    
}

- (void)test:(CGFloat)x
{
    if (x >= 1.0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            _progressview.width = DEVICE_WIDTH * x;
        } completion:^(BOOL finished) {
            if (finished) {
                
                [_progressview removeFromSuperview];
            }
        }];
    }else
    {
        _progressview.width = DEVICE_WIDTH * x;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 事件处理

-(void)rightButtonTap:(UIButton *)sender
{
    ArticleListController *article = [[ArticleListController alloc]init];
    [self.navigationController pushViewController:article animated:YES];
}

#pragma mark - UIWebviewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    
}

@end
