//
//  GCustomDownOfProductView.h
//  TiJian
//
//  Created by gaomeng on 16/7/20.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    TheDownViewType_gouwuche =0,//正常(客服、收藏、预约、购物车、加入购物车)
    TheDownViewType_yuyue,//立即预约(联系卖家、电话咨询、收藏、立即预约)
    TheDownViewType_vourcher//代金券跳转(客服、收藏、预约、购物车、立即购买)
}TheDownViewType;

typedef void(^downViewClickedBlock)(NSInteger theTag);

@interface GCustomDownOfProductView : UIView

@property(nonatomic,copy)downViewClickedBlock downViewClickedBlock;
@property(nonatomic,strong)UIButton *addShopCarBtn;//加入购物车
@property(nonatomic,strong)UIButton *shoucang_btn;//收藏
@property(nonatomic,strong)UILabel *shopCarNumLabel;
@property(nonatomic,strong)UIButton *gouwucheOneBtn;//购物车btn

-(void)setDownViewClickedBlock:(downViewClickedBlock)downViewClickedBlock;

-(id)initWithFrame:(CGRect)frame customType:(TheDownViewType)theType;



@end
