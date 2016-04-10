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
@class Gbtn;
@class ConfirmOrderViewController;

typedef void(^yuyueViewClickedBlock)(ProductModel *theModel);

@interface GconfirmOrderCell : UITableViewCell
@property(nonatomic,strong)UIView *yuyueView;//预约相关view
@property(nonatomic,copy)yuyueViewClickedBlock yuyueViewClickedBlock;

-(void)loadCustomViewWithModel:(ProductModel *)model;
-(void)setYuyueViewClickedBlock:(yuyueViewClickedBlock)yuyueViewClickedBlock;

+ (CGFloat)heightForCellWithModel:(ProductModel*)theModel;

@end
