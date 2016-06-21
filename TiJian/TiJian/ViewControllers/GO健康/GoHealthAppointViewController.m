//
//  GoHealthAppointViewController.m
//  TiJian
//
//  Created by gaomeng on 16/6/13.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GoHealthAppointViewController.h"
#import "ShoppingAddressController.h"
#import "PeopleManageController.h"
#import "GMAPI.h"
#import "AddressModel.h"
#import "LDatePicker.h"
#import "LPickerView.h"
#import "GoHealthChooseCityViewController.h"
//btn.tag [100 200)
//view.tag [200 300)
//textFild.tag [300 400)
//label.tag [400 500)

@interface GoHealthAppointViewController ()<UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>

{
    UIScrollView *_mainScrollView;
    UIView *_upView;//体检人信息
    UIView *_downView;//联系人信息
    LDatePicker *_datePicker;//生日picker
    LPickerView *_pickerView;//选择预约时间

    NSMutableArray *_textFieldArray;//textField数组
    CGPoint _orig_mainscrollView_contentOffset;
    
    
    
    NSDictionary *_userSelectCityDic;

    NSArray *_hours;//小时
    NSArray *_dates;//日期到天
    NSString *_selectDateString;//选择的时间
    
    YJYRequstManager *_request;
    
    CGSize _mainScrollSize;
    
}
@property(nonatomic,retain)LPickerView *pickerView;

@end

@implementation GoHealthAppointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"预约上门";
    
//    self.orderId = @"33";
//    self.productId = @"1110009852737";
    
    _textFieldArray = [NSMutableArray arrayWithCapacity:1];
    [self creatScrollView];
    [self creatUpView];
    [self creatDownView];
    [self creatBirthPicker];
    [self setTfKeyBoard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建
-(void)creatScrollView{
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _mainScrollView.delegate = self;
    _mainScrollView.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.view addSubview:_mainScrollView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyBord)];
    [_mainScrollView addGestureRecognizer:tap];
    
}


