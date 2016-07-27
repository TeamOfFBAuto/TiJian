//
//  GRegisterDetailCell.h
//  TiJian
//
//  Created by gaomeng on 16/7/27.
//  Copyright © 2016年 lcw. All rights reserved.
//

/**
 *  挂号详情自定义cell
 */
#import <UIKit/UIKit.h>

@interface GRegisterDetailCell : UITableViewCell

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *contentLabel;

-(void)loadCustomViewWithDic:(NSDictionary *)dic;

-(CGFloat)heightForCellWithDic:(NSDictionary *)dic;

@end
