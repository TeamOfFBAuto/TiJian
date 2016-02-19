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
#import "GproductDetailViewController.h"//单品详情

@interface WebviewController ()<UIWebViewDelegate,UIAlertViewDelegate>
{
    UIView *_progressview;
}

@property(nonatomic,retain)UIWebView *webView;

@end

@implementation WebviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = self.navigationTitle ? :  @"健康资讯";
    
//    [self registerForKeyboardNotifications]; //键盘通知
    
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
    self.webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag; // 当拖动时移除键盘
    
    _progressview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 3.f)];
    _progressview.backgroundColor = RGBCOLOR(0, 188, 22);
    [self.view addSubview:_progressview];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]];
    [self.webView loadRequest:request progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"bytesWritten:%ld totalBytesWritten:%ld totalBytesExpectedToWrite:%lld",(unsigned long)bytesWritten,(unsigned long)totalBytesWritten,totalBytesExpectedToWrite);
        
        [self test:(totalBytesWritten/totalBytesExpectedToWrite)];
        
    } success:^NSString *(NSHTTPURLResponse *response, NSString *HTML) {
        
        if (HTML.length == 0) {
            return Alert_ServerErroInfo;
        }
        return HTML;
        
    } failure:^(NSError *error) {
        NSLog(@"erro %@",error);
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:Alert_ServerErroInfo delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self leftButtonTap:nil];
    }
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
    NSLog(@"navigationType %ld",(long)navigationType);
    NSLog(@"request %@",request.URL.relativeString);
    
    NSString *relativeUrl = request.URL.relativeString;
    
    //单品链接
    if ([relativeUrl rangeOfString:@"product_id"].length > 0) {
        
        NSArray *arr = [relativeUrl componentsSeparatedByString:@":"];
        if (arr.count > 1) {
            NSString *productId = [arr lastObject];
            GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
            cc.productId = productId;
            [self.navigationController pushViewController:cc animated:YES];
            
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.updateParamsBlock) {
        self.updateParamsBlock(@{@"result":[NSNumber numberWithBool:YES]});//加载完成
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    
}

#pragma mark - 键盘处理

// Call this method somewhere in your view controller setup code.

- (void)registerForKeyboardNotifications

{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
    
}



// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    _webView.scrollView.contentInset = contentInsets;
    
    _webView.scrollView.scrollIndicatorInsets = contentInsets;
    
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    
    // Your app might not need or want this behavior.
    
    CGRect aRect = self.view.frame;
    
    aRect.size.height -= kbSize.height;
    
//    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
//        
//        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
//        
//    }
    
}

// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    _webView.scrollView.contentInset = contentInsets;
    _webView.scrollView.scrollIndicatorInsets = contentInsets;
    
}

@end