//体检人信息
-(void)creatUpView{
    _upView = [[UIView alloc]initWithFrame:CGRectZero];
    [_mainScrollView addSubview:_upView];
    _upView.backgroundColor = [UIColor whiteColor];
    
    //套餐名
    UIView *productView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 45)];
    productView.backgroundColor = RGBCOLOR(244, 245, 246);
    [_upView addSubview:productView];
    
    UILabel *productTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, DEVICE_WIDTH-24, 45)];
    productTitleLabel.textColor = [UIColor blackColor];
    productTitleLabel.backgroundColor = RGBCOLOR(244, 245, 246);
    productTitleLabel.font = [UIFont systemFontOfSize:15];
    productTitleLabel.text = self.productName;
    productTitleLabel.tag = 403;
    [productView addSubview:productTitleLabel];
    
    
    //标题
    UIView *personInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, productTitleLabel.bottom, DEVICE_WIDTH, 40)];
    [_upView addSubview:personInfoView];
    
    UIImageView *personLogoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
    [personLogoImv setImage:[UIImage imageNamed:@"GoAppoint_infoic1.png"]];
    personLogoImv.layer.cornerRadius = 15;
    [personInfoView addSubview:personLogoImv];
    
    UILabel *personTitle = [[UILabel alloc]initWithFrame:CGRectMake(personLogoImv.right+5, 0, DEVICE_WIDTH - 10 - personLogoImv.frame.size.width  - 5-70, 40)];
    personTitle.text = @"体检人信息";
    personTitle.font = [UIFont systemFontOfSize:14];
    personTitle.textColor = RGBCOLOR(109, 162, 211);
    [personInfoView addSubview:personTitle];
    
    UIButton *addPersonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addPersonBtn setImage:[UIImage imageNamed:@"GoHealthAddperson.png"] forState:UIControlStateNormal];
    [addPersonBtn setFrame:CGRectMake(personTitle.right, 0, 70, 40)];
    [addPersonBtn addTarget:self action:@selector(theBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    addPersonBtn.tag = 102;
    [personInfoView addSubview:addPersonBtn];
    
    
    //体检人姓名
    UIView *personNameView = [[UIView alloc]initWithFrame:CGRectMake(0, personInfoView.bottom, DEVICE_WIDTH, 40)];
    [_upView addSubview:personNameView];
    UITextField *_personName_tf = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 70, 40)];
    _personName_tf.placeholder = @"体检人姓名";
    _personName_tf.delegate = self;
    [_textFieldArray addObject:_personName_tf];
    _personName_tf.font = [UIFont systemFontOfSize:12];
    _personName_tf.tag = 300;
    [personNameView addSubview:_personName_tf];
    
    UIView *line_pn = [[UIView alloc]initWithFrame:CGRectMake(28, _personName_tf.bottom, DEVICE_WIDTH - 28 -28, 0.5)];
    line_pn.backgroundColor = DEFAULT_LINECOLOR;
    [personNameView addSubview:line_pn];
    
    //体检人手机
    UIView *personPhoneView = [[UIView alloc]initWithFrame:CGRectMake(0, personNameView.bottom, DEVICE_WIDTH, 40)];
    [_upView addSubview:personPhoneView];
    UITextField *personPhone_tf = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 70, 40)];
    personPhone_tf.placeholder = @"体检人手机";
    personPhone_tf.delegate = self;
    [_textFieldArray addObject:personPhone_tf];
    personPhone_tf.font = [UIFont systemFontOfSize:12];
    personPhone_tf.tag = 301;
    [personPhoneView addSubview:personPhone_tf];
    UIView *line_pp = [[UIView alloc]initWithFrame:CGRectMake(28, personPhone_tf.bottom, DEVICE_WIDTH - 28 -28, 0.5)];
    line_pp.backgroundColor = DEFAULT_LINECOLOR;
    [personPhoneView addSubview:line_pp];
    
    
    //性别
    UIView *personGenderView = [[UIView alloc]initWithFrame:CGRectMake(0, personPhoneView.bottom, DEVICE_WIDTH, 40)];
    [_upView addSubview:personGenderView];
    UILabel *personGender_tLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 30, 40)];
    personGender_tLabel.font = [UIFont systemFontOfSize:12];
    personGender_tLabel.textColor = [UIColor blackColor];
    personGender_tLabel.text = @"性别";
    [personGenderView addSubview:personGender_tLabel];
    UIButton *manBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [manBtn setFrame:CGRectMake(personGender_tLabel.right + 100*DEVICE_WIDTH/750.0, 0, 40, 40)];
    [manBtn setTitle:@"男" forState:UIControlStateNormal];
    manBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [manBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [manBtn setImage:[UIImage imageNamed:@"GappointGenderNoChoose.png"] forState:UIControlStateNormal];
    [manBtn setImage:[UIImage imageNamed:@"GappointGenderChoose.png"] forState:UIControlStateSelected];
    [manBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
    [manBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    manBtn.tag = 100;
    [manBtn addTarget:self action:@selector(chooseGenderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [personGenderView addSubview:manBtn];
    UIButton *womanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [womanBtn setFrame:CGRectMake(manBtn.right + 75*DEVICE_WIDTH/750.0, 0, 40, 40)];
    womanBtn.selected = YES;
    [womanBtn setTitle:@"女" forState:UIControlStateNormal];
    womanBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [womanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [womanBtn setImage:[UIImage imageNamed:@"GappointGenderNoChoose.png"] forState:UIControlStateNormal];
    [womanBtn setImage:[UIImage imageNamed:@"GappointGenderChoose.png"] forState:UIControlStateSelected];
    womanBtn.tag = 101;
    [womanBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
    [womanBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [womanBtn addTarget:self action:@selector(chooseGenderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [personGenderView addSubview:womanBtn];
    
    UIView *line_pgt = [[UIView alloc]initWithFrame:CGRectMake(28, personGender_tLabel.bottom, DEVICE_WIDTH - 28 -28, 0.5)];
    line_pgt.backgroundColor = DEFAULT_LINECOLOR;
    [personGenderView addSubview:line_pgt];
    
    
    //生日
    UIView *personBirthView = [[UIView alloc]initWithFrame:CGRectMake(0, personGenderView.bottom, DEVICE_WIDTH, 40)];
    [_upView addSubview:personBirthView];
    personBirthView.tag = 200;
    [personBirthView addTapGestureTaget:self action:@selector(theViewClicked:) imageViewTag:personBirthView.tag];
    UILabel *personBirth_tLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 30, 40)];
    personBirth_tLabel.font = [UIFont systemFontOfSize:12];
    personBirth_tLabel.textColor = [UIColor blackColor];
    personBirth_tLabel.text = @"生日";
    [personBirthView addSubview:personBirth_tLabel];
    UILabel *personBirthLabel = [[UILabel alloc]initWithFrame:CGRectMake(personBirth_tLabel.right + + 100*DEVICE_WIDTH/750.0, 0,DEVICE_WIDTH - 40 - personBirth_tLabel.width - 40, 40)];
    personBirthLabel.font = [UIFont systemFontOfSize:12];
    personBirthLabel.textColor = [UIColor blackColor];
    personBirthLabel.tag = 400;
    [personBirthView addSubview:personBirthLabel];
    UIButton *personBirth_jiantouBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [personBirth_jiantouBtn setFrame:CGRectMake(personBirthLabel.right, 0, 16, 40)];
    [personBirth_jiantouBtn setImage:[UIImage imageNamed:@"qrdd_jiantou_big.png"] forState:UIControlStateNormal];
    personBirth_jiantouBtn.userInteractionEnabled = NO;
    [personBirthView addSubview:personBirth_jiantouBtn];

    //分隔条
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, personBirthView.bottom, DEVICE_WIDTH, 13)];
    line.backgroundColor = RGBCOLOR(244, 245, 246);
    [_upView addSubview:line];
    
    
    [_upView setFrame:CGRectMake(0, 0, DEVICE_HEIGHT, line.bottom)];
    
}





//联系人信息
-(void)creatDownView{
    _downView = [[UIView alloc]initWithFrame:CGRectZero];
    _downView.backgroundColor = [UIColor whiteColor];
    [_mainScrollView addSubview:_downView];
    
    //标题
    UIView *personInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    [_downView addSubview:personInfoView];
    
    UIImageView *personLogoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
    [personLogoImv setImage:[UIImage imageNamed:@"GoAppoint_infoic2.png"]];
    personLogoImv.layer.cornerRadius = 15;
    [personInfoView addSubview:personLogoImv];
    
    UILabel *personTitle = [[UILabel alloc]initWithFrame:CGRectMake(personLogoImv.right+5, 0, DEVICE_WIDTH - 10 - personLogoImv.frame.size.width  - 5-70, 40)];
    personTitle.text = @"联系信息";
    personTitle.font = [UIFont systemFontOfSize:14];
    personTitle.textColor = RGBCOLOR(109, 162, 211);
    [personInfoView addSubview:personTitle];
    
    UIButton *addPersonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addPersonBtn setImage:[UIImage imageNamed:@"GoHealthAddperson.png"] forState:UIControlStateNormal];
    [addPersonBtn setFrame:CGRectMake(personTitle.right, 0, 70, 40)];
    addPersonBtn.tag = 103;
    [addPersonBtn addTarget:self action:@selector(theBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [personInfoView addSubview:addPersonBtn];
    
    
    //联系人姓名
    UIView *personNameView = [[UIView alloc]initWithFrame:CGRectMake(0, personInfoView.bottom, DEVICE_WIDTH, 40)];
    [_downView addSubview:personNameView];
    
    UITextField *_personName_tf = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 70, 40)];
    _personName_tf.placeholder = @"联系人姓名";
    _personName_tf.delegate = self;
    [_textFieldArray addObject:_personName_tf];
    _personName_tf.font = [UIFont systemFontOfSize:12];
    _personName_tf.tag = 302;
    [personNameView addSubview:_personName_tf];
    
    UIView *line_pn = [[UIView alloc]initWithFrame:CGRectMake(28, _personName_tf.bottom, DEVICE_WIDTH - 28 -28, 0.5)];
    line_pn.backgroundColor = DEFAULT_LINECOLOR;
    [personNameView addSubview:line_pn];
    
    
    //联系人手机
    UIView *personPhoneView = [[UIView alloc]initWithFrame:CGRectMake(0, personNameView.bottom, DEVICE_WIDTH, 40)];
    [_downView addSubview:personPhoneView];
    UITextField *personPhone_tf = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 70, 40)];
    personPhone_tf.placeholder = @"联系人手机";
    personPhone_tf.delegate = self;
    [_textFieldArray addObject:personPhone_tf];
    personPhone_tf.font = [UIFont systemFontOfSize:12];
    personPhone_tf.tag = 303;
    [personPhoneView addSubview:personPhone_tf];
    UIView *line_pp = [[UIView alloc]initWithFrame:CGRectMake(28, personPhone_tf.bottom, DEVICE_WIDTH - 28 -28, 0.5)];
    line_pp.backgroundColor = DEFAULT_LINECOLOR;
    [personPhoneView addSubview:line_pp];
    
    
    
    //选择城市
    UIView *chooseCityView = [[UIView alloc]initWithFrame:CGRectMake(0, personPhoneView.bottom, DEVICE_WIDTH, 40)];
    chooseCityView.tag = 201;
    [chooseCityView addTapGestureTaget:self action:@selector(theViewClicked:) imageViewTag:chooseCityView.tag];
    [_downView addSubview:chooseCityView];
    UILabel *chooseCity_Label = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 40, 40)];
    chooseCity_Label.textColor = RGBCOLOR(199, 199, 205);
    chooseCity_Label.text = @"选择城市";
    chooseCity_Label.tag = 401;
    chooseCity_Label.font = [UIFont systemFontOfSize:12];
    [chooseCityView addSubview:chooseCity_Label];
    
    UIButton *chooseCity_jiantou = [UIButton buttonWithType:UIButtonTypeCustom];
    [chooseCity_jiantou setFrame:CGRectMake(chooseCity_Label.right, 0, 16, 40)];
    [chooseCity_jiantou setImage:[UIImage imageNamed:@"qrdd_jiantou_big.png"] forState:UIControlStateNormal];
    chooseCity_jiantou.userInteractionEnabled = NO;
    [chooseCityView addSubview:chooseCity_jiantou];
    
    UIView *line_cc = [[UIView alloc]initWithFrame:CGRectMake(28, chooseCity_Label.bottom, DEVICE_WIDTH-28-28, 0.5)];
    line_cc.backgroundColor = DEFAULT_LINECOLOR;
    [chooseCityView addSubview:line_cc];
    
    
    //详细地址
    UIView *addressDetailView = [[UIView alloc]initWithFrame:CGRectMake(0, chooseCityView.bottom, DEVICE_WIDTH, 40)];
    [_downView addSubview:addressDetailView];
    UITextField *address_tf = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 50, 40)];
    address_tf.placeholder = @"请输入详细地址";
    address_tf.font = [UIFont systemFontOfSize:12];
    address_tf.delegate = self;
    [_textFieldArray addObject:address_tf];
    address_tf.tag = 304;
    [addressDetailView addSubview:address_tf];
    UIView *line_addr = [[UIView alloc]initWithFrame:CGRectMake(28, address_tf.bottom, DEVICE_WIDTH-28-28, 0.5)];
    line_addr.backgroundColor = DEFAULT_LINECOLOR;
    [addressDetailView addSubview:line_addr];
    
    
    //预约时间
    UIView *appointTimeView = [[UIView alloc]initWithFrame:CGRectMake(0, addressDetailView.bottom, DEVICE_WIDTH, 40)];
    appointTimeView.tag = 202;
    [appointTimeView addTapGestureTaget:self action:@selector(theViewClicked:) imageViewTag:appointTimeView.tag];
    [_downView addSubview:appointTimeView];
    UITextField *appointTime_tf = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 40, 40)];
    appointTime_tf.font = [UIFont systemFontOfSize:12];
    appointTime_tf.placeholder = @"选择预约时间";
    appointTime_tf.enabled = NO;
    appointTime_tf.tag = 402;
    [appointTimeView addSubview:appointTime_tf];
    UIButton *appointTime_jiantou = [UIButton buttonWithType:UIButtonTypeCustom];
    [appointTime_jiantou setFrame:CGRectMake(appointTime_tf.right, 0, 16, 40)];
    [appointTime_jiantou setImage:[UIImage imageNamed:@"qrdd_jiantou_big.png"] forState:UIControlStateNormal];
    appointTime_jiantou.userInteractionEnabled = NO;
    [appointTimeView addSubview:appointTime_jiantou];
    
    [_downView setFrame:CGRectMake(0, _upView.bottom, DEVICE_WIDTH, appointTimeView.bottom)];
    
    //立即预约
    UIButton *appointBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [appointBtn setFrame:CGRectMake(30, _downView.bottom + 15, DEVICE_WIDTH - 60, 40)];
    appointBtn.layer.cornerRadius = 5;
    [appointBtn setBackgroundColor:RGBCOLOR(107, 163, 211)];
    appointBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [appointBtn setTitle:@"立即预约" forState:UIControlStateNormal];
    [appointBtn addTarget:self action:@selector(appointBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:appointBtn];
    
    
    [_mainScrollView setContentSize:CGSizeMake(DEVICE_WIDTH, MAX(appointBtn.bottom + 15, DEVICE_HEIGHT-64+15))];
    
    _mainScrollSize = _mainScrollView.contentSize;
}


