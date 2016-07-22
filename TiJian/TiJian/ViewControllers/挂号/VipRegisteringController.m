//
//  VipRegisteringController.m
//  TiJian
//
//  Created by lichaowei on 16/7/20.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "VipRegisteringController.h"
#import "PeopleManageController.h"
#import "JKImagePickerController.h"
#import "LTextView.h"

@interface VipRegisteringController ()<UITextFieldDelegate,JKImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSString *_familyUid;//就诊人familyUid
    UILabel *_nameLabel;//就诊人name
    LTextView *_sickDescTextView;//病情描述
}

@property(nonatomic,retain)UITextField *searchTF;
@property(nonatomic,retain)UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *assetsArray;


@end

@implementation VipRegisteringController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self prepareViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

/**
 *  转诊预约参数处理
 *
 *  @return
 */
- (NSDictionary *)referralParams
{
    NSString *familyUid = _familyUid;
    NSString *desc = _searchTF.text;//病情描述
    NSString *proviceId = @"";
    NSString *cityId = @"";
    NSString *hospital = @"";//选择医院
    NSString *alternative_hospital = @"";//备选医院
    NSString *dept = @"";//科室
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"authcode"];
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"family_uid"];//家人uid 选填 如果是家人就填 自己就不写这个参数或为0
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"desc"];
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"province_id"];
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"city_id"];
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"hospital"];
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"alternative_hospital"];
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"dept"];
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"appoint_date"];
    
    return params;
}

/**
 *  获取上传图片 UIImage
 *
 *  @return
 */
- (NSArray *)uploadImages
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:1];
    
    for (int i = 0;i < self.assetsArray.count; i++) {
        
        JKAssets* jkAsset = self.assetsArray[i];
        
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:jkAsset.assetPropertyURL resultBlock:^(ALAsset *asset) {
            
            if (asset)
            {
                UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                
                [temp addObject:image];
            }
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    
    if (self.assetsArray.count == 0)
    {
        
    }

    
    return temp;
}

#pragma mark - 获取所选图片

/**
 *  转诊预约新版
 */
- (void)netWorkForReferral
{
    NSString *api = Guahao_referral_data;
    NSDictionary *params = [self referralParams];
    
    __weak typeof(self)weakSelf = self;
    //    __weak typeof(RefreshTableView *)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:^(id<AFMultipartFormData> formData) {
        
        NSArray *images = [weakSelf uploadImages];
        
        int count = (int)images.count;
        
        for (int i = 0; i < count; i ++)
        {
            UIImage *aImage = images[i];
            
            if (aImage) {
                
                NSData *data = [aImage dataWithCompressMaxSize:200 * 1000 compression:0.5];//最大200kb
                
                DDLOG(@"---> 大小 %ld",(unsigned long)data.length);
                
                NSString *imageName = [NSString stringWithFormat:@"referralimage%d.jpg",i];
                
                NSString *picName = [NSString stringWithFormat:@"images%d",i];
                
                [formData appendPartWithFileData:data name:picName fileName:imageName mimeType:@"image/jpg"];
            }
        }
        
    } completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

#pragma mark - 创建视图

- (void)prepareViews
{
    if (!self.userInfo) {
        [LTools showMBProgressWithText:@"需要合法用户信息" addToView:self.view];
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        return;
    }
    
    self.navigationItem.titleView = self.searchTF;
    
    CGFloat width = DEVICE_WIDTH - 12 * 2;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(12, 12, width , 432)];
    view.backgroundColor = [UIColor whiteColor];
    [view addCornerRadius:5.f];
    [self.scrollView addSubview:view];
    //就诊人
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, 55, 45) font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"就 诊 人 :"];
    [view addSubview:titleLabel];
    
    NSString *name = self.userInfo.family_user_name;
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.right + 12, 0, width - titleLabel.right - 12 - 50, 45) font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:name];
    [view addSubview:contentLabel];
    _nameLabel = contentLabel;
    [contentLabel addTaget:self action:@selector(clickToSelectUserInfo:) tag:0];
    
    //箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(width - 35, 0, 35, 45)];
    arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
    arrow.contentMode = UIViewContentModeCenter;
    [view addSubview:arrow];
    
    //分割
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, titleLabel.bottom, width, 9)];
    line.backgroundColor = self.scrollView.backgroundColor;
    [view addSubview:line];
    
    //病情描述
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, line.bottom + 17, 55, 30) font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"病情描述:"];
    [view addSubview:titleLabel];
    
    CGFloat t_width = width - titleLabel.right - 12 - 12;
    
    LTextView *textView = [[LTextView alloc]initWithFrame:CGRectMake(titleLabel.right + 12, titleLabel.top, t_width, 70.f)];
    textView.backgroundColor = [UIColor colorWithHexString:@"f6f9fb"];
    [view addSubview:textView];
    [textView addCornerRadius:3.f];
    [textView setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"dfe1e6"]];
    textView.font = [UIFont systemFontOfSize:12];
    _sickDescTextView = textView;
    
    [textView setPlaceHolder:@"请详细描述您的疾病、症状(必填,10个字以上)"];
    [textView setPlaceHolderColor:RGBCOLOR(196, 198, 205)];
    
    //添加图片
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, textView.bottom + 15, 55, 30) font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"添加图片:"];
    [view addSubview:titleLabel];
    
    //添加图片底部scrollView
    
    UIButton *addPic = [[UIButton alloc]initWithframe:CGRectMake(titleLabel.right + 12, titleLabel.top, 48, 48) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"vip_add"] selectedImage:nil target:self action:@selector(clickToAddPic:)];
    [view addSubview:addPic];
    
    CGFloat top = addPic.bottom + 5;
    NSArray *titles = @[@"医       院:",@"科       室:",@"备选医院:",@"预约时间:"];
    NSArray *placeHolders = @[@"医院(必填)",@"科室(必填)",@"请选择备选医院"];
    for (int i = 0; i < titles.count; i ++) {
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, top, 55, 45) font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:titles[i]];
        [view addSubview:titleLabel];
        top = titleLabel.bottom+ 5;
        
        if (i != 3) {
            UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(titleLabel.right + 12, titleLabel.top + 7.5, t_width, 30)];
            tf.backgroundColor = [UIColor colorWithHexString:@"f6f9fb"];
            tf.textAlignment = NSTextAlignmentCenter;
            [view addSubview:tf];
            [tf addCornerRadius:2.f];
            [tf setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"dfe1e6"]];
            tf.font = [UIFont systemFontOfSize:10];
            [tf setPlaceholder:placeHolders[i]];
        }else
        {
            CGFloat t_width2 = (t_width - 15)/ 2.f;
            
            titles = @[@"开始时间",@"结束时间"];
            for (int i = 0; i < 2; i ++)
            {
                UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(titleLabel.right + 12 + (t_width2 + 15) * i , titleLabel.top + 7.5, t_width2, 30)];
                tf.backgroundColor = [UIColor colorWithHexString:@"f6f9fb"];
                tf.textAlignment = NSTextAlignmentCenter;
                [view addSubview:tf];
                [tf addCornerRadius:2.f];
                [tf setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"dfe1e6"]];
                tf.font = [UIFont systemFontOfSize:10];
                [tf setPlaceholder:titles[i]];
                
                if (i == 1) {
                    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.right + 12, tf.bottom + 5, t_width, 20) font:10 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_ORANGE title:@"注:开始时间距结束时间不少于7个工作日"];
                    [view addSubview:titleLabel];
                }
            }
           
        }
        
        
        
    }
    
    UIButton *sender = [[UIButton alloc]initWithframe:CGRectMake(12, view.bottom + 20, DEVICE_WIDTH - 12 * 2, 38) buttonType:UIButtonTypeCustom normalTitle:@"确认挂号" selectedTitle:nil target:self action:@selector(clickToGuahao:)];
    [self.scrollView addSubview:sender];
    [sender addCornerRadius:5.f];
    sender.backgroundColor = [UIColor colorWithHexString:@"2e80e1"];
    [sender.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    [self.scrollView setContentSize:CGSizeMake(DEVICE_WIDTH, sender.bottom + 10)];
}

