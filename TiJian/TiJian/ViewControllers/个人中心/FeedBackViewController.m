//
//  FeedBackViewController.m
//  TiJian
//
//  Created by lichaowei on 15/11/24.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "FeedBackViewController.h"

@interface FeedBackViewController ()<UITextViewDelegate>
{
    UITextView *_textView;
}

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"意见反馈";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, 100)];
    _textView.delegate = self;
    [_textView setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
    [_textView addCornerRadius:3.f];
//    _textView.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_textView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(25, _textView.bottom + 20, DEVICE_WIDTH - 50, 40);
    btn.backgroundColor = DEFAULT_TEXTCOLOR;
    [btn addCornerRadius:3.f];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(netWorkForList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建
#pragma mark - 网络请求
- (void)netWorkForList
{
    [self hiddenKeyboard];
    
    NSString *content = _textView.text;
    
    if (content.length < 10 || content.length > 200) {
        
        [LTools showMBProgressWithText:@"请输入10~200个字符" addToView:self.view];
        
        return;
    }
    
    NSDictionary *params = @{@"authcode":[LTools objectForKey:USER_AUTHOD],
                             @"suggest":content};;
    NSString *api = ADD_SUGGEST;
    
    __weak typeof(self)weakSelf = self;
    //    __weak typeof(RefreshTableView *)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:weakSelf.view];
        
        [weakSelf performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}
#pragma mark - 数据解析处理
#pragma mark - 事件处理

- (void)hiddenKeyboard
{
    [_textView resignFirstResponder];
}
#pragma mark - 代理

#pragma - mark UITextViewDelegate <NSObject, UIScrollViewDelegate>

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    
}


@end