-(LDatePicker*)creatBirthPicker{
    if (_datePicker) {
        return _datePicker;
    }
    _datePicker = [[LDatePicker alloc] init];
    
    return _datePicker;
}

- (void)selectBookdate
{
    if (!_pickerView) {
        
        @WeakObj(self);
        _pickerView = [[LPickerView alloc]initWithDelegate:self delegate:self pickerBlock:^(ACTIONTYPE type, int row, int component) {
            if (type == ACTIONTYPE_SURE) {
                
                [Weakself confirmDate];
                
            }else if (type == ACTIONTYPE_Refresh)
            {
                
            }
        }];
    }
    
    [_pickerView pickerViewShow:YES];
    [_pickerView reloadAllComponents];
}

#pragma mark -

- (UITextField *)textFieldWithTag:(int)tag
{
    return (UITextField *)[self.view viewWithTag:tag];
}


#pragma mark - 事件处理

-(void)hiddenTheKeyBord{
    NSLog(@"%s",__FUNCTION__);
}

//性别打钩
-(void)chooseGenderBtnClicked:(UIButton *)sender{
    UIButton *manBtn = [_upView viewWithTag:100];
    UIButton *womanBtn = [_upView viewWithTag:101];
    if (sender.tag == 100) {//男
        if (!sender.selected) {
            sender.selected = YES;
            womanBtn.selected = NO;
        }
    }else if (sender.tag == 101){//女
        if (!sender.selected) {
            sender.selected = YES;
            manBtn.selected = NO;
        }
    }
}


