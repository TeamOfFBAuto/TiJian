//
//  GproductDetailTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//


//套餐详情自定义cell

#import <UIKit/UIKit.h>
@class CoupeView;
@class GproductDetailViewController;
@class ProductModel;

@interface GproductDetailTableViewCell : UITableViewCell
{
    CoupeView *_coupeView;//领取优惠券view
}
@property(nonatomic,assign)GproductDetailViewController *delegate;

@property(nonatomic,strong)ProductModel *productModel;

-(CGFloat)loadCustomViewWithModel:(ProductModel*)theModel index:(NSIndexPath*)theindexPath productCommentArray:(NSArray*)commentArr lookAgainArray:(NSArray *)theLookArray;

@end
