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
#import "GHospitalOfProvinceViewController.h"
#import "LTextView.h"
#import "LDatePicker.h"

#define kTag_searchTf 100
#define kTag_hospital 101 //首选医院
#define kTag_hospital2 102 //备用医院
#define kTag_dept 103 //科室
#define kTag_beginTime 104 //开始时间
#define kTag_endTime 105 //结束时间

@interface VipRegisteringController ()<UITextFieldDelegate,JKImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UILabel *_nameLabel;//就诊人name
    LTextView *_sickDescTextView;//病情描述
    NSDate *_beginDate;//开始时间
    
    NSString *_familyUid;//就诊人familyUid
    __block NSString *_hospital_id;//选择医院
    __block NSString *_alternative_hospital_id;//备选医院
    __block NSString *_dept;//科室
}

@property(nonatomic,retain)UITextField *searchTF;
@property(nonatomic,retain)UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic,strong)UIScrollView *imagesScrollView;//放置图片
@property (nonatomic,strong)UIButton *addPicButton;//添加图片按钮
@property (nonatomic,strong)LDatePicker *datePicker;


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
    NSString *desc = _sickDescTextView.text;//病情描述
    
    NSString *hospital = @"005e9c12-f6e7-4d9a-a8f9-1d1f46ffd2ae000";//选择医院
    NSString *alternative_hospital = @"";//备选医院
    NSString *dept = @"18a0dcc1-978c-45a0-a00a-c5a129650435000";//科室
    
    NSString *benginTime = [self textfieldWithTag:kTag_beginTime].text;
    NSString *endTime = [self textfieldWithTag:kTag_endTime].text;
    
    NSString *appointDate = [NSString stringWithFormat:@"%@ %@",benginTime,endTime];//时间 appoint_date 预约起止时间 字符串  例：2016-07-22【空格】2016-07-30
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:[UserInfo getAuthkey] forKey:@"authcode"];
    [params safeSetValue:familyUid forKey:@"family_uid"];//家人uid 选填 如果是家人就填 自己就不写这个参数或为0
    [params safeSetValue:desc forKey:@"desc"];
    [params safeSetValue:hospital forKey:@"hospital_id"];
    [params safeSetValue:alternative_hospital forKey:@"alternative_hospital_id"];
    [params safeSetValue:dept forKey:@"dept_id"];
    [params safeSetValue:appointDate forKey:@"appoint_date"];
    
    return params;
}

/**
 *  先获取图片然后提交预约 UIImage
 *
 *  @return
 */
