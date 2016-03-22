//
//  FeedBackViewController.m
//  TiJian
//
//  Created by lichaowei on 15/11/24.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "FeedBackViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

@interface FeedBackViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>
{
    UITextView *_textView;
    UILabel *_placeHolder;//默认字
    UIImageView *_photoView;
    UITextField *_chatTf;//联系方式
    BOOL _selectedImage;//是否选择了图片
}

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"意见反馈";
    
    
    CGFloat height = 120;
    if (iPhone4) {
        height = 100.f;
        
        self.rightString = @"提交";
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    }else
    {
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    }
    
    if (iPhone6) {
        height = 186.f;
    }
    
    if (iPhone6PLUS) {
        height = 200.f;
    }
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, height)];
    bgView.backgroundColor = [UIColor whiteColor];
    [bgView setBorderWidth:1.f borderColor:[UIColor colorWithHexString:@"e4e4e4"]];
    [self.view addSubview:bgView];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(10-5, 10 - 5, bgView.width - 10, bgView.height - 10 - 50 - 5)];
    _textView.delegate = self;
    _textView.font = [UIFont systemFontOfSize:13.f];
//    _textView.backgroundColor = [UIColor orangeColor];
    [bgView addSubview:_textView];
    
    _placeHolder = [[UILabel alloc]initWithFrame:CGRectMake(9, 13, _textView.width - 9 * 2, 14) font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"c7c7cd"] title:@"请输入您的意见或建议"];
    [bgView addSubview:_placeHolder];
    
    //反馈图
    _photoView = [[UIImageView alloc]initWithFrame:CGRectMake(10, bgView.height - 10 - 50, 50, 50)];
    _photoView.image = [UIImage imageNamed:@"feedback_tianjia"];
    _photoView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    [bgView addSubview:_photoView];
    [_photoView addTaget:self action:@selector(clickToSelectImage) tag:100];
    
    _chatTf = [[UITextField alloc]initWithFrame:CGRectMake(10, bgView.bottom + 6, bgView.width, 40)];
    [_chatTf setBorderWidth:1.f borderColor:[UIColor colorWithHexString:@"e4e4e4"]];
    _chatTf.placeholder = @"请输入的手机号/邮箱(选填)";
    _chatTf.backgroundColor = [UIColor whiteColor];
    _chatTf.font = [UIFont systemFontOfSize:13.f];
    _chatTf.delegate = self;
    _chatTf.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_chatTf];
    //textField 缩进
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 9, 40)];
    _chatTf.leftView = leftView;
    _chatTf.leftViewMode = UITextFieldViewModeAlways;
    _chatTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    if (!iPhone4) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(25, _chatTf.bottom + 30, DEVICE_WIDTH - 50, 40);
        btn.backgroundColor = DEFAULT_TEXTCOLOR;
        [btn addCornerRadius:3.f];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:@"提交" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(netWorkForList) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
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
    NSString *mobile = _chatTf.text;
    
    
    if (!_selectedImage) {
        
        if ([LTools isEmpty:content]) {
            
            [LTools showMBProgressWithText:@"多说两句吧" addToView:self.view];
            
            return;
        }else
        {
            if (content.length < 10 || content.length > 200) {
                
                [LTools showMBProgressWithText:@"请输入10~200个字符" addToView:self.view];
                
                return;
            }
        }
        
    }
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetString:[UserInfo getAuthkey] forKey:@"authcode"];
    [params safeSetString:content forKey:@"suggest"];
    [params safeSetString:mobile forKey:@"mobile"];

    NSString *api = ADD_SUGGEST;
    
    __weak typeof(self)weakSelf = self;
    //    __weak typeof(RefreshTableView *)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:^(id<AFMultipartFormData> formData) {
        
        if (_selectedImage) {
            
            UIImage *image = _photoView.image;
            
            if (image) {
                
                NSData *imageData = [image dataWithCompressMaxSize:300 * 1000 compression:0.5];

                DDLOG(@"---> 大小 %ld",(unsigned long)imageData.length);
                NSString *imageName = [NSString stringWithFormat:@"feedback.jpg"];
                
                NSString *picName = [NSString stringWithFormat:@"image"];
                
                [formData appendPartWithFileData:imageData name:picName fileName:imageName mimeType:@"image/jpg"];
            }
            
        }
    } completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [LTools showMBProgressWithText:@"感谢您的反馈" addToView:weakSelf.view];
        
        [weakSelf performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:1.f];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}
#pragma mark - 数据解析处理
#pragma mark - 事件处理

-(void)rightButtonTap:(UIButton *)sender
{
    [self netWorkForList];
}

- (void)hiddenKeyboard
{
    [_textView resignFirstResponder];
    [_chatTf resignFirstResponder];
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
    DDLOG(@"---");
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    DDLOG(@"---ccc");
    
    if (textView.text.length > 0) {
        _placeHolder.hidden = YES;
    }else
    {
        _placeHolder.hidden = NO;
    }

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 选取图片

- (void)clickToSelectImage
{
    [self hiddenKeyboard];
    
    if (_selectedImage) {
        
        UIActionSheet* alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"拍照",@"从相册选择",@"删除图片",nil];
        [alert showInView:self.view];
        
        return;
    }
    
    UIActionSheet* alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"拍照",@"从相册选择",nil];
    [alert showInView:self.view];
}

-(void)choseImageWithTypeCameraTypePhotoLibrary:(UIImagePickerControllerSourceType)type{
    
    if (type == UIImagePickerControllerSourceTypeCamera) { //相机
        if (![UIImagePickerController isSourceTypeAvailable:type]) {
            //不支持相机
            return;
        }
        
        //相机
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == kCLAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            //无权限
            NSString *title = @"此应用没有权限访问您的相机";
            NSString *errorMessage = @"您可以在\"隐私设置\"中启用访问。";
            
            //iOS8 之后可以打开系统设置界面
            if (IOS8_OR_LATER) {
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                                   message:errorMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                         otherButtonTitles:@"设置", nil];
                [alertView show];
            }else
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                                   message:errorMessage
                                                                  delegate:nil
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                [alertView show];
            }
            return;
        }
    }
    
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate =self;
    imagePicker.sourceType = type;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

#pragma mark UIACtionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex ==0){
        [self choseImageWithTypeCameraTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera];
    }else if(buttonIndex == 1){
        [self choseImageWithTypeCameraTypePhotoLibrary:UIImagePickerControllerSourceTypePhotoLibrary];
    }else
    {
        _photoView.image = [UIImage imageNamed:@"feedback_tianjia"];
        _selectedImage = NO;
    }
}

#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else if (buttonIndex == 1){
        
        if (IOS8_OR_LATER) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString]];
        }
    }
}


#pragma - mark UIPickerViewControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //最大300kb
    NSData *data = [image dataWithCompressMaxSize:300 * 1000 compression:0.5];
    
//    NSData *data = UIImageJPEGRepresentation(image, 1);
    if (image) {
        _selectedImage = YES;//选择了图片
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _photoView.image = [UIImage imageWithData:data];
    });
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
