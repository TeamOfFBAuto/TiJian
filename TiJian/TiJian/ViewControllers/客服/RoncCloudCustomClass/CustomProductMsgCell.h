//
//  CustomMsgCell.h
//  TiJian
//
//  Created by lichaowei on 16/1/12.
//  Copyright © 2016年 lcw. All rights reserved.

/**
 *  用于聊天界面自定义订单cell
 */

#import <RongIMKit/RongIMKit.h>

@interface CustomProductMsgCell : UICollectionViewCell

@property(nonatomic,retain)UIButton *senderButton;//发送按钮

@property(nonatomic,strong)UIImageView *logoImv;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *originalPriceLabel;
@property(nonatomic,strong)UILabel *priceLabel;

-(void)loadData:(id)theModel;

@end
