//
//  GconfirmOrderCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/18.
//  Copyright © 2015年 lcw. All rights reserved.
//



//确认订单cell

#import <UIKit/UIKit.h>
@class ProductModel;

@interface GconfirmOrderCell : UITableViewCell

-(void)loadCustomViewWithModel:(ProductModel *)model;

+ (CGFloat)heightForCell;

@end
