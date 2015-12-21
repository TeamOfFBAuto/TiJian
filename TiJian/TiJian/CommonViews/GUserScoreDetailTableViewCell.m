//
//  GUserScoreDetailTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/12/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GUserScoreDetailTableViewCell.h"

@implementation GUserScoreDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 8, DEVICE_WIDTH - 100, 11)];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, CGRectGetMaxY(self.titleLabel.frame)+3, self.titleLabel.frame.size.width, 11)];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:self.timeLabel];
        
        self.score_detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 100, 0, 88, 40)];
        self.score_detailLabel.textColor = RGBCOLOR(241, 108, 22);
        self.score_detailLabel.font = [UIFont systemFontOfSize:10];
        self.score_detailLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.score_detailLabel];
        
    }
    
    return self;
}


-(void)loadDataWithDic:(NSDictionary *)dic{
    
    self.titleLabel.text = [dic stringValueForKey:@"desc"];
    self.timeLabel.text = [GMAPI timechangeYMDhms:[dic stringValueForKey:@"add_time"]];
    if ([[dic stringValueForKey:@"type"] intValue] == 1) {//购买商品消耗积分
        NSString *score = [dic stringValueForKey:@"score"];
        self.score_detailLabel.text = [NSString stringWithFormat:@"-%@",score];
    }else if ([[dic stringValueForKey:@"type"] intValue] == 2){//购买商品赠送积分
        NSString *score = [dic stringValueForKey:@"score"];
        self.score_detailLabel.text = [NSString stringWithFormat:@"+%@",score];
    }
    
    
    
}











@end
