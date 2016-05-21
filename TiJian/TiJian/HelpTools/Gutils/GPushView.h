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
@class GBrandListViewController;

//key
#define Dic_gender @"gender"

#define Dic_city_id @"city_id"
#define Dic_city_name @"city_name"
#define Dic_province_id @"province_id"

#define Dic_price @"price"
#define Dic_high_price @"high_price"
#define Dic_low_price @"low_price"

#define Dic_brand_name @"brand_name"
#define Dic_brand_id @"brand_id"


@protocol GpushViewDelegate <NSObject>

@property(nonatomic,strong)NSArray *brand_city_list;
@property(nonatomic,strong)NSDictionary *shaixuanDic;

-(void)shaixuanFinishWithDic:(NSDictionary *)dic;

-(void)therightSideBarDismiss;

//请求品牌信息
-(void)prepareBrandListWithLocation;

@end

@interface GPushView : UIView<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong)GcustomNavcView *navigationView;//上面navigationview

@property(nonatomic,retain)UIView *noBrandView;//没有获取到品牌信息的提示view

@property(nonatomic,assign)BOOL isRightBtnClicked;

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


//数据相关
@property(nonatomic,strong)NSMutableDictionary *selectDic;//cellforrow取值
@property(nonatomic,strong)NSDictionary *tempDic;//存储初始值 只在开始时备份(把tempDic = select)和最后点击取消时(select = tempDic)改变





/**
 *  有没有性别选项
 */
@property(nonatomic,assign)BOOL isGender;

/**
 *  代理
 */
@property(nonatomic,assign)id<GpushViewDelegate> delegate;
//@property(nonatomic,assign)GBrandListViewController *delegate1;

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
-(id)initWithFrame:(CGRect)frame gender:(BOOL)theGender isHaveShaixuanDic:(NSDictionary *)theDic;



/**
 *  清空筛选条件
 */
-(void)qingkongshaixuanBtnClicked;


-(void)leftBtnClicked:(UIButton*)sender;//点击取消关闭页面
-(void)leftBtnClicked;//手势滑动返回 关闭页面


@end