- (void)getUploadImages
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:1];
    
    for (int i = 0;i < self.assetsArray.count; i++) {
        
        JKAssets* jkAsset = self.assetsArray[i];
        
         @WeakObj(self);
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:jkAsset.assetPropertyURL resultBlock:^(ALAsset *asset) {
            
            if (asset)
            {
                UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                
                [temp addObject:image];
            }
            
            //获取完图片 再提交
            if (temp.count == Weakself.assetsArray.count) {
                [Weakself netWorkForReferralWithImages:temp];
            }
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    
    if (self.assetsArray.count == 0)
    {
        [self netWorkForReferralWithImages:nil];
    }
}

#pragma mark - 获取所选图片

/**
 *  转诊预约新版
 */
- (void)netWorkForReferralWithImages:(NSArray *)images
{
    NSString *api = Guahao_referral_data;
    NSDictionary *params = [self referralParams];
    
    __weak typeof(self)weakSelf = self;
    //    __weak typeof(RefreshTableView *)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:^(id<AFMultipartFormData> formData) {
        
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
        [weakSelf referralSuccessWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

/**
 *  处理挂号成功结果
 *
 *  @param result
 */
- (void)referralSuccessWithResult:(NSDictionary *)result
{
    NSString *resultInfo = result[RESULT_INFO];
    if (self.updateParamsBlock) {
        NSDictionary *params = @{@"result":[NSNumber numberWithBool:YES]};
        self.updateParamsBlock(params);
    }
    [LTools showMBProgressWithText:resultInfo addToView:self.view];
    [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
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
    
    CGFloat titleWidth = 65;
    CGFloat width = DEVICE_WIDTH - 12 * 2;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(12, 12, width , 432)];
    view.backgroundColor = [UIColor whiteColor];
    [view addCornerRadius:5.f];
    [self.scrollView addSubview:view];
    //就诊人
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, titleWidth, 45) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"就 诊 人 :"];
    [view addSubview:titleLabel];
    
    NSString *name = self.userInfo.family_user_name;
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.right + 12, 0, width - titleLabel.right - 12 - 50, 45) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:name];
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
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, line.bottom + 17, titleWidth, 30) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"病情描述:"];
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
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, textView.bottom + 15, titleWidth, 30) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"添加图片:"];
    [view addSubview:titleLabel];
    
    //添加图片按钮
    UIButton *addPicButton = [[UIButton alloc]initWithframe:CGRectMake(titleLabel.right + 12, titleLabel.top, 48, 48) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"vip_add"] selectedImage:nil target:self action:@selector(clickToAddPic:)];
    [view addSubview:addPicButton];
    
    //添加图片底部scrollView
    self.imagesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(addPicButton.right + 5, titleLabel.top, t_width - addPicButton.width - 5, 48)];
    [view addSubview:_imagesScrollView];
    
    CGFloat top = _imagesScrollView.bottom + 5;
    NSArray *titles = @[@"医       院:",@"科       室:",@"备选医院:",@"预约时间:"];
    NSArray *placeHolders = @[@"医院(必填)",@"科室(必填)",@"请选择备选医院"];
    for (int i = 0; i < titles.count; i ++) {
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, top, titleWidth, 45) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:titles[i]];
        [view addSubview:titleLabel];
        top = titleLabel.bottom+ 5;
        
        if (i != 3) {
            UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(titleLabel.right + 12, titleLabel.top + 7.5, t_width, 30)];
            tf.backgroundColor = [UIColor colorWithHexString:@"f6f9fb"];
            tf.textAlignment = NSTextAlignmentCenter;
            tf.delegate = self;
            [view addSubview:tf];
            [tf addCornerRadius:2.f];
            [tf setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"dfe1e6"]];
            tf.font = [UIFont systemFontOfSize:10];
            [tf setPlaceholder:placeHolders[i]];
            
            if (i == 0) {
                tf.tag = kTag_hospital;
            }else if (i == 1)
            {
                tf.tag = kTag_dept;
            }else if (i == 2)
            {
                tf.tag = kTag_hospital2;
            }
            
        }else
        {
            CGFloat t_width2 = (t_width - 15)/ 2.f;
            
            titles = @[@"开始时间",@"结束时间"];
            
            NSDate *beginDate = [[NSDate date] fs_dateByAddingDays:1];
            _beginDate = beginDate;
            
            for (int i = 0; i < 2; i ++)
            {
                UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(titleLabel.right + 12 + (t_width2 + 15) * i , titleLabel.top + 7.5, t_width2, 30)];
                tf.backgroundColor = [UIColor colorWithHexString:@"f6f9fb"];
                tf.delegate = self;
                tf.textAlignment = NSTextAlignmentCenter;
                [view addSubview:tf];
                [tf addCornerRadius:2.f];
                [tf setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"dfe1e6"]];
                tf.font = [UIFont systemFontOfSize:10];
                [tf setPlaceholder:titles[i]];
                
                
                if (i == 1) {
                    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.right + 12, tf.bottom + 5, t_width, 20) font:10 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_ORANGE title:@"注:仅预约今天以后、距结束时间不少于7个工作日"];
                    [view addSubview:titleLabel];
                    
                    tf.tag = kTag_endTime;
                    
                    tf.text = [self endTimeWithBeginTime:beginDate];
                    
                }else
                {
                    tf.tag = kTag_beginTime;
                    
                    tf.text = [LTools timeDate:beginDate withFormat:@"yyyy-MM-dd"];
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

/**
 *  根据开始时间计算结束时间
 *
 *  @param beginDate
 *
 *  @return
 */
- (NSString *)endTimeWithBeginTime:(NSDate *)beginDate
{
    NSDate *endDate = [self endTimeDateWithBeginDate:beginDate];
    
    NSString *endTimeString = [LTools timeDate:endDate withFormat:@"yyyy-MM-dd"];
    
    return endTimeString;
}

- (NSDate *)endTimeDateWithBeginDate:(NSDate *)beginDate
{
    int padding = 1;
    //星期天 1
    int week = (int)[beginDate fs_weekday];
    if (week == 1 || week == 2|| week == 3 || week == 4) //周一至周三 和 周天 需要加9天
    {
        padding = 9;
        
    }else if( week == 5 || week == 6 ) //周四和周五 11
    {
        padding = 11;
        
    }else if (week == 7) //周六
    {
        padding = 10;
    }
    
    NSDate *endDate = [[NSDate date] fs_dateByAddingDays:padding];
    
    return endDate;
}

#pragma mark - getter

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
        searchTF.tag = kTag_searchTf;
        _searchTF = searchTF;
        
        UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 13 + 8 + 8, 28)];
        leftImage.contentMode = UIViewContentModeCenter;
        leftImage.image = [UIImage imageNamed:@"vip_fangdajing"];
        searchTF.leftView = leftImage;
    }
    return _searchTF;
}

