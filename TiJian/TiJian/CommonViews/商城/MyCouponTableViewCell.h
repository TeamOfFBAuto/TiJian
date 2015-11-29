//
//  MyCouponTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CouponModel;
@class MyCouponViewController;


@interface MyCouponTableViewCell : UITableViewCell


@property(nonatomic,strong)UIButton *chooseBtn;//选择按钮
@property(nonatomic,strong)UIImageView* iconImageView;//logo图
@property(nonatomic,strong)UIImageView *couponImv;//优惠券图片
@property(nonatomic,strong)UILabel *contentLabel;//优惠券描述
@property(nonatomic,strong)UILabel *useTimeLabel;//使用期限


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSIndexPath*)theIndex type:(GCouponType)theType;


-(void)loadDataWithModel:(CouponModel*)theModel;




@end
