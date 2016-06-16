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
//btn.tag [100 200)
//view.tag [200 300)
//textFild.tag [300 400)
//label.tag [400 500)

@interface GoHealthAppointViewController ()<UIScrollViewDelegate>
{
    UIScrollView *_mainScrollView;
    UIView *_upView;//体检人信息
    UIView *_downView;//联系人信息
    LDatePicker *_datePicker;//生日picker
    LPickerView *_pickerView;//选择预约时间
}
@property(nonatomic,retain)LPickerView *pickerView;

@end

@implementation GoHealthAppointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"预约上门";
    [self creatScrollView];
    [self creatUpView];
    [self creatDownView];
    [self creatBirthPicker];
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
    productTitleLabel.text = @"女性乐享健康体检套餐";
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
    _personName_tf.font = [UIFont systemFontOfSize:12];
    _personName_tf.tag = 300;
    [personNameView addSubview:_personName_tf];
    
    UIView *line_pn = [[UIView alloc]initWithFrame:CGRectMake(28, _personName_tf.bottom, DEVICE_WIDTH - 28 -28, 0.5)];
    line_pn.backgroundColor = DEFAULT_LINECOLOR;
    [personNameView addSubview:line_pn];
    
    //体检人手机
    UIView *personPhoneView = [[UIView alloc]initWithFrame:CGRectMake(0, personNameView.bottom, DEVICE_WIDTH, 40)];
    [_upView addSubview:personPhoneView];
    UITextField *personPhone_tf = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 50, 40)];
    personPhone_tf.placeholder = @"体检人手机";
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
    UILabel *personBirthLabel = [[UILabel alloc]initWithFrame:CGRectMake(personBirth_tLabel.right, 0,DEVICE_WIDTH - 40 - personBirth_tLabel.width - 40, 40)];
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
    _personName_tf.font = [UIFont systemFontOfSize:12];
    _personName_tf.tag = 302;
    [personNameView addSubview:_personName_tf];
    
    UIView *line_pn = [[UIView alloc]initWithFrame:CGRectMake(28, _personName_tf.bottom, DEVICE_WIDTH - 28 -28, 0.5)];
    line_pn.backgroundColor = DEFAULT_LINECOLOR;
    [personNameView addSubview:line_pn];
    
    
    //联系人手机
    UIView *personPhoneView = [[UIView alloc]initWithFrame:CGRectMake(0, personNameView.bottom, DEVICE_WIDTH, 40)];
    [_downView addSubview:personPhoneView];
    UITextField *personPhone_tf = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 50, 40)];
    personPhone_tf.placeholder = @"联系人手机";
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
    UILabel *appointTime_label = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, DEVICE_WIDTH - 40 - 40, 40)];
    appointTime_label.font = [UIFont systemFontOfSize:12];
    appointTime_label.text = @"选择预约时间";
    appointTime_label.textColor = RGBCOLOR(199, 199, 205);
    appointTime_label.tag = 402;
    [appointTimeView addSubview:appointTime_label];
    UIButton *appointTime_jiantou = [UIButton buttonWithType:UIButtonTypeCustom];
    [appointTime_jiantou setFrame:CGRectMake(appointTime_label.right, 0, 16, 40)];
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
    
    
    [_mainScrollView setContentSize:CGSizeMake(DEVICE_WIDTH, MAX(appointBtn.bottom, DEVICE_HEIGHT-64+15))];
    
}


-(LDatePicker*)creatBirthPicker{
    if (_datePicker) {
        return _datePicker;
    }
    _datePicker = [[LDatePicker alloc] init];
    
    return _datePicker;
}



#pragma mark - 点击事件

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
        [self clickToUpdateBirthday];
    }else if (sender.view.tag == 201){//城市
        
    }else if (sender.view.tag == 202){//时间
        
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



//拿到数据后刷新界面
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
    }else if ([theRetureData isKindOfClass:[NSString class]]){
        if (tag == 200) {
            NSString *str = (NSString *)theRetureData;
            UILabel *personBirthLabel = (UILabel *)[self.view viewWithTag:400];
            personBirthLabel.text = str;
        }
    }
}

#pragma mark - 网络请求

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
    
    NSString *productionIds = @"";//产品的idNumber, id 以","分割
    NSString *cityid = @"";//城市id
    NSString *districtid = @"";//区县id
    
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    [params safeSetValue:productionIds forKey:@"productionIds"];
    [params safeSetValue:cityid forKey:@"cityId"];
    [params safeSetValue:districtid forKey:@"districtId"];
    
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
    NSArray *dates = result[@"dates"];
    NSArray *hours = result[@"hours"];
    //    ": [
    //    "2016-06-17 00:00:00 +0800",
    //    "2016-06-18 00:00:00 +0800",
    //    "2016-06-19 00:00:00 +0800"
    //    ],
    //    ""
}

- (void)selectBrand
{
    if (!_pickerView) {
        
        @WeakObj(self);
        _pickerView = [[LPickerView alloc]initWithDelegate:self delegate:self pickerBlock:^(ACTIONTYPE type, int row, int component) {
            if (type == ACTIONTYPE_SURE) {
                
                
                
            }else if (type == ACTIONTYPE_Refresh)
            {
                
            }
        }];
    }
    
    [_pickerView pickerViewShow:YES];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return 10;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)componen{
    
    return [NSString stringWithFormat:@"%d",(int)row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"年龄%d",(int)row + 1);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 45.f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view __TVOS_PROHIBITED
{
    UIView *pickerCell = view;
    if (!pickerCell) {
        pickerCell = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, [UIScreen mainScreen].bounds.size.width, 45.0f}];
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(50, 10, 25, 25)];
        icon.backgroundColor = [UIColor orangeColor];
        [pickerCell addSubview:icon];
        icon.tag = 100;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 10, 10, 200, 25) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@""];
        [pickerCell addSubview:label];
        label.tag = 101;
    }
    
    UIImageView *icon = [pickerCell viewWithTag:100];
    UILabel *label = [pickerCell viewWithTag:101];
   
    
    return pickerCell;
}

@end