//立即预约按钮
-(void)appointBtnClicked{
    NSLog(@"%s",__FUNCTION__);
    
    //体检人姓名
    UITextField *personName_tf = (UITextField *)[self.view viewWithTag:300];
    NSString *userName_tijian = personName_tf.text;
    if ([LTools isEmpty:userName_tijian]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请填写体检人信息" addToView:self.view];
        return;
    }
    
    //体检人手机
    UITextField *personMoble_tf = (UITextField *)[self.view viewWithTag:301];
    NSString *userPhone_tijian = personMoble_tf.text;
    if ([LTools isEmpty:userPhone_tijian]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请填写体检人手机" addToView:self.view];
        return;
    }
    
    //体检人性别
    UIButton *manBtn = [_upView viewWithTag:100];
    NSString *gender = @"1";//女
    if (manBtn.selected) {
        gender = @"2";
    }
    
    //体检人生日
    UILabel *personBirthLabel = (UILabel *)[self.view viewWithTag:400];
    NSString *birthDate = personBirthLabel.text;
    if ([LTools isEmpty:birthDate]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请填写体检人生日" addToView:self.view];
        return;
    }
    
    
    //联系人姓名
    UITextField *personName_tf_l = (UITextField *)[self.view viewWithTag:302];
    NSString *userName_lianxi = personName_tf_l.text;
    if ([LTools isEmpty:userName_lianxi]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请填写联系人姓名" addToView:self.view];
        return;
    }
    
    //联系人手机
    UITextField *personMoble_tf_l = (UITextField *)[self.view viewWithTag:303];
    NSString *userPhone_lianxi = personMoble_tf_l.text;
    if ([LTools isEmpty:userPhone_lianxi]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请填写联系人手机" addToView:self.view];
        return;
    }
    
    
    //体检人城市
    NSString *provinceName = [_userSelectCityDic stringValueForKey:@"provinceName"];
    int provinceId = [[_userSelectCityDic stringValueForKey:@"provinceId"] intValue];
    NSString *cityName = [_userSelectCityDic stringValueForKey:@"cityName"];
    int cityId = [[_userSelectCityDic stringValueForKey:@"cityId"] intValue];
    NSString *districtName = [_userSelectCityDic stringValueForKey:@"districtName"];
    int districtId = [[_userSelectCityDic stringValueForKey:@"districtId"] intValue];
    if ([LTools isEmpty:cityName]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请选择城市" addToView:self.view];
        return;
    }
    
    
    //体检人详细地址
    UITextField *address_tf = (UITextField*)[self.view viewWithTag:304];
    NSString *address_tijian = address_tf.text;
    if ([LTools isEmpty:address_tijian]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请填写详细地址" addToView:self.view];
        return;
    }
    
    //预约时间
    NSString *userAppointTime = _selectDateString;
    if ([LTools isEmpty:userAppointTime]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请选择预约时间" addToView:self.view];
        return;
    }
    //订单id
    NSString *order_id = self.orderId;
    //随机字符串
    NSString *nonceStr = [LTools randomNum:32];
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [postDic safeSetString:[UserInfo getAuthkey] forKey:@"authcode"];
    [postDic safeSetString:order_id forKey:@"order_id"];//订单id
    [postDic safeSetString:nonceStr forKey:@"nonceStr"];//随机字符串
    [postDic safeSetString:userAppointTime forKey:@"bookTime"];//预约时间
    
    //联系人信息
    NSMutableDictionary *contact = [NSMutableDictionary dictionaryWithCapacity:1];
    [contact safeSetString:userName_lianxi forKey:@"name"];
    [contact safeSetString:userPhone_lianxi forKey:@"phone"];
    [postDic safeSetString:[LTools JSONStringWithObject:contact] forKey:@"contact"];
    
    //体检人信息
    NSMutableDictionary *testees = [NSMutableDictionary dictionaryWithCapacity:1];
    [testees safeSetString:userName_tijian forKey:@"name"];
    [testees safeSetString:birthDate forKey:@"birthday"];
    [testees safeSetInt:[gender intValue] forKey:@"gender"];
    [testees safeSetString:userPhone_tijian forKey:@"phone"];
    [testees safeSetInt:0 forKey:@"isInsurance"];//保险默认都没有
    
    NSArray *productIds = @[self.productId];
    NSString *productionIds = [productIds componentsJoinedByString:@","];
    [testees safeSetString:productionIds forKey:@"productionIds"];
    NSMutableArray *testeesArray = [NSMutableArray arrayWithCapacity:1];
    [testeesArray addObject:testees];
    [postDic safeSetString:[LTools JSONStringWithObject:testeesArray] forKey:@"testees"];
    
    
    //地址
    NSMutableDictionary *address = [NSMutableDictionary dictionaryWithCapacity:1];
    [address safeSetInt:provinceId forKey:@"provinceId"];
    [address safeSetString:provinceName forKey:@"provinceName"];
    [address safeSetInt:cityId forKey:@"cityId"];
    [address safeSetString:cityName forKey:@"cityName"];
    [address safeSetInt:districtId forKey:@"districtId"];
    [address safeSetString:districtName forKey:@"districtName"];
    [address safeSetString:address_tijian forKey:@"address"];
    [postDic safeSetString:[LTools JSONStringWithObject:address] forKey:@"address"];
    
    [self appointInfoToServerWithDic:postDic];
    
}

