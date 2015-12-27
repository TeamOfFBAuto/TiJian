//
//  ReportDetailController.m
//  TiJian
//
//  Created by lichaowei on 15/12/5.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "ReportDetailController.h"
#import "UIWebView+AFNetworking.h"
#import "MoreReportViewController.h"
#import "FBPhotoBrowserController.h"
#import "LPhotoBrowser.h"

@interface ReportDetailController ()<UIWebViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    UIScrollView *_scrollView;
    UserInfo *_userInfo;
    NSArray *_imagesArray;
}

@property(nonatomic,retain)UIWebView *webView;

@end

@implementation ReportDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"报告解读";
    self.rightImage = [UIImage imageNamed:@"personal_jiaren_shanchu"];
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    [self netWorkForDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

- (void)setViewWithModel:(UserInfo *)report
{
    _userInfo = report;
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _scrollView.contentSize = CGSizeMake(DEVICE_WIDTH, _scrollView.height + 50);
    _scrollView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:_scrollView];
    
    CGFloat top = 0.f;
    
    for (int i = 0; i < 2; i ++) {
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5 + (50 + 5) * i, DEVICE_WIDTH, 50)];
        view.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:view];
        
        NSString *title = i == 0 ? @"体检人信息" : @"体检时间";
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 150, 50) title:title font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB];
        [view addSubview:label];
        
        
        CGFloat width = DEVICE_WIDTH - label.right - 20 - 10;
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 20, 0, width, 50) title:nil font:14 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE];
        [view addSubview:contentLabel];
        contentLabel.tag = 100 + i;
        
        if (i == 0) {
            
            contentLabel.text = [NSString stringWithFormat:@"%@  %@",report.appellation,report.family_user_name];
        }else
        {
            contentLabel.text = report.checkup_time;
        }
        
        top = view.bottom;
    }
    
    NSArray *img = report.img;
    
    CGFloat width = (DEVICE_WIDTH - 30) / 3.f ;
    CGFloat height = width * 1.3;
    CGFloat left = (DEVICE_WIDTH - width * 3)/3.f;
    
    NSInteger count = img.count;
    
    NSMutableArray *temp = [NSMutableArray array];
    
    for (int i = 0; i < (count > 6 ? 6 : count); i ++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left + (width + left/2.f) * (i % 3), 110 + 10 + (height + left/2.f) * (i / 3), width, height)];
        NSString *url = img[i][@"img"];
        [imageView l_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
        [_scrollView addSubview:imageView];
        
        [imageView addTapGestureTaget:self action:@selector(tapToBrowser:) imageViewTag:200 + i];
        
        [imageView setBorderWidth:0.5 borderColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        
        [temp addObject:url];
        
        top = imageView.bottom;
        
        if (count > 6 && i == 5) {
            
            imageView.userInteractionEnabled = YES;
            UILabel *label = [[UILabel alloc]initWithFrame:imageView.bounds title:@"更多" font:15 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
            [imageView addSubview:label];
            label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            [label addTaget:self action:@selector(clickToMore) tag:0];
        }
    }
    
    _imagesArray = [NSArray arrayWithArray:temp];
    
    //未解读
    if ([report.is_read intValue] == 0) {
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, top + 10, DEVICE_WIDTH, 16) title:@"专家正在解读您的报告,请耐心等待....." font:15 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_SUB];
        [_scrollView addSubview:label];
    }else
    {
        self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, top + 10, DEVICE_WIDTH, _scrollView.height - top - 10)];
        _webView.delegate = self;
        [_scrollView addSubview:_webView];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        [_webView setOpaque:NO];
        _webView.scrollView.scrollEnabled = NO;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:report.url]];
        [_webView loadRequest:request progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            NSLog(@"");
        } success:^NSString *(NSHTTPURLResponse *response, NSString *HTML) {
            return HTML;
        } failure:^(NSError *error) {
           
            
        }];

    }
}

#pragma mark - 网络请求

- (void)netWorkForDetail
{
    if (!self.reportId) {
        [LTools showMBProgressWithText:@"报告不存在" addToView:self.view];
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        return;
    }
    NSDictionary *params = @{@"authcode":[UserInfo getAuthkey],
                             @"report_id":self.reportId};;
    NSString *api = REPORT_DETAIL;
    
    __weak typeof(self)weakSelf = self;
    //    __weak typeof(RefreshTableView *)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        UserInfo *report = [[UserInfo alloc]initWithDictionary:result[@"info"]];
        
        [weakSelf setViewWithModel:report];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

- (void)netWorkForDelReport
{
    if (!self.reportId) {
        [LTools showMBProgressWithText:@"报告不存在" addToView:self.view];
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        return;
    }
    NSDictionary *params = @{@"authcode":[UserInfo getAuthkey],
                             @"report_id":self.reportId};;
    NSString *api = REPORT_DEL;
    
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if ([result[RESULT_CODE]intValue] == 0) {
            
            [LTools showMBProgressWithText:@"删除报告成功" addToView:weakSelf.view];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_REPORT_DEL_SUCCESS object:nil];
        [weakSelf performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:1.f];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

#pragma mark - 事件处理

-(void)rightButtonTap:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"删除后不能恢复,确定要删除吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

/**
 *  手势
 *
 *  @param sender 手势
 */
- (void)tapToBrowser:(UITapGestureRecognizer *)sender
{
    int index = (int)sender.view.tag - 200;
//    
//    FBPhotoBrowserController *browser = [[FBPhotoBrowserController alloc]init];
//    browser.showIndex = index;
//    browser.imagesArray = _imagesArray;
//    [self.navigationController pushViewController:browser animated:YES];
    
//    _scrollView
    
    NSArray *img = _userInfo.img;
    
    int count = (int)[img count];
    
    NSInteger initPage = index;
    
     @WeakObj(_scrollView);
    [LPhotoBrowser showWithViewController:self initIndex:initPage photoModelBlock:^NSArray *{
        
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:7];
        
        for (int i = 0; i < count; i ++) {
            
            UIImageView *imageView = [Weak_scrollView viewWithTag:200 + i];
            LPhotoModel *photo = [[LPhotoModel alloc]init];
            photo.imageUrl = img[i][@"img"];
            imageView = imageView;
            photo.thumbImage = imageView.image;
            photo.sourceImageView = imageView;
            
            [temp addObject:photo];
        }
        
        return temp;
    }];
}

- (void)clickToMore
{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *aDic in _userInfo.img) {
        
        NSString *url = aDic[@"img"];
        if (url) {
            [arr addObject:url];
        }
    }
    MoreReportViewController *more = [[MoreReportViewController alloc]init];
    more.imageUrlArray = [NSArray arrayWithArray:arr];
    [self.navigationController pushViewController:more animated:YES];
}

#pragma mark - 代理

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.height = webView.scrollView.contentSize.height;
    CGFloat height = webView.bottom;
    height = height > DEVICE_HEIGHT - 64 ? height : DEVICE_HEIGHT - 64;
    _scrollView.contentSize = CGSizeMake(DEVICE_WIDTH, height);
    
     [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.background='#F5F5F5'"];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self netWorkForDelReport];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self netWorkForDelReport];
    }
}

@end
