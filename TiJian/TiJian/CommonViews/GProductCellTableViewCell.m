//
//  GProductCellTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GProductCellTableViewCell.h"

@interface GProductCellTableViewCell ()

-(void)loadCustomView;
-(void)loadCustomViewWithData:(ProductModel*)theModel;

@end

@implementation GProductCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self loadCustomView];
    return self;
}



-(void)loadCustomView{
    //图片宽高比 255.0/160
    
    CGFloat imv_W = 255.0/750 * DEVICE_WIDTH;
    self.logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, imv_W, [GMAPI scaleWithHeight:0 width:imv_W theWHscale:255.0/160])];
    [self.contentView addSubview:self.logoImv];
    
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
    
}


+(CGFloat)getCellHight{
    
    CGFloat height = 0.01;
    
    CGFloat imv_W = 255.0/750 * DEVICE_WIDTH;
    
    height = [GMAPI scaleWithHeight:0 width:imv_W theWHscale:255.0/160];
    
    return height + 20;
}




-(void)loadData:(ProductModel *)theModel{
    
    UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5)];
    upLine.backgroundColor = RGBCOLOR(220, 221, 223);
    [self.contentView addSubview:upLine];
    
    
    
    [self.logoImv l_setImageWithURL:[NSURL URLWithString:theModel.cover_pic] placeholderImage:nil];
    
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",[LTools isEmpty:theModel.brand_name]?@"":theModel.brand_name,theModel.setmeal_name];
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

-(void)loadCustomViewWithData:(ProductModel*)theModel{
    [self loadCustomView];
    [self loadData:theModel];
}






@end
