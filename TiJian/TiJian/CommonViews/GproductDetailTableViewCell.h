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

@interface GproductDetailTableViewCell : UITableViewCell
{
    CoupeView *_coupeView;//领取优惠券view
}
@property(nonatomic,assign)GproductDetailViewController *delegate;

@property(nonatomic,strong)NSDictionary *dataDic;

-(CGFloat)loadCustomViewWithDic:(NSDictionary*)dataDic index:(NSIndexPath*)theindexPath productCommentArray:(NSArray*)commentArr;

@end
