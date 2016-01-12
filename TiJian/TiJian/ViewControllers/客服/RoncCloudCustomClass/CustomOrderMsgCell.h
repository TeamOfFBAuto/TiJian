//
//  CustomOrderMsgCell.h
//  TiJian
//
//  Created by lichaowei on 16/1/12.
//  Copyright © 2016年 lcw. All rights reserved.

/**
 *  用于聊天界面自定义订单cell
 */

#import <UIKit/UIKit.h>

@interface CustomOrderMsgCell : UICollectionViewCell

@property(nonatomic,retain)UIButton *senderButton;//发送按钮

@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *realPriceLabel;


@property (nonatomic,retain)UIScrollView *contentScroll;//放置多个商品

- (void)setCellWithModel:(id)aModel;

@end