//按钮点击
-(void)theBtnClicked:(UIButton *)sender{
    NSLog(@"%ld",(long)sender.tag);
    
    PeopleManageController *people = [[PeopleManageController alloc]init];
    people.actionType = PEOPLEACTIONTYPE_SELECT_Single;
    people.noAppointNum = 1;
    
    if (sender.tag == 102) {//体检人信息 添加人
        __weak typeof(self)weakSelf = self;
        people.updateParamsBlock = ^(NSDictionary *params){
            UserInfo *user = params[@"result"];
            user.mySelf = [params[@"myself"]boolValue];
            [weakSelf reloadViewWithData:user senderIdentifier:sender.tag];
        };
        
    }else if (sender.tag == 103){//联系信息 添加人
        __weak typeof(self)weakSelf = self;
        people.updateParamsBlock = ^(NSDictionary *params){
            UserInfo *user = params[@"result"];
            user.mySelf = [params[@"myself"]boolValue];
            [weakSelf reloadViewWithData:user senderIdentifier:sender.tag];
        };
    }
    
    [self.navigationController pushViewController:people animated:YES];
    
    
}

//view点击
-(void)theViewClicked:(UITapGestureRecognizer *)sender{
    NSLog(@"%ld",(long)sender.view.tag);
    if (sender.view.tag == 200) {//生日
        [self hiddenKeyBord];
        [self clickToUpdateBirthday];
    }else if (sender.view.tag == 201){//城市
        [self hiddenKeyBord];
        GoHealthChooseCityViewController *cc = [[GoHealthChooseCityViewController alloc]init];
        cc.productId = self.productId;
        __weak typeof (self)bself = self;
        [cc setUserSelectCityBlock:^(NSDictionary *userSelectCityDic) {
            
            [bself reloadViewWithData:(NSDictionary*)userSelectCityDic senderIdentifier:201];
            
        }];
        [self.navigationController pushViewController:cc animated:YES];
    }else if (sender.view.tag == 202){//时间
        [self hiddenKeyBord];
        [self netWorkForAvailableTime];
    }
}


