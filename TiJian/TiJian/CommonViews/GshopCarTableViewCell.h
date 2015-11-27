//
//  GshopCarTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/9.
//  Copyright © 2015年 lcw. All rights reserved.
//


//购物车自定义cell

#import <UIKit/UIKit.h>
@class ProductModel;
@class GShopCarViewController;

@interface GshopCarTableViewCell : UITableViewCell
{
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_addShopCar;
    AFHTTPRequestOperation *_requset_subShopCar;
    
}
@property(nonatomic,assign)GShopCarViewController *delegate;

@property(nonatomic,strong)NSIndexPath *theIndexPath;

@property(nonatomic,strong)UIButton *chooseBtn;

@property(nonatomic,strong)UILabel *numLabel;


-(void)loadCustomViewWithIndex:(NSIndexPath *)index;

/**
 *  cell高度
 *
 *  @return
 */
+ (CGFloat)heightForCell;

@end
