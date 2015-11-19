//
//  GconfirmOrderCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/18.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GconfirmOrderCell.h"
#import "ProductModel.h"

@implementation GconfirmOrderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)loadCustomViewWithModel:(ProductModel *)model{
    
    CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/250];
    
    UIImageView *logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, [GMAPI scaleWithHeight:height-20 width:0 theWHscale:252.0/158], height - 20)];
    [logoImv l_setImageWithURL:[NSURL URLWithString:model.cover_pic] placeholderImage:nil];
    
    [self.contentView addSubview:logoImv];
    
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(logoImv.frame)+5, logoImv.frame.origin.y, DEVICE_WIDTH - 5 - 15 - 5 - logoImv.frame.size.width - 5 - 5, logoImv.frame.size.height/3)];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.numberOfLines = 2;
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.text = model.product_name;
    [contentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(logoImv.frame)+5, logoImv.frame.origin.y) height:logoImv.frame.size.height/3 limitMaxWidth:DEVICE_WIDTH - 5 - 15 - 5 - logoImv.frame.size.width - 5 - 5 - 30];
    [self.contentView addSubview:contentLabel];
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentLabel.frame.origin.x, CGRectGetMaxY(logoImv.frame)-logoImv.frame.size.height/3, DEVICE_WIDTH - 5 - 15 - 5 - logoImv.frame.size.width - 5 - 5 - 40, logoImv.frame.size.height/3)];
    priceLabel.font = [UIFont systemFontOfSize:13];
    priceLabel.textColor = RGBCOLOR(237, 108, 22);
    priceLabel.text = [NSString stringWithFormat:@"￥%@",model.current_price];
    [self.contentView addSubview:priceLabel];
    
    
    UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(priceLabel.frame), logoImv.frame.size.height*0.5 - 10 + logoImv.frame.origin.y, 40, 20)];
    numLabel.font = [UIFont systemFontOfSize:17];
    numLabel.textAlignment = NSTextAlignmentRight;
    numLabel.textColor = RGBCOLOR(237, 108, 22);
    numLabel.text = [NSString stringWithFormat:@"X%@",model.product_num];
    [self.contentView addSubview:numLabel];
    
    
    
}




@end
