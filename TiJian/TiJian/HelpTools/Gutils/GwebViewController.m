//
//  GwebViewController.m
//  fblifebbs
//
//  Created by gaomeng on 14/10/17.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GwebViewController.h"

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
//代码屏幕适配（设计图为320*568）
#define GscreenRatio_320 DEVICE_WIDTH/320.00
//代码屏幕适配 (设计图为320*568)
#define GscreenRatio_568 DEVICE_HEIGHT/568.00

@interface GwebViewController ()

@end

@implementation GwebViewController



-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)dealloc
{
    NSLog(@"--%s--",__FUNCTION__);
    
    [awebview stopLoading];
    awebview.delegate = nil;
    awebview = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    NSURL *url =[NSURL URLWithString:self.urlstring];
    
    if (self.targetTitle.length > 0) {
        
        self.myTitle = self.targetTitle;
    }else
    {
        self.myTitle = @"详情";

    }
    
    if (self.ismianzeshengming) {
        self.rightString = @"同意";
    }
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    awebview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-HMFitIphoneX_navcBarHeight-40)];
    awebview.delegate=self;
    [awebview loadRequest:request];
    awebview.scalesPageToFit = YES;
    [self.view addSubview:awebview];
    awebview.dataDetectorTypes = UIDataDetectorTypeNone;
    
    UIView *toolview=[[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT-65-40, DEVICE_WIDTH, 40)];
    toolview.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ios7_webviewbar.png"]];
    [self.view addSubview:toolview];
    
    
    NSArray *array_imgname=[NSArray arrayWithObjects:@"ios7_goback4032.png",@"ios7_goahead4032.png",@"ios7_refresh4139.png", nil];
    for (int i=0; i<3; i++) {
        UIImage *img=[UIImage imageNamed:[array_imgname objectAtIndex:i]];
        
        UIButton *tool_Button=[[UIButton alloc]initWithFrame:CGRectMake(5+i*70, 5, img.size.width, img.size.height)];
        tool_Button.center=CGPointMake(22+i*i*68.5*GscreenRatio_320, 20);
        
        tool_Button.tag=99+i;
        [tool_Button setBackgroundImage:[UIImage imageNamed:[array_imgname objectAtIndex:i]] forState:UIControlStateNormal];
        
        [tool_Button addTarget:self action:@selector(dobuttontool:) forControlEvents:UIControlEventTouchUpInside];
        
        [toolview addSubview:tool_Button];
        
        if (self.ismianzeshengming) {
            if (i == 0 || i==1) {
                tool_Button.hidden = YES;
            }
        }
        
    }
    
    
}


-(void)dobuttontool:(UIButton *)sender{
    switch (sender.tag) {
        case 99:
            [awebview goBack];
            break;
        case 100:
            [awebview goForward];
            break;
        case 101:
        {
            NSURL *url =[NSURL URLWithString:self.urlstring];
            
            NSURLRequest *request =[NSURLRequest requestWithURL:url];
            
            [awebview loadRequest:request];
            
            [awebview reload];
        }
            break;
            
            
        default:
            break;
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [MBProgressHUD showHUDAddedTo:webView animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    button_comment.userInteractionEnabled=YES;
    
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"erro %@",error);
    
    NSLog(@"data 为空 connectionError %@",error);
    
    [MBProgressHUD hideAllHUDsForView:webView animated:YES];
    
    NSString *errInfo = @"网络有问题,请检查网络";
//    switch (error.code) {
//        case NSURLErrorNotConnectedToInternet:
//            
//            errInfo = @"无网络连接";
//            break;
//        case NSURLErrorTimedOut:
//            
//            errInfo = @"网络连接超时";
//            break;
//        default:
//            break;
//    }
    
//    [LTools showMBProgressWithText:errInfo addToView:webView];
    
    if (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorTimedOut) {
        
        [self addReloadButtonWithTarget:self action:@selector(reloadData:) info:errInfo];

    }

}

- (void)reloadData:(UIButton *)sender
{
    NSURL *url =[NSURL URLWithString:self.urlstring];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    [awebview loadRequest:request];
    
    [awebview reload];
    
    [sender removeFromSuperview];
    sender = nil;
}


-(void)rightButtonTap:(UIButton *)sender
{
    if (self.ismianzeshengming) {
        //同意
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

-(void)leftButtonTap:(UIButton *)sender
{
    if (self.ismianzeshengming || self.isSaoyisao) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
