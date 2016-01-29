//
//  GconfirmOrderCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/18.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GconfirmOrderCell.h"
#import "ProductModel.h"

@interface GconfirmOrderCell ()

@property(nonatomic,retain)UIImageView *iconImageView;
@property(nonatomic,retain)UILabel *contentLabel;
@property(nonatomic,retain)UILabel *priceLabel;
@property(nonatomic,retain)UILabel *numLabel;
@property(nonatomic,retain)UIImageView *markImageView;//标记加项

@end

@implementation GconfirmOrderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/195];
        UIImageView *logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, [GMAPI scaleWithHeight:height - 20 width:0 theWHscale:250.0/155], height - 20)];
        [self.contentView addSubview:logoImv];
        
        self.iconImageView = logoImv;
        
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(logoImv.frame)+5, logoImv.frame.origin.y, DEVICE_WIDTH - 5 - 15 - 5 - logoImv.frame.size.width - 5 - 5, logoImv.frame.size.height/3)];
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.numberOfLines = 2;
        contentLabel.textColor = [UIColor blackColor];
        [contentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(logoImv.frame)+5, logoImv.frame.origin.y) height:logoImv.frame.size.height/3 limitMaxWidth:DEVICE_WIDTH - 5 - 15 - 5 - logoImv.frame.size.width - 5 - 5 - 30];
        [self.contentView addSubview:contentLabel];
        
        self.contentLabel = contentLabel;
        
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentLabel.frame.origin.x, CGRectGetMaxY(logoImv.frame)-logoImv.frame.size.height/3, DEVICE_WIDTH - 5 - 15 - 5 - logoImv.frame.size.width - 5 - 5 - 40, logoImv.frame.size.height/3)];
        priceLabel.font = [UIFont systemFontOfSize:13];
        priceLabel.textColor = RGBCOLOR(237, 108, 22);
        [self.contentView addSubview:priceLabel];
        
        self.priceLabel = priceLabel;
        
        
        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(priceLabel.frame), logoImv.frame.size.height*0.5 - 10 + logoImv.frame.origin.y, 40, 20)];
        numLabel.font = [UIFont systemFontOfSize:17];
        numLabel.textAlignment = NSTextAlignmentRight;
        numLabel.textColor = RGBCOLOR(237, 108, 22);
        [self.contentView addSubview:numLabel];
        
        self.numLabel = numLabel;
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(priceLabel.left, height - 0.5, DEVICE_WIDTH - priceLabel.left, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [self.contentView addSubview:line];
        
        CGFloat width = 77/2.f;
        self.markImageView = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - width, 0, width, width)];
        _markImageView.image = [UIImage imageNamed:@"jiaqiang"];
        [self.contentView addSubview:_markImageView];
        
    }
    return self;
}


-(void)loadCustomViewWithModel:(ProductModel *)model{
    

    [self.iconImageView l_setImageWithURL:[NSURL URLWithString:model.cover_pic] placeholderImage:nil];
    
    self.contentLabel.text = model.product_name;
    
    [self.contentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(self.iconImageView.frame)+5, self.iconImageView.frame.origin.y) height:self.iconImageView.frame.size.height/3 limitMaxWidth:DEVICE_WIDTH - 5 - 15 - 5 - self.iconImageView.frame.size.width - 5 - 5 - 30];
    
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",model.current_price];
    
    self.numLabel.text = [NSString stringWithFormat:@"X %@",model.product_num];
    
    BOOL additon = [model.is_append intValue] == 1 ? YES : NO;//是否是加强
    self.markImageView.hidden = !additon;
}

+ (CGFloat)heightForCell
{
    CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/195];
    
    return height;
}



@end
