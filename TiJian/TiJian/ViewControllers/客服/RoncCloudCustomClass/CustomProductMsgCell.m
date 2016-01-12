//
//  CustomMsgCell.m
//  TiJian
//
//  Created by lichaowei on 16/1/12.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "CustomProductMsgCell.h"
#import "ProductModel.h"

@implementation CustomProductMsgCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        //图片宽高比 255.0/160
        
        CGFloat imv_W = 255.0/750 * DEVICE_WIDTH;
        self.logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, imv_W, [GMAPI scaleWithHeight:0 width:imv_W theWHscale:255.0/160])];
        [self.contentView addSubview:self.logoImv];
        _logoImv.backgroundColor = [UIColor lightGrayColor];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.logoImv.frame)+10, self.logoImv.frame.origin.y, DEVICE_WIDTH-20-imv_W -10, self.logoImv.frame.size.height*0.5)];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.numberOfLines = 2;
        [self.contentView addSubview:self.titleLabel];
        
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.titleLabel.frame), self.titleLabel.frame.size.width, self.titleLabel.frame.size.height/2)];
        self.priceLabel.textColor = RGBCOLOR(224, 104, 21);
        self.priceLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.priceLabel];
        
        self.originalPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.priceLabel.frame), self.titleLabel.frame.size.width, self.titleLabel.frame.size.height/2)];
        self.originalPriceLabel.textColor = RGBCOLOR(80, 81, 82);
        self.originalPriceLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.originalPriceLabel];
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((DEVICE_WIDTH - 163)/2.f, _logoImv.bottom + 10, 163, 28)];
        [btn setTitle:@"发送商品链接" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [btn setBorderWidth:1.f borderColor:DEFAULT_TEXTCOLOR];
        [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        [btn addCornerRadius:3.f];
        [self.contentView addSubview:btn];
        self.senderButton = btn;
        
        
        
    }
    return self;
}

-(void)loadData:(ProductModel *)theModel{
    
    
    [self.logoImv l_setImageWithURL:[NSURL URLWithString:theModel.cover_pic] placeholderImage:nil];
    
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",theModel.brand_name,theModel.setmeal_name];
    CGFloat imv_W = 255.0/750 * DEVICE_WIDTH;
    [self.titleLabel setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(self.logoImv.frame)+10, self.logoImv.frame.origin.y) width:DEVICE_WIDTH-20-imv_W -10];
    if (self.titleLabel.frame.size.height > self.logoImv.frame.size.height*0.5) {
        [self.titleLabel setHeight:self.logoImv.frame.size.height*0.5];
    }
    
    NSString *priceString = [NSString stringWithFormat:@"￥%@",theModel.setmeal_price];
    
    self.priceLabel.text = priceString;
    
    
    NSString *p = [NSString stringWithFormat:@"￥%@",theModel.setmeal_original_price];
    NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:p];
    [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(80, 81, 82) range:NSMakeRange(0, p.length)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, p.length)];
    [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, p.length)];
    
    
    self.originalPriceLabel.attributedText = aaa;
}

@end
