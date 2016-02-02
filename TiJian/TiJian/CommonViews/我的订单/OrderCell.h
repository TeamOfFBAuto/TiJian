//
//  OrderCell.h
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

/**
 *  订单cell
 */
#import <UIKit/UIKit.h>
#import "LScrollView.h"

@interface OrderCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *realPriceLabel;
@property (strong, nonatomic) IBOutlet PropertyButton *commentButton;//右边按钮
@property (strong, nonatomic) IBOutlet PropertyButton *actionButton;//左边按钮
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UILabel *addTimeLabel;

@property (nonatomic,retain)LScrollView *contentScroll;//放置多个商品

- (void)setCellWithModel:(id)aModel;

+ (CGFloat)heightForAddress:(NSString *)address;

@end
