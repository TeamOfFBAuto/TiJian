//
//  GshopCarTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/9.
//  Copyright © 2015年 lcw. All rights reserved.
//


//购物车自定义cell

#import <UIKit/UIKit.h>

@interface GshopCarTableViewCell : UITableViewCell


-(void)loadCustomViewWithIndex:(NSIndexPath *)index data:(NSDictionary *)dic;


@end