-(UITextField *)searchTF
{
    if (!_searchTF) {
        UITextField *searchTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 28)];
        [searchTF addCornerRadius:14.f];
        [searchTF setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"dfe1e6"]];
        searchTF.placeholder = @"搜索医院";
        searchTF.font = [UIFont systemFontOfSize:12.f];
        searchTF.backgroundColor = [UIColor colorWithHexString:@"f6f9fb"];
        searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchTF.leftViewMode = UITextFieldViewModeAlways;
        searchTF.delegate = self;
        _searchTF = searchTF;
        
        UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 13 + 8 + 8, 28)];
        leftImage.contentMode = UIViewContentModeCenter;
        leftImage.image = [UIImage imageNamed:@"vip_fangdajing"];
        searchTF.leftView = leftImage;
    }
    return _searchTF;
}

-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
        _scrollView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

#pragma mark - 事件处理

/**
 *  去搜索医院
 */
- (void)clickToSearchHospital
{
    
}

- (void)clickToSelectHospital
{
    
}

/**
 *  去添加图片
 *
 *  @param sender
 */
- (void)clickToAddPic:(UIButton *)sender
{
    JKImagePickerController *imagePickerController = [[JKImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 0;
    imagePickerController.maximumNumberOfSelection = 9;
    imagePickerController.selectedAssetArray = self.assetsArray;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

/**
 *  确认挂号
 *
 *  @param sender
 */
- (void)clickToGuahao:(UIButton *)sender
{
    
}

/**
 *  去选择就诊人
 *
 *  @param sender
 */
- (void)clickToSelectUserInfo:(UIButton *)sender
{
    PeopleManageController *people = [[PeopleManageController alloc]init];
    people.actionType = PEOPLEACTIONTYPE_SELECT_Single;
    people.noAppointNum = 1;
    [self.navigationController pushViewController:people animated:YES];
    
    __weak typeof(_nameLabel)weakNameLabel = _nameLabel;
    people.updateParamsBlock = ^(NSDictionary *params){
        
        UserInfo *user = params[@"result"];
//        BOOL myself = [params[@"myself"]boolValue];
        _familyUid = user.family_uid;
        weakNameLabel.text = [NSString stringWithFormat:@"%@",user.family_user_name];
        
    };
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _searchTF) //搜搜框
    {
        
    }
    return NO;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}


@end
