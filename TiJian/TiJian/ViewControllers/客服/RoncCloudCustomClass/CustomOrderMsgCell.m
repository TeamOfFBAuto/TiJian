//
//  CustomOrderMsgCell.m
//  TiJian
//
//  Created by lichaowei on 16/1/12.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "CustomOrderMsgCell.h"
#import "OrderModel.h"
#import "ProductModel.h"

@implementation CustomOrderMsgCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //图片宽高比 255.0/160
        
//        CGFloat imv_W = 255.0/750 * DEVICE_WIDTH;
//        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, imv_W, [GMAPI scaleWithHeight:0 width:imv_W theWHscale:255.0/160])];
//        [self.contentView addSubview:self.iconImageView];
//        _iconImageView.backgroundColor = [UIColor lightGrayColor];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 12, DEVICE_WIDTH - 20, 15)];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.numberOfLines = 2;
        [self.contentView addSubview:self.titleLabel];
        
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, _titleLabel.bottom + 5, self.titleLabel.frame.size.width, _titleLabel.height)];
//        self.priceLabel.textColor = RGBCOLOR(224, 104, 21);
        self.priceLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
        self.priceLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.priceLabel];
        
//        self.realPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.priceLabel.frame), self.titleLabel.frame.size.width, self.titleLabel.frame.size.height/2)];
//        self.realPriceLabel.textColor = RGBCOLOR(80, 81, 82);
//        self.realPriceLabel.font = [UIFont systemFontOfSize:12];
//        [self.contentView addSubview:self.realPriceLabel];
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((DEVICE_WIDTH - 163)/2.f, _priceLabel.bottom + 10, 163, 28)];
        [btn setTitle:@"发送订单链接" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [btn setBorderWidth:1.f borderColor:DEFAULT_TEXTCOLOR];
        [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        [btn addCornerRadius:3.f];
        [self.contentView addSubview:btn];
        self.senderButton = btn;
        
    }
    return self;
}

- (void)setCellWithModel:(OrderModel *)aModel
{
    NSString *key = @"订单编号:";
    NSString *title = [NSString stringWithFormat:@"%@ %@",key,aModel.order_no];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:title];
    //加粗
    [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, key.length)];
    [self.titleLabel setAttributedText:att];
    
    
    key = @"商品金额:";
    NSString *realPrice = [NSString stringWithFormat:@"¥%.2f",[aModel.real_price floatValue]];
    NSString *totalPrice = [NSString stringWithFormat:@"¥%.2f ",[aModel.total_fee floatValue]];
    NSString *text = [NSString stringWithFormat:@"%@ %@   %@",key,realPrice,totalPrice];
    
    NSRange realPriceRange = [text rangeOfString:realPrice];
    NSRange totalPriceRange = [text rangeOfString:totalPrice];

    NSMutableAttributedString *priceAttString = [[NSMutableAttributedString alloc]initWithString:text];
    [priceAttString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:totalPriceRange];
    //加粗
    [priceAttString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, key.length)];
    [priceAttString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, key.length)];
    
    [priceAttString addAttribute:NSForegroundColorAttributeName value:DEFAULT_TEXTCOLOR_ORANGE range:realPriceRange];
    [self.priceLabel setAttributedText:priceAttString];
}

@end
