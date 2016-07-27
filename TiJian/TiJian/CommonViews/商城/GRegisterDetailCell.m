//
//  GRegisterDetailCell.m
//  TiJian
//
//  Created by gaomeng on 16/7/27.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GRegisterDetailCell.h"

@implementation GRegisterDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 10, 65, 15)];
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.titleLabel];
        
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.right +5, 10, DEVICE_WIDTH-20 - self.titleLabel.width - 10 -10, 0)];
        self.contentLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.contentLabel];
        
    }
    return self;
}


-(void)loadCustomViewWithDic:(NSDictionary *)dic{
    
    NSString *title = [dic stringValueForKey:@"title"];
    NSString *content = [dic stringValueForKey:@"content"];
    
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    [self.contentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(self.titleLabel.right +10, 10)width:DEVICE_WIDTH-20 - self.titleLabel.width - 10 -10 -10];
}

-(CGFloat)heightForCellWithDic:(NSDictionary *)dic{
    CGFloat height = 45;
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:12];
    NSString *content = [dic stringValueForKey:@"content"];
    label.text = content;
    [label setMatchedFrame4LabelWithOrigin:CGPointMake(0, 0) width:DEVICE_WIDTH-20 - self.titleLabel.width - 10 -10];
    
    height = label.height + 20;
    
    return height;
}

@end
