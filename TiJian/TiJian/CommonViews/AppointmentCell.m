//
//  AppointmentCell.m
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AppointmentCell.h"
#import "ProductModel.h"

@interface AppointmentCell ()

@property(nonatomic,retain)UIImageView *brandIcon;//品牌logo
@property(nonatomic,retain)UILabel *brandName;//品牌name
@property(nonatomic,retain)UIImageView *iconImageView;//套餐图
@property(nonatomic,retain)UILabel *productNameLabel;//套餐name
@property(nonatomic,retain)UILabel *priceLabel;//套餐价格
@property(nonatomic,retain)UILabel *timeLabel;//时间label
@property(nonatomic,retain)UILabel *typeLabel;//用途label

@end

@implementation AppointmentCell

/**
 *  获取cell高度
 *
 *  @param type 1 公司购买套餐 2 公司代金券 3 普通套餐
 *
 *  @return
 */
+ (CGFloat)heightForCellWithType:(int)type
{
    if (type == 2) {
        return 130 + 5;
    }
    return 75 + 5;
}

/**
 *  cell初始化
 *
 *  @param style
 *  @param reuseIdentifier
 *  @param type            1 公司购买套餐 2 公司代金券 3 普通套餐
 *
 *  @return
 */
-(instancetype)initWithStyle:(UITableViewCellStyle)style
             reuseIdentifier:(NSString *)reuseIdentifier
                        type:(int)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (type == 2) {
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 130)];
            view.backgroundColor = [UIColor whiteColor];
            [self.contentView addSubview:view];
            
            CGFloat width = 273.f;
            CGFloat height = 71.f;
            CGFloat left = (DEVICE_WIDTH - width) / 2.f;
            //背景图
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, 10, width, height)];
            imageView.backgroundColor = [UIColor whiteColor];
            imageView.image = [UIImage imageNamed:@"yuyue_daijinquan"];
            [view addSubview:imageView];
//            [imageView setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
            
            //================代金卷相关
            
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 107, 16) title:@"1000元" font:15 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
            [imageView addSubview:priceLabel];
            self.priceLabel = priceLabel;
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, priceLabel.bottom + 5, priceLabel.width, 13) title:@"【超额补差价】" font:12 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
            [imageView addSubview:label];
            
            
            UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(priceLabel.right, 20, imageView.width - priceLabel.width, 16) title:@"全场通用" font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR];
            [imageView addSubview:typeLabel];
            self.typeLabel = typeLabel;
            
            UILabel *timelabel = [[UILabel alloc]initWithFrame:CGRectMake(typeLabel.left, typeLabel.bottom + 5, typeLabel.width, 13) title:@"2015.09.20-2015.10.20" font:10 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR];
            [imageView addSubview:timelabel];
            self.timeLabel = timelabel;
            
            //================
            //线
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, imageView.bottom + 10, DEVICE_WIDTH, 0.5)];
            line.backgroundColor = DEFAULT_LINECOLOR;
            [view addSubview:line];
            //两个按钮
            for (int i = 0; i < 2; i ++) {
                PropertyButton *btn = [PropertyButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(DEVICE_WIDTH/2.f * i, imageView.bottom + 10,DEVICE_WIDTH/2.f ,130 - imageView.bottom - 10);
                btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
                [view addSubview:btn];
                if (i == 0) {
                    [btn setTitle:@"前去购买套餐" forState:UIControlStateNormal];
                    [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
                    self.buyButton = btn;
                    //线
                    line = [[UIView alloc]initWithFrame:CGRectMake(btn.right - 0.5, btn.top, 0.5, btn.height)];
                    line.backgroundColor = DEFAULT_LINECOLOR;
                    [view addSubview:line];
                }else
                {
                    [btn setTitle:@"定制专属套餐" forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor colorWithHexString:@"f98425"] forState:UIControlStateNormal];
                    self.customButton = btn;
                }
            }
            
            
        }else
        {
            CGFloat left = 10.f;
            //===========套餐相关
            UIView *tc_bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 75)];
            tc_bgView.backgroundColor = [UIColor whiteColor];
            [self.contentView addSubview:tc_bgView];
            
            //套餐图
            self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, (75 - 50)/2.f, 80, 50)];
            [tc_bgView addSubview:_iconImageView];
            //套餐name
            self.productNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_iconImageView.right + 8, 14, tc_bgView.width - _iconImageView.right - 8 - left - 80, 30) title:@"爱康国宾粉红真爱体检套餐全国通用爱康国宾粉红真爱体检套餐全国通用" font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
            [tc_bgView addSubview:_productNameLabel];
            _productNameLabel.numberOfLines = 2;
            _productNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
            //价格
            self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(_productNameLabel.left, _productNameLabel.bottom + 5, 150, 12) title:nil font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"eb7d24"]];
            _priceLabel.text = @"剩 1 份";
            [tc_bgView addSubview:_priceLabel];
            //前去预约
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"前去预约" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.frame = CGRectMake(DEVICE_WIDTH - left - 10 - 50, 0, 50, tc_bgView.height);
            [btn setTitleColor:DEFAULT_TEXTCOLOR_TITLE_THIRD forState:UIControlStateNormal];
            [tc_bgView addSubview:btn];
            btn.userInteractionEnabled = NO;
            //箭头 6 12
            UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - left - 6, 0, 6, tc_bgView.height)];
            arrow.image = [UIImage imageNamed:@"jiantou"];
            arrow.contentMode = UIViewContentModeCenter;
            [tc_bgView addSubview:arrow];
        }
    }
    return self;
}

-(void)setCellWithModel:(ProductModel *)aModel
{
    if ([aModel.type intValue] == 2) { //代金卷
        self.priceLabel.text = [NSString stringWithFormat:@"%d元",[aModel.vouchers_price intValue]];
        self.typeLabel.text = [aModel.brand_id intValue] > 0 ? aModel.brand_name : @"全场通用";
        self.timeLabel.text = [NSString stringWithFormat:@"%@-%@",[LTools timeString:aModel.add_time withFormat:@"YYYY.MM.dd"],[LTools timeString:aModel.deadline withFormat:@"YYYY.MM.dd"]];
        return;
    }
    
    [self.iconImageView l_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
    self.productNameLabel.text = aModel.product_name;
    NSString *text = [aModel.appointed_num intValue] > 0 ? @"剩" : @"共";
    if ([aModel.type intValue] == 1) {
        aModel.no_appointed_num = @"1";
    }
    NSString *priceString = [NSString stringWithFormat:@"￥%.2f",[aModel.product_price floatValue]];
    NSString *noAppoint = [NSString stringWithFormat:@"%@%d份",text,[aModel.no_appointed_num intValue]];
    
    NSString *sumString = [NSString stringWithFormat:@"%@   %@",priceString,noAppoint];
    self.priceLabel.textColor = [UIColor colorWithHexString:@"f98e40"];
    [self.priceLabel setAttributedText:[LTools attributedString:sumString keyword:noAppoint color:[UIColor colorWithHexString:@"f98e40"] keywordFontSize:12]];
}

@end
