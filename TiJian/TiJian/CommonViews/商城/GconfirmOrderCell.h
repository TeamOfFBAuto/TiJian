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
@property(nonatomic,copy)cellClickedBlock cellClickedBlock;

//需要更改界面的view
@property(nonatomic,strong)UIView *yuyueView;//预约相关view
@property(nonatomic,strong)UIView *addProductView;//加项包view
@property(nonatomic,assign)BOOL isConfirmCell;//是否为提交订单页面的cell
@property(nonatomic,strong)UIImageView *jiaxiangbaoImv;//订单详情界面加项包标示

-(void)setCellClickedBlock:(cellClickedBlock)cellClickedBlock;

-(void)loadCustomViewWithModel:(ProductModel *)model;

+ (CGFloat)heightForCellWithModel:(ProductModel*)theModel;

@end
