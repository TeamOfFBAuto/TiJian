//
//  GproductDirectoryTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//


//套餐里的具体项目自定义cell
#import <UIKit/UIKit.h>

@interface GproductDirectoryTableViewCell : UITableViewCell



-(CGFloat)loadCustomViewWithData:(NSDictionary*)dic indexPath:(NSIndexPath*)theIndex;

@end
