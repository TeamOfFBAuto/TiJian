//
//  GshopCarTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/9.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GshopCarTableViewCell.h"

@implementation GshopCarTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)loadCustomViewWithIndex:(NSIndexPath *)index data:(NSDictionary *)dic{
    
    CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/250];
    
    UIButton *chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat wAndH = 44;
    [chooseBtn setFrame:CGRectMake(0, height*0.5-wAndH*0.5, wAndH, wAndH)];
    chooseBtn.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:chooseBtn];
    
    UIImageView *logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(chooseBtn.frame)+10, 10, height - 20, height - 20)];
    logoImv.backgroundColor = [UIColor redColor];
    
    [self.contentView addSubview:logoImv];
    
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(logoImv.frame)+10, logoImv.frame.origin.y, DEVICE_WIDTH - chooseBtn.frame.size.width - 10 - logoImv.frame.size.width - 10 - 10, logoImv.frame.size.height/3)];
    contentLabel.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:contentLabel];
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentLabel.frame.origin.x, CGRectGetMaxY(contentLabel.frame), contentLabel.frame.size.width, contentLabel.frame.size.height)];
    priceLabel.backgroundColor = RGBCOLOR_ONE;
    [self.contentView addSubview:priceLabel];
    
    UIView *numView = [[UIView alloc]initWithFrame:CGRectMake(priceLabel.frame.origin.x, CGRectGetMaxY(priceLabel.frame), priceLabel.frame.size.width, priceLabel.frame.size.height)];
    numView.backgroundColor = RGBCOLOR_ONE;
    [self.contentView addSubview:numView];
    
}

@end
