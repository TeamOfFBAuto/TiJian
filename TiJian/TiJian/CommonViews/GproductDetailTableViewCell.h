//
//  GproductDetailTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//


//套餐详情自定义cell

#import <UIKit/UIKit.h>

@interface GproductDetailTableViewCell : UITableViewCell


-(CGFloat)loadCustomViewWithDic:(NSDictionary*)dataDic index:(NSIndexPath*)theindexPath;

@end
