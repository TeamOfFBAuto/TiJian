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
@class HospitalModel;

typedef enum : NSUInteger {
    CellClickedBlockType_yuyue,
    CellClickedBlockType_delete,
    CellClickedBlockType_changePerson,
    CellClickedBlockType_changeHostpital
} CellClickedBlockType;

typedef void(^cellClickedBlock)(CellClickedBlockType theType,ProductModel *theProduct,HospitalModel *theHospital,UserInfo *theUser);

@interface GconfirmOrderCell : UITableViewCell
@property(nonatomic,strong)UIView *yuyueView;//预约相关view
@property(nonatomic,copy)cellClickedBlock cellClickedBlock;

-(void)setCellClickedBlock:(cellClickedBlock)cellClickedBlock;

-(void)loadCustomViewWithModel:(ProductModel *)model;

+ (CGFloat)heightForCellWithModel:(ProductModel*)theModel;

@end
