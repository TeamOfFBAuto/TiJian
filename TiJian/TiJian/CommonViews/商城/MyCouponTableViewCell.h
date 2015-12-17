//
//  MyCouponTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gbtn.h"
@class CouponModel;
@class MyCouponViewController;

@interface MyCouponTableViewCell : UITableViewCell


@property(nonatomic,strong)Gbtn *chooseBtn;//选择按钮
@property(nonatomic,strong)UIImageView* iconImageView;//logo图
@property(nonatomic,strong)UIImageView *couponImv;//优惠券图片
@property(nonatomic,strong)UILabel *contentLabel;//优惠券描述
@property(nonatomic,strong)UILabel *useTimeLabel;//使用期限
@property(nonatomic,assign)MyCouponViewController *delegate;
@property(nonatomic,strong)UIImageView *daijiquanImv;//代金券图片
@property(nonatomic,strong)UILabel *daijinquan_priceLabel;//代金券上的价格
@property(nonatomic,strong)UILabel *daijinquan_brandNameLabel;//代金券的品牌
@property(nonatomic,strong)UILabel *daijinquan_timeLabel;//代金券的使用时间
@property(nonatomic,strong)UILabel *companyLabel;//代金券前方公司名
@property(nonatomic,strong)UILabel *miaoshuLabel;//代金券描述

@property(nonatomic,strong)UIImageView *disable_use_imv;//不可用的imv

@property(nonatomic,strong)UILabel *imvTitleLabel;//优惠标题


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSIndexPath*)theIndex type:(GCouponType)theType;


-(void)loadDataWithModel:(CouponModel*)theModel type:(GCouponType)theType;




@end
