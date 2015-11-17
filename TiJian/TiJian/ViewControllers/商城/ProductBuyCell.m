//
//  ProductCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/18.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ProductBuyCell.h"
#import "ProductModel.h"

@implementation ProductBuyCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(ProductModel *)model
{
//    if ([model.small_cover_pic isKindOfClass:[NSDictionary class]]) {
//        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[model.small_cover_pic stringValueForKey:@"src"]] placeholderImage:DEFAULT_YIJIAYI];
//    }
//    self.productNameLabel.text = [NSString stringWithFormat:@"%@: %@",model.product_type_name,model.product_name];
//    
//    NSString *text = [NSString stringWithFormat:@"颜色: %@  尺码: %@",model.color,model.size];
//    self.paramLabel.text = text;
//    
//    //有折扣
//    if (model.discount_num < 1) {
//        
//        //原价
//        NSString *price_original = [NSString stringWithFormat:@"%.2f",[model.original_price floatValue]];
//        NSString *price_discount = [NSString stringWithFormat:@"%.2f",[model.product_price floatValue]];
//        
//        NSString *str = [NSString stringWithFormat:@"￥%@ %@",price_discount,price_original];
//        
//        NSAttributedString *temp = [[NSAttributedString alloc]initWithString:str];
//        
//        NSMutableAttributedString *priceAttString = [[NSMutableAttributedString alloc]initWithAttributedString:temp];
//        
//        //中间加横线
//        NSRange range = [str rangeOfString:price_original];
//        
//        [priceAttString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:range];
//        [priceAttString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"767676"] range:range];
//        
//        [self.priceLabel setAttributedText:priceAttString];
//        
//    }else
//    {
//        self.priceLabel.text = [NSString stringWithFormat:@"￥%@",model.product_price];
//
//    }
//    
//    
//    self.numLabel.text = [NSString stringWithFormat:@"x %@",model.product_num];
}

@end