/**
 *  底部scroll
 *
 *  @return
 */
-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
        _scrollView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
        [self.view addSubview:_scrollView];
        [_scrollView addTapGestureTaget:self action:@selector(clickToHiddenKeyboard) imageViewTag:0];
    }
    return _scrollView;
}

/**
 *  添加图片按钮
 *
 *  @return
 */
-(UIButton *)addPicButton
{
    if (!_addPicButton) {
        _addPicButton = [[UIButton alloc]initWithframe:CGRectMake(0, 0, 48, 48) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"vip_add"] selectedImage:nil target:self action:@selector(clickToAddPic:)];
    }
    return _addPicButton;
}

- (UITextField *)textfieldWithTag:(int)tag
{
    return (UITextField *)[_scrollView viewWithTag:tag];
}

#pragma mark - 时间选择

/**
 *  选择时间
 *
 *  @param textField 对应textField
 */
- (void)clickToSelectTime:(UITextField *)textField
{
//    __weak typeof(self)weakSelf = self;
    int tag = (int)textField.tag;
    if (tag == kTag_endTime) {
        [self.datePicker setMinDate:[self endTimeDateWithBeginDate:_beginDate]];
    }else
    {
        [self.datePicker setMinDate:_beginDate];
    }
    
    [self.datePicker showDateBlock:^(ACTIONTYPE type, NSString *dateString) {
        
        if (type == ACTIONTYPE_SURE) {
            
            textField.text = dateString;
        }
        
        NSLog(@"dateBlock %@",dateString);
        
    }];
}

/**
 *  时间选择器
 *
 *  @return
 */
-(LDatePicker *)datePicker
{
    if (_datePicker) {
        return _datePicker;
    }
    _datePicker = [[LDatePicker alloc] init];
    
    return _datePicker;
}

#pragma mark - 事件处理


/**
 *  隐藏键盘
 */
- (void)clickToHiddenKeyboard
{
    if ([_sickDescTextView isFirstResponder]) {
        [_sickDescTextView resignFirstResponder];
    }
}

/**
 *  去选择医院
 */
- (void)clickToSelectHospital:(UITextField *)textField
{
    HospitalType type;
    if (textField.tag == kTag_hospital) { //主医院
        type = HospitalType_selectNormal;
    }else
    {
        type = HospitalType_selectAlternative;//备选医院
    }
    [self pushToHospitalType:type textField:textField];
}

