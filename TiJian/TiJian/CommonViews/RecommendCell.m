//
//  RecommendCell.m
//  TiJian
//
//  Created by lichaowei on 16/1/27.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "RecommendCell.h"
#import "RecommendProjectModel.h"

@interface RecommendCell(){
    UIView *_backView;
}

@property(nonatomic,retain)UILabel *price_label;
@property(nonatomic,retain)UILabel *numLabel;
@property(nonatomic,retain)UILabel *contentLabel;
@property(nonatomic,retain)UILabel *titleLabel;
@property(nonatomic,retain)UIView *line;

@end

@implementation RecommendCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _bgImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_bgImageView];
        
        self.backView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 170)];
        _backView.clipsToBounds = YES;
//        [_backView addCornerRadius:3.f];
//        _backView.backgroundColor = DEFAULT_TEXTCOLOR;
        [self.contentView addSubview:_backView];
        
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, _backView.width - 20, 35) font:14 align:NSTextAlignmentLeft textColor:[UIColor whiteColor] title:@"基础套餐"];
        [_backView addSubview:title];
        self.titleLabel = title;
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(_backView.width - 25, 0, 25, 35)];
        arrow.image = [UIImage imageNamed:@"jiantou_white"];
        arrow.contentMode = UIViewContentModeCenter;
        [_backView addSubview:arrow];
        
        //价格
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(arrow.left - 100 + 5 , 0, 100, 35) font:14 align:NSTextAlignmentRight textColor:[UIColor whiteColor] title:@"380起"];
        [_backView addSubview:priceLabel];
        NSString *priceString = [NSString stringWithFormat:@"380元起"];
        [priceLabel setAttributedText:[LTools attributedString:priceString keyword:@"起" color:[UIColor whiteColor] keywordFontSize:9]];
        self.price_label = priceLabel;
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(10, priceLabel.bottom, _backView.width - 20 - 100, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [_backView addSubview:line];
        
        //指数
        title = [[UILabel alloc]initWithFrame:CGRectMake(10, line.bottom, 60, 35) font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"ebf5ff"] title:@"推荐指数"];
        [_backView addSubview:title];
        
        //星星
        for (int i = 0; i < 5; i ++ ) {
            UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(title.right + 5 + (3 + 10) * i, 0, 10, 10)];
            icon.image = [UIImage imageNamed:@"star"];
            [_backView addSubview:icon];
            icon.centerY = title.centerY;
            icon.tag = 100 + i;
        }
        
        //体检项目
        title = [[UILabel alloc]initWithFrame:CGRectMake(10, title.bottom, 60, 15) font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"ebf5ff"] title:@"体检项目"];
        [_backView addSubview:title];
        
        NSString *desc = @"";
        //体检项目内容
        CGFloat width = DEVICE_WIDTH - 20 - 60 - 5 - 20;
        UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(title.right + 5, title.top,width, 10) font:14 align:NSTextAlignmentLeft textColor:[UIColor whiteColor] title:desc];
        content.numberOfLines = 0;
        content.lineBreakMode = NSLineBreakByCharWrapping;
        [_backView addSubview:content];
        self.contentLabel = content;
        
        CGFloat height = [LTools heightForText:desc width:content.width font:14];
        content.height = height;
        
        //line
        line = [[UIImageView alloc]initWithFrame:CGRectMake(10, content.bottom + 10, _backView.width - 20, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [_backView addSubview:line];
        self.line = line;
        
        //符合推荐条数
        title = [[UILabel alloc]initWithFrame:CGRectMake(10, line.bottom, _backView.width - 20, 35) font:14 align:NSTextAlignmentCenter textColor:[UIColor whiteColor] title:@""];
        [_backView addSubview:title];
        title.text = @"";
        self.numLabel = title;
    }
    return self;
}

- (void)setCellWithModel:(RecommendProjectModel *)model
{
    int star = [model.star_num intValue];
    int brandNum = [model.brand_num intValue];
    CGFloat minPrice = [model.min_price floatValue];//价格
//    NSArray *projects = model.project_list;
    
    NSString *title = @"基础套餐";
    if (star == 5)
    {
        title = @"专业套餐";
    }else if (star == 4)
    {
        title = @"标准套餐";
    }else
    {
        
        title = @"基础套餐";
    }
    self.titleLabel.text = title;
    
    NSString *priceString = [NSString stringWithFormat:@"%.f元起",minPrice];
    [self.price_label setAttributedText:[LTools attributedString:priceString keyword:@"起" color:[UIColor whiteColor] keywordFontSize:9]];
    
    //控制星星
    
    //星星
    for (int i = 0; i < 5; i ++ ) {
        UIImageView *icon = [_backView viewWithTag:100 + i];
        if (i < star) {
            icon.hidden = NO;
        }else
        {
            icon.hidden = YES;
        }
    }
    
    //品牌个数
    NSString *numstring = [NSString stringWithFormat:@"符合本次评估结果的推荐体检品牌有%d个",brandNum];
    self.numLabel.text = numstring;
    
    //体检项目
    NSString *content = [RecommendCell projectStringWithModel:model];
    self.contentLabel.text = content;
    CGFloat width = DEVICE_WIDTH - 20 - 60 - 5 - 20;
    CGFloat height = [LTools heightForText:content width:width font:14];
    self.contentLabel.height = height;
    
    self.line.top = _contentLabel.bottom + 5 + 5;
    self.numLabel.top = _line.bottom;
    _backView.height = _numLabel.bottom;
}

+ (NSString *)projectStringWithModel:(RecommendProjectModel *)amodel
{
    NSArray *projects = amodel.project_list;
    //体检项目
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:projects.count];
    for (NSDictionary *dic in amodel.project_list) {
        [temp addObject:dic[@"project_name"]];
    }
    NSString *projectString = [temp componentsJoinedByString:@"   "];
    return projectString;
}

+ (CGFloat)heightForCellWithModel:(RecommendProjectModel *)amodel
{
    
    NSString *content = [RecommendCell projectStringWithModel:amodel];
//    35 + 0.5 + 35 + 10 + 0.5 + 35 + 5
    CGFloat height = 121;
    
    CGFloat width = DEVICE_WIDTH - 105;

    CGFloat h_content = [LTools heightForText:content width:width font:14];
    
    h_content = h_content > 15 ? h_content : 15;
    
    height += h_content;
    
    return height + 5;
}

@end
