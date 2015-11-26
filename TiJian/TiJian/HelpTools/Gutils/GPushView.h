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

@interface GPushView : UIView<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong)GcustomNavcView *navigationView;//上面navigationview
@property(nonatomic,strong)UITableView *tab1;//主筛选
@property(nonatomic,strong)UITableView *tab2;//城市选择
@property(nonatomic,strong)UITableView *tab3;//价格
@property(nonatomic,strong)UITableView *tab4;//体检品牌

@property(nonatomic,strong)UILabel *navc_midelLabel;//自定义navigationview 中间Label
@property(nonatomic,strong)UIButton *navc_leftBtn;//自定义navigationview 左边Label
@property(nonatomic,strong)UIButton *navc_rightBtn;//自定义navigationview 右边Label

@property(nonatomic,strong)NSString *userChooseCity;//城市选择
@property(nonatomic,strong)NSString *userChoosePrice;//价钱选择
@property(nonatomic,strong)NSString *userChoosePinpai;//品牌选择


@property(nonatomic,assign)BOOL gender;//没有性别选项

@property(nonatomic,assign)GoneClassListViewController *delegate;


-(id)initWithFrame:(CGRect)frame gender:(BOOL)theGender;


@end
