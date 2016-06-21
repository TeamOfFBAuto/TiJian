//
//  OrderCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderCell.h"
#import "OrderModel.h"
#import "ProductModel.h"

@implementation OrderCell

- (void)awakeFromNib {
    // Initialization code
    [self.rightButton setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"ec7d24"]];
    [self.rightButton addCornerRadius:3.f];
    
    [self.leftButton setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR_TITLE];
    [self.leftButton addCornerRadius:3.f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForAddress:(NSString *)address
{
    CGFloat height = 0.f;
     
    if ([LTools isEmpty:address]) {
        height = - 20.f + 2;
        
    }else
    {
        address = [NSString stringWithFormat:@"配送地址:%@",[LTools NSStringNotNull:address]];
        height = [LTools heightForText:address width:DEVICE_WIDTH - 20 font:14];
    }
    
    return 89 + height + 10 + 10 + 50 + 20 + 5;
}

- (void)setCellWithModel:(OrderModel *)aModel
{
    //只有一个商品
    
    int productNum = (int)aModel.products.count;
    
    if (productNum == 1) {
        
        ProductModel *product = [[ProductModel alloc]initWithDictionary:[aModel.products lastObject]];
        
        NSString *imageUrl = product.cover_pic;

        [self.iconImageView l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_HEADIMAGE];
        self.titleLabel.text = product.product_name;
        _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _titleLabel.numberOfLines = 2;
        CGFloat height = [LTools heightForText:product.product_name width:_titleLabel.width font:14];
        _titleLabel.height = height;
        
        self.numLabel.text = [NSString stringWithFormat:@"x%d",[product.product_num intValue]];
        self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[product.current_price floatValue]];;

        if (self.contentScroll) {
            
            for (UIView *aView in _contentScroll.subviews) {
                
                [aView removeFromSuperview];
            }
            
            [_contentScroll removeFromSuperview];
            _contentScroll = nil;
        }
     
    //好多商品
    }else if (productNum > 1){
        
        [self.iconImageView sd_setImageWithURL:nil];
        self.titleLabel.text = @"";
        self.numLabel.text = @"";
        self.priceLabel.text = @"";
        
        if (!self.contentScroll) {
            self.contentScroll = [[LScrollView alloc]initWithFrame:CGRectMake(10, 14, DEVICE_WIDTH - 20, 60)];
            _contentScroll.contentSize = CGSizeMake(productNum * (80 + 5), 50);
            [self.contentView addSubview:_contentScroll];
            
            for (int i = 0; i < productNum; i ++) {
                
                if ([aModel.products isKindOfClass:[NSArray class]]) {
                    NSDictionary *dic = [aModel.products objectAtIndex:i];
                    if ([LTools isDictinary:dic])
                    {
                        ProductModel *product = [[ProductModel alloc]initWithDictionary:dic];
                        NSString *imageUrl = product.cover_pic;
                        UIImageView *aImageView = [[UIImageView alloc]initWithFrame:CGRectMake((80 + 5) * i, 0, 80, 50)];
                        [aImageView l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_HEADIMAGE];
                        aImageView.userInteractionEnabled = NO;
                        [_contentScroll addSubview:aImageView];
                    }
                }
            }
        }
    }
    
    NSString *address = @"";
    CGFloat height = 0.f;
    if (![LTools isEmpty:aModel.address]) {
       address = [NSString stringWithFormat:@"配送地址:%@",[LTools NSStringNotNull:aModel.address]];
       height = [LTools heightForText:address width:DEVICE_WIDTH - 20 font:14];
    }
    self.addressLabel.text = address;
    _addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _addressLabel.numberOfLines = 2;
    _addressLabel.height = height;
    
    self.realPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",[aModel.real_price floatValue]];
    
    if (height > 0) {
        self.infoView.top = _addressLabel.bottom + 10;
    }else
    {
        self.infoView.top = self.topLine.top;
    }
    
    self.backView.height = _infoView.bottom;
    
    NSString *text = [NSString stringWithFormat:@"下单时间:%@",[LTools timeString:aModel.add_time withFormat:@"yyyy-MM-dd"]];
    self.addTimeLabel.text = text;
}

@end
