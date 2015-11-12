//
//  CompanyCell.m
//  TiJian
//
//  Created by lichaowei on 15/11/11.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "CompanyCell.h"

//延展
@interface CompanyCell ()

@property(nonatomic,retain)UILabel *comanyNameLabel;//公司名字
@property(nonatomic,retain)UILabel *userNameLabel;//体检人name
@property(nonatomic,retain)UIImageView *iconImageView;//套餐图
@property(nonatomic,retain)UILabel *productNameLabel;//套餐name
@property(nonatomic,retain)UILabel *priceLabel;//套餐价格

@end

@implementation CompanyCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
              companyPreType:(COMPANYPRETYPE)preType
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
        CGFloat left = 15.f;
        
        //==========公司信息部分=======
        UIView *companyBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 75)];
        companyBgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:companyBgView];
        //图标
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(left, 9, 12, 12)];
        icon.image = [UIImage imageNamed:@"fenyuan"];
        [companyBgView addSubview:icon];
        //公司title
        UILabel *companyTitle = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 5, 0, 100, 30) title:@"公司名称" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
        [companyBgView addSubview:companyTitle];
        //线
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(12, companyTitle.bottom, companyBgView.width - 12 * 2, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [companyBgView addSubview:line];
        //公司名字
        self.comanyNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(icon.left, line.bottom, companyBgView.width - left * 2, companyBgView.height - 30) title:@"控股集团" font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
        [companyBgView addSubview:_comanyNameLabel];
        
        //==========体检人信息部分=======
        UIView *userBgView = [[UIView alloc]initWithFrame:CGRectMake(0, companyBgView.bottom + 5, DEVICE_WIDTH, 75)];
        userBgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:userBgView];
        //图标
        icon = [[UIImageView alloc]initWithFrame:CGRectMake(left, 9, 12, 12)];
        icon.image = [UIImage imageNamed:@"tijianren"];
        [userBgView addSubview:icon];
        //公司title
        companyTitle = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 5, 0, 100, 30) title:@"体检人信息" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
        [userBgView addSubview:companyTitle];
        //线
        line = [[UIView alloc]initWithFrame:CGRectMake(12, companyTitle.bottom, userBgView.width - 12 * 2, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [userBgView addSubview:line];
        //公司名字
        self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(icon.left, line.bottom, companyBgView.width - left * 2, companyBgView.height - 30) title:@"张木木   女   45岁   3222********2233" font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
        [userBgView addSubview:_userNameLabel];
        
        //==========公司套餐或者代金券部分=======
        userBgView = [[UIView alloc]initWithFrame:CGRectMake(0, userBgView.bottom + 5, DEVICE_WIDTH, 150)];
        userBgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:userBgView];
        //图标
        icon = [[UIImageView alloc]initWithFrame:CGRectMake(left, 9, 12, 12)];
        icon.image = [UIImage imageNamed:@"gouwudai"];
        [userBgView addSubview:icon];
        //title
        companyTitle = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 5, 0, 100, 30) title:@"公司已买单" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
        [userBgView addSubview:companyTitle];
        //线
        line = [[UIView alloc]initWithFrame:CGRectMake(12, companyTitle.bottom, userBgView.width - 12 * 2, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [userBgView addSubview:line];
        
        CGFloat top = line.bottom;
        //套餐部分
        if (preType == COMPANYPRETYPE_TAOCAN) {
            
            UIView *tc_bgView = [[UIView alloc]initWithFrame:CGRectMake(0, line.bottom, DEVICE_WIDTH, 75)];
            tc_bgView.backgroundColor = [UIColor whiteColor];
            [userBgView addSubview:tc_bgView];
            
            //套餐图
            self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, (75 - 50)/2.f, 80, 50)];
            _iconImageView.backgroundColor = DEFAULT_TEXTCOLOR;
            [tc_bgView addSubview:_iconImageView];
            //套餐name
            self.productNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_iconImageView.right + 8, 14, tc_bgView.width - _iconImageView.right - 8 - left, 30) title:@"爱康国宾粉红真爱体检套餐全国通用爱康国宾粉红真爱体检套餐全国通用" font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
            [tc_bgView addSubview:_productNameLabel];
            _productNameLabel.numberOfLines = 2;
            _productNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
            //价格
            self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(_productNameLabel.left, _productNameLabel.bottom + 5, 150, 12) title:nil font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"eb7d24"]];
            _priceLabel.text = @"￥899.00";
            [tc_bgView addSubview:_priceLabel];
            
            //线
            line = [[UIView alloc]initWithFrame:CGRectMake(12, tc_bgView.height - 0.5, userBgView.width - 12 * 2, 0.5)];
            line.backgroundColor = DEFAULT_LINECOLOR;
            [tc_bgView addSubview:line];
            
            top = tc_bgView.bottom;
        }
        //代金券
        else if (preType == COMPANYPRETYPE_MONEY){
            
            
        }
        
        //==========选择体检分院时间、去预约=======
        UIView *selectView = [[UIView alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, 45)];
        selectView.backgroundColor = [UIColor whiteColor];
        [userBgView addSubview:selectView];
        //图标
        icon = [[UIImageView alloc]initWithFrame:CGRectMake(left, (45-12)/2.f, 12, 12)];
        icon.image = preType == COMPANYPRETYPE_MONEY ? [UIImage imageNamed:@"dingzhi"] : [UIImage imageNamed:@"fenyuan"];
        [selectView addSubview:icon];
        //title
        companyTitle = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 5, 0, 120, 45) title:nil font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
        [selectView addSubview:companyTitle];
        companyTitle.text = preType == COMPANYPRETYPE_MONEY ? @"去预约" : @"选择体检时间、分院";
        //线
        line = [[UIView alloc]initWithFrame:CGRectMake(12, companyTitle.bottom-0.5, userBgView.width - 12 * 2, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [selectView addSubview:line];
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(userBgView.width - 6 - 20, (45-12)/2.f, 6, 12)];
        arrow.image = [UIImage imageNamed:@"jiantou"];
        [selectView addSubview:arrow];
        

        
    }
    return self;
}

@end