- (void)clickToUpdateBirthday
{
    __weak typeof(self)weakSelf = self;
    [_datePicker showDateBlock:^(ACTIONTYPE type, NSString *dateString) {
        
        if (type == ACTIONTYPE_SURE) {
            [weakSelf reloadViewWithData:dateString senderIdentifier:200];
        }
        
        NSLog(@"dateBlock %@",dateString);
        
    }];
    
//    NSString *birthday =  [NSString stringWithFormat:@"%@",_userInfo.birthday];
//    if ([LTools isEmpty:birthday]) {
//        birthday = @"1990-01-01";
//    }
//    NSDate *date = [LTools dateFromString:birthday withFormat:@"yyyy-MM-dd"];
//    [_datePicker setInitDate:date];

}

- (void)confirmDate
{
    UIPickerView *pickerView = _pickerView.pickerView;
    NSDictionary *dateDic = _dates[[pickerView selectedRowInComponent:0]];
    if (![LTools isDictinary:dateDic]) {
        DDLOG(@"时间格式有问题");
        [LTools showMBProgressWithText:@"没有获取到可用预约时间" addToView:self.view];
        return;
    }
    NSString *date = dateDic[@"date"];
    NSArray *hours = dateDic[@"hours"];
    NSNumber *hour = hours[[pickerView selectedRowInComponent:1]];
    int minus = (int)[pickerView selectedRowInComponent:2];
    
    DDLOG(@"date:%@ hour:%@ minus:%d",date,hour,minus);
    
    NSDate *selectDate = [LTools dateFromString:date withFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    date = [LTools timeDate:selectDate withFormat:@"yyyy-MM-dd"];
    
    NSString *timeString = [NSString stringWithFormat:@"%@ %@:%@:00",date,[self doubleString:[hour intValue]],[self doubleString:minus]];
    NSString *test = [NSString stringWithFormat:@"%@ +0800",timeString];
    _selectDateString = test;
    DDLOG(@"test:%@",test);
    
    [self textFieldWithTag:402].text = timeString;
}

- (NSString *)doubleString:(int)num
{
    return [NSString stringWithFormat:@"%02d",(int)num];
}

#pragma mark - 拿到数据后刷新界面
-(void)reloadViewWithData:(id)theRetureData senderIdentifier:(NSInteger)tag{
    if ([theRetureData isKindOfClass:[UserInfo class]]) {//选择人
        if (tag == 102) {//体检人
            UserInfo *user = (UserInfo*)theRetureData;
            
            //体检人姓名
            UITextField *personName_tf = (UITextField *)[self.view viewWithTag:300];
            if (user.mySelf) {
                personName_tf.text = user.user_name;
            }else{
                personName_tf.text = user.family_user_name;
            }
            
            //体检人电话
            UITextField *personMoble_tf = (UITextField *)[self.view viewWithTag:301];
            personMoble_tf.text = user.mobile;
            
            //性别
            UIButton *girlBtn = (UIButton *)[self.view viewWithTag:101];
            UIButton *boyBtn = (UIButton*)[self.view viewWithTag:100];
            if ([user.gender intValue] == 2) {//女
                girlBtn.selected = YES;
                boyBtn.selected = NO;
            }else if ([user.gender intValue] == 1){//男
                girlBtn.selected = NO;
                boyBtn.selected = YES;
            }
            
            //生日
            NSString *birth = [LTools getIdCardbirthday:user.id_card];
            UILabel *birthLabel = [self.view viewWithTag:400];
            birthLabel.text = birth;
            
            
        }else if (tag == 103){//联系人
            UserInfo *user = (UserInfo*)theRetureData;
            //联系人姓名
            UITextField *personName_tf = (UITextField *)[self.view viewWithTag:302];
            if (user.mySelf) {
                personName_tf.text = [NSString stringWithFormat:@"%@",user.user_name];
            }else{
                personName_tf.text = [NSString stringWithFormat:@"%@",user.family_user_name];
            }
            
            //联系人电话
            UITextField *personMoble_tf = (UITextField *)[self.view viewWithTag:303];
            personMoble_tf.text = user.mobile;
            
        }
    }else if ([theRetureData isKindOfClass:[NSString class]]){//生日
        if (tag == 200) {
            NSString *str = (NSString *)theRetureData;
            UILabel *personBirthLabel = (UILabel *)[self.view viewWithTag:400];
            personBirthLabel.text = str;
        }
    }else if ([theRetureData isKindOfClass:[NSDictionary class]]){
        if (tag == 201) {//选择城市
            NSDictionary *dic = (NSDictionary *)theRetureData;
            _userSelectCityDic = dic;
            NSString *city = [dic stringValueForKey:@"districtName"];
            NSString *province = [dic stringValueForKey:@"cityName"];
            UILabel *personCityLabel = [(UILabel *)self.view viewWithTag:401];
            personCityLabel.textColor = [UIColor blackColor];
            personCityLabel.text = [NSString stringWithFormat:@"%@ %@",province,city];
            //清空预约时间
            UITextField *appointTime_tf = [self.view viewWithTag:402];
            appointTime_tf.text = @"";
            
        }
    }
}




#pragma mark - 网络相关

/**
 *  可预约时间
 */
- (void)netWorkForAvailableTime
{
    //    respTimeInDate	YES	Int	1	返回格式
    //    itemCodes	NO	String	10015, 10073	检测项目,id 以","分割
    //    	NO	String	1100000123,111000000	产品的idNumber, id 以","分割
    //    	NO	int	1948	城市Id
    //    	NO	int	1970	区县Id
    
    NSString *productionIds = self.productId;//产品的idNumber, id 以","分割
    
    NSString *theCityId = [_userSelectCityDic stringValueForKey:@"cityId"];
    NSString *theDistrictId = [_userSelectCityDic stringValueForKey:@"districtId"];
    
    NSString *cityid = @"";//城市id
    NSString *districtid = @"";//区县id
    
    if (![LTools isEmpty:theCityId] && ![LTools isEmpty:theDistrictId]) {
        cityid = theCityId;
        districtid = theDistrictId;
    }else{
        [GMAPI showAutoHiddenMBProgressWithText:@"请先选择城市" addToView:self.view];
        return;
    }
    
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    [params safeSetValue:productionIds forKey:@"productionIds"];
    [params safeSetValue:cityid forKey:@"cityId"];
    [params safeSetValue:districtid forKey:@"districtId"];
    [params safeSetInt:1 forKey:@"respTimeInDate"];
    
    NSString *sign = [MiddleTools goHealthSignWithParams:params];
    [params safeSetValue:sign forKey:@"sign"];
    
    @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet_goHealth api:GoHealth_book_dates parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [Weakself parseBookTimeWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"%@",result[@"msg"]);
    }];
}

