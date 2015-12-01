//
//  GPushView.h
//  TiJian
//
//  Created by gaomeng on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GcustomNavcView;
@class GoneClassListViewController;

@interface GPushView : UIView<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>


@property(nonatomic,strong)GcustomNavcView *navigationView;//上面navigationview

/**
 *  主筛选
 */
@property(nonatomic,strong)UITableView *tab1;

/**
 *  城市选择
 */
@property(nonatomic,strong)UITableView *tab2;
/**
 *  价格
 */
@property(nonatomic,strong)UITableView *tab3;

/**
 *  体检品牌
 */
@property(nonatomic,strong)UITableView *tab4;

/**
 *  自定义navigationview 中间Label
 */
@property(nonatomic,strong)UILabel *navc_midelLabel;
/**
 *  自定义navigationview 左边Label
 */
@property(nonatomic,strong)UIButton *navc_leftBtn;
/**
 *  自定义navigationview 右边Label
 */
@property(nonatomic,strong)UIButton *navc_rightBtn;

/**
 *  城市选择
 */
@property(nonatomic,strong)NSString *userChooseCity;
/**
 *  价钱选择
 */
@property(nonatomic,strong)NSString *userChoosePrice;
@property(nonatomic,strong)NSString *userChoosePrice_low;
@property(nonatomic,strong)NSString *userChoosePrice_high;
/**
 *  品牌选择
 */
@property(nonatomic,strong)NSString *userChoosePinpai;
@property(nonatomic,strong)NSString *userChoosePinpai_id;

/**
 *  有没有性别选项
 */
@property(nonatomic,assign)BOOL gender;

/**
 *  代理
 */
@property(nonatomic,assign)GoneClassListViewController *delegate;

/**
 *  价格选择填写最低价的label
 */
@property(nonatomic,strong)UITextField *tf_low;

/**
 *  价格选择填写最高价的label
 */
@property(nonatomic,strong)UITextField *tf_high;

/**
 *  初始化
 *
 *  @param frame     frame
 *  @param theGender 是否有性别
 *
 *  @return 
 */
-(id)initWithFrame:(CGRect)frame gender:(BOOL)theGender;


@end
