//
//  GProductCellTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//



//套餐自定义cell
#import <UIKit/UIKit.h>
#import "ProductModel.h"

@interface GProductCellTableViewCell : UITableViewCell


@property(nonatomic,strong)UIImageView *logoImv;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *originalPriceLabel;
@property(nonatomic,strong)UILabel *priceLabel;


+(CGFloat)getCellHight;


-(void)loadData:(ProductModel *)theModel;


@end
