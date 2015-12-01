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


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSIndexPath*)theIndex type:(GCouponType)theType;


-(void)loadDataWithModel:(CouponModel*)theModel;




@end