/**
 *  去搜索医院
 */
- (void)clickToSearchHospital:(UITextField *)textField
{
    [self pushToHospitalType:HospitalType_search textField:textField];
}

/**
 *  push to 选择医院
 *
 *  @param type
 *  @param textField
 */
- (void)pushToHospitalType:(HospitalType)type
                 textField:(UITextField *)textField
{
    GHospitalOfProvinceViewController *hospital = [[GHospitalOfProvinceViewController alloc]init];
    hospital.hospitalType = type;
    
     @WeakObj(self);
    [hospital setUpdateParamsBlock:^(NSDictionary *params) {
        DDLOG(@"hospital %@",params);
        
        if (type == HospitalType_selectNormal ||
            type == HospitalType_search) //主医院\搜索
        {
            NSString *hospitalId = params[@"hospital_id"];//选择医院id
            if (hospitalId) {
                _hospital_id = hospitalId;
            }
            NSString *hospitalName = params[@"hospitalName"];//已选医院name
            if (hospitalName) {
                [Weakself textfieldWithTag:kTag_hospital].text = hospitalName;
            }
            
            NSString *deptId = params[@"dept_id"];//科室id
            if (deptId) {
                _dept = deptId;
            }

            NSString *deptName = params[@"dept_name"];//科室name
            if (deptName) {
                [Weakself textfieldWithTag:kTag_dept].text = deptName;
            }
            
        }else if (type == HospitalType_selectAlternative) //备选医院
        {
            NSString *alterHospitalId = params[@"alternativeHospitalId"];//备选医院id
            if (alterHospitalId) {
                _alternative_hospital_id = alterHospitalId;
            }
            NSString *alterHospitalName = params[@"alternativeHospitalName"];//备选医院name
            
            if (alterHospitalName)
            {
                [Weakself textfieldWithTag:kTag_hospital2].text = alterHospitalName;

            }
        }

    }];
    [self.navigationController pushViewController:hospital animated:YES];
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
    [self getUploadImages];
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
    int tag = (int)textField.tag;
    if (tag == kTag_searchTf) //搜搜框
    {
        [self clickToSearchHospital:textField];
    }else if (tag == kTag_hospital ||
              tag == kTag_hospital2)
    {
        [self clickToSelectHospital:textField];//选择医院或者备选医院
    }else if (tag == kTag_beginTime ||
              tag == kTag_endTime)
    {
        DDLOG(@"选择时间");
        [self clickToSelectTime:textField];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

#pragma mark - JKImagePickerControllerDelegate
- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAsset:(JKAssets *)asset isSource:(BOOL)source
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets isSource:(BOOL)source
{
    [self updateImagesScrollWithAssets:assets];
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker
{
    [self updateImagesScrollWithAssets:self.assetsArray];
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/**
 *  更新图片ScrollView
 *
 *  @param assets
 */
- (void)updateImagesScrollWithAssets:(NSArray *)assets
{
    int count = (int)assets.count;//当前图片张数
    
    [self resetImageScroll];
    CGFloat dis = 5.f;
    CGFloat width = 48.f;
    CGFloat sumWidth = width * count + dis * (count - 1);
    _imagesScrollView.contentSize = CGSizeMake(sumWidth, _imagesScrollView.height);
    for (int i = 0; i < count; i ++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((width + dis) * i, 0, width, width)];
        [_imagesScrollView addSubview:imageView];
        
        ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
        
        JKAssets *sset = assets[i];
        
        [lib assetForURL:sset.assetPropertyURL resultBlock:^(ALAsset *asset) {
            if (asset) {
                imageView.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            }
            
        } failureBlock:^(NSError *error) {
            
            NSLog(@"error %@",error);
        }];
    }
  
    self.assetsArray = [NSMutableArray arrayWithArray:assets];
}

/**
 *  重置ImageScrollView
 */
- (void)resetImageScroll
{
    for (UIView *view in _imagesScrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
}

@end