- (void)parseBookTimeWithResult:(NSDictionary *)result
{
    result = result[@"data"];
    NSArray *dates = result[@"dates"];
    _dates = [NSArray arrayWithArray:dates];
    
    [self selectBookdate];
}


//提交预约信息
-(void)appointInfoToServerWithDic:(NSDictionary *)postDic{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSLog(@"%@",postDic);

     @WeakObj(self);
    [_request requestWithMethod:YJYRequstMethodPost api:GoHealth_upAppointUserInfo parameters:postDic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [Weakself appointSuccessWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        [LTools showMBProgressWithText:@"预约失败,请稍后再试" addToView:Weakself.view];
    }];
}

#pragma mark - 数据处理

/**
 *  预约成功
 *
 *  @param result
 */
- (void)appointSuccessWithResult:(NSDictionary *)result
{
    NSLog(@"%@",result);
    //预约成功通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPOINT_SUCCESS object:nil];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:Alert_AppointSucess delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //返回
    [self leftButtonTap:nil];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0) {
        return _dates.count;
    }else if (component == 1){
        NSDictionary *date = _dates[[pickerView selectedRowInComponent:0]];
        NSArray *hours = date[@"hours"];
        return hours.count;
    }
    return 60;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        
        NSDictionary *dateDic = _dates[row];
        NSString *string = dateDic[@"date"];
        NSDate *date = [LTools dateFromString:string withFormat:@"yyyy-MM-dd HH:mm:ssZ"];
        
        return [NSString stringWithFormat:@"%@ %@",[LTools timeDate:date withFormat:@"MM/dd"],[LTools weekWithDate:date]];
        
    }else if (component == 1){
        
        NSDictionary *date = _dates[[pickerView selectedRowInComponent:0]];
        NSArray *hours = date[@"hours"];
        return [NSString stringWithFormat:@"%d点",[hours[row] intValue]];
    }
    return [self doubleString:(int)row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0) {
        [pickerView reloadComponent:1];
    }
}

//- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0) __TVOS_PROHIBITED; // attributed title is favored if both methods are implemented
//{
//    NSString *string = @"";
//    if (component == 0) {
//        
//        NSDictionary *dateDic = _dates[row];
//        NSString *string = dateDic[@"date"];
//        NSDate *date = [LTools dateFromString:string withFormat:@"yyyy-MM-dd HH:mm:ssZ"];
//        
//        string = [NSString stringWithFormat:@"%@ %@",[LTools timeDate:date withFormat:@"MM/dd"],[LTools weekWithDate:date]];
//        
//    }else if (component == 1){
//        
//        NSDictionary *date = _dates[[pickerView selectedRowInComponent:0]];
//        NSArray *hours = date[@"hours"];
//        string = [NSString stringWithFormat:@"%d点",[hours[row] intValue]];
//    }else
//    {
//        
//        string = [self doubleString:(int)row];
//    }
//    
//    return [LTools attributedString:string keyword:string color:DEFAULT_TEXTCOLOR_TITLE keywordFontSize:10];
//}

//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
//{
//    return 45.f;
//}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        return DEVICE_WIDTH / 2.f;
    }
    return DEVICE_WIDTH / 4.f;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    CGPoint origin = textField.frame.origin;
    CGPoint point = [textField.superview convertPoint:origin toView:_mainScrollView];
    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGPoint offset = _mainScrollView.contentOffset;
    // Adjust the below value as you need
    
    
    offset.y = (point.y - navBarHeight - 150);
    
    if (iPhone4) {
        offset.y = (point.y - navBarHeight - 50);
    }
    
    offset.y = MAX(0, offset.y);
    
    _orig_mainscrollView_contentOffset = _mainScrollView.contentOffset;
    
    [_mainScrollView setContentOffset:offset animated:YES];
    
    [_mainScrollView setContentSize:CGSizeMake(DEVICE_WIDTH, _mainScrollSize.height+offset.y)];
    
    
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag == 304) {
        [self hiddenKeyBord];
    }else{
        UITextField *tf = [self.view viewWithTag:(textField.tag+1)];
        [tf becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - 收键盘
-(void)hiddenKeyBord{
    for (UITextField *tf in _textFieldArray) {
        [tf resignFirstResponder];
    }
    [_mainScrollView setContentSize:_mainScrollSize];
//    [_mainScrollView setContentOffset:_orig_mainscrollView_contentOffset animated:YES];
    [_mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

#pragma mark - 设置时间右下角按键名称
-(void)setTfKeyBoard{
    for (UITextField *tf in _textFieldArray) {
        tf.returnKeyType = UIReturnKeyNext;
        if (tf.tag == 301 || tf.tag == 303) {
            tf.keyboardType = UIKeyboardTypeNumberPad;
        }else if (tf.tag == 304){
            tf.returnKeyType = UIReturnKeyDefault;
        }
        
    }
}





@end
