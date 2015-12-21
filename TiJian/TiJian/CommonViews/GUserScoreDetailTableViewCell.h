//
//  GUserScoreDetailTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/12/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GUserScoreDetailTableViewCell : UITableViewCell


@property(nonatomic,strong)UILabel *titleLabel;//标题
@property(nonatomic,strong)UILabel *timeLabel;//时间
@property(nonatomic,strong)UILabel *score_detailLabel;//积分变动

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)loadDataWithDic:(NSDictionary *)dic;

@end
