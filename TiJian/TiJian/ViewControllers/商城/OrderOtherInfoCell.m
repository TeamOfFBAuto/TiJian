//
//  OrderOtherInfoCell.m
//  YiYiProject
//
//  Created by lichaowei on 15/9/12.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderOtherInfoCell.h"
#import "ShopModel.h"
#import "CouponModel.h"
#import "CoupeView.h"

@implementation CustomTextField



@end

@implementation OrderOtherInfoCell
{
    UILabel *minusLabel;//减多少
    UILabel *fullLabel;//满多少
    UIButton *couponBtn;//优惠劵
    CoupeView *_coupeView;//使用优惠劵界面
    ShopModel *_shopModel;
    UILabel *_label_coupon;//显示是否使用
    UIImageView *_jiantouImage;
}

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];

}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *footer = [self footerView];
        [self.contentView addSubview:footer];
    }
    return self;
}

- (UIView *)footerView
{
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 276/2.f)];
    footer.backgroundColor = [UIColor whiteColor];
    
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 55, 43) title:@"店铺优惠" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
    [footer addSubview:leftLabel];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    
    
    //显示优惠劵使用情况
    self.btn_quan = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btn_quan setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [_btn_quan setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateSelected];
    [_btn_quan setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_btn_quan.titleLabel setFont:[UIFont systemFontOfSize:13]];
    _btn_quan.frame = CGRectMake(leftLabel.right + 10, 0, 100, 43);
    [footer addSubview:_btn_quan];
    
    //箭头
    _jiantouImage = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 6, 0, 6, 11)];
    _jiantouImage.image = [UIImage imageNamed:@"qrdd_jiantou_small"];
    [footer addSubview:_jiantouImage];
    _jiantouImage.centerY = _btn_quan.centerY;
    
    //未使用优惠劵
    _label_coupon = [[UILabel alloc]initWithFrame:CGRectMake(_jiantouImage.left - 10 - 40, _btn_quan.top, 40, 43) title:@"未使用" font:13 align:NSTextAlignmentRight textColor:[UIColor colorWithHexString:@"333333"]];
    [footer addSubview:_label_coupon];
    
    //优惠券
    CGFloat aWidth = [LTools fitWidth:85];
    couponBtn = [self couponViewFrame:CGRectMake(DEVICE_WIDTH - 10 - aWidth, 0, aWidth, 28)];
    [footer addSubview:couponBtn];
    couponBtn.centerY = _btn_quan.centerY;
    
    //分割线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _btn_quan.bottom, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [footer addSubview:line];
    
    //备注
    self.tf = [[CustomTextField alloc]initWithFrame:CGRectMake(10, line.bottom + 9, DEVICE_WIDTH - 20, 35)];
    [_tf addCornerRadius:3.f];
    _tf.placeholder = @"选填:建议填写您和商家达成一致的特殊要求";
    _tf.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    _tf.font = [UIFont systemFontOfSize:12];
    _tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tf.delegate = self;
    [footer addSubview:_tf];

    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 35)];
    _tf.leftView = leftView;
    _tf.leftViewMode = UITextFieldViewModeAlways;
    _tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    //分割线
    line = [[UIView alloc]initWithFrame:CGRectMake(0, _tf.bottom + 9, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [footer addSubview:line];
    
    //件数和总价格
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(10, line.bottom, DEVICE_WIDTH - 20, 40)];
    [footer addSubview:_label];
    _label.font = [UIFont systemFontOfSize:13];
    _label.textColor = [UIColor colorWithHexString:@"646464"];
    _label.textAlignment = NSTextAlignmentRight;
    
    //分割线
    line = [[UIView alloc]initWithFrame:CGRectMake(0, _label.bottom, DEVICE_WIDTH, 5)];
    line.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    [footer addSubview:line];
    
    return footer;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)clickToSelectCoupon
{
    if (_coupeView) {
        [_coupeView removeFromSuperview];
        _coupeView = nil;
    }
    
    _coupeView = [[CoupeView alloc]initWithCouponArray:_shopModel.couponsArray userStyle:USESTYLE_Use];
    
    __weak typeof(self)weakSelf = self;
    
    _coupeView.coupeBlock = ^(NSDictionary *params){
        
//        ButtonProperty *btn = params[@"button"];
        CouponModel *aModel = params[@"model"];
        [weakSelf updateCouponWithModel:aModel];
    };
    [_coupeView show];
}

//更新优惠劵信息 包括界面显示和shopModel的属性
- (void)updateCouponWithModel:(CouponModel *)aModel
{
    [self updateCouponViewDateWithModel:aModel];
    _shopModel.couponModel = aModel;
    [self setCellWithModel:_shopModel];
    
    //更改优惠劵了
    if (self.updateCouponBlock) {
        _updateCouponBlock(aModel);
    }
    
}
-(void)setUpdateCouponBlock:(UPDATECOUPONBLOCK)updateCouponBlock
{
    _updateCouponBlock = updateCouponBlock;
}

/**
 *  优惠劵
 *
 *  @return
 */
- (UIButton *)couponViewFrame:(CGRect)frame
{
    UIButton *btn = [[UIButton alloc]initWithframe:frame buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil nornalImage:nil selectedImage:nil target:self action:nil];
    CGFloat aHeight = btn.height / 2.f - 5;
    minusLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, btn.width - 10, aHeight) title:nil font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:minusLabel];
    minusLabel.font = [UIFont boldSystemFontOfSize:8];
    
    fullLabel = [[UILabel alloc]initWithFrame:CGRectMake(minusLabel.left, minusLabel.bottom, minusLabel.width, aHeight) title:nil font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:fullLabel];
    return btn;
}

/**
 *  更新优惠劵显示内容
 *
 *  @param aModel
 */
- (void)updateCouponViewDateWithModel:(CouponModel *)aModel
{
    if (aModel == nil) {
        
        [couponBtn setImage:nil forState:UIControlStateNormal];
        minusLabel.text = @"";
        fullLabel.text = @"";
        return;
    }
    
    int type = [aModel.type intValue];
    
    NSString *title_minus;
    NSString *title_full;
    //满减
    if (type == 1) {
        
        title_minus = [NSString stringWithFormat:@"￥%@",aModel.minus_money];
        title_full = [NSString stringWithFormat:@"满%@即可使用",aModel.full_money];
    }
    //折扣
    else if (type == 2){
        
        NSString *discount = [NSString stringWithFormat:@"%.1f",[aModel.discount_num floatValue] * 10];
        discount = [NSString stringWithFormat:@"%@",[discount stringByRemoveTrailZero]];
        title_minus = @"优惠券";
        title_full = [NSString stringWithFormat:@"本店享%@折优惠",discount];
    }
    minusLabel.text = title_minus;
    fullLabel.text = title_full;
    
    UIImage *aImage = [LTools imageForCoupeColorId:aModel.color];
    [couponBtn setImage:aImage forState:UIControlStateNormal];
}

- (void)setCellWithModel:(ShopModel *)shopModel
{
    _shopModel = shopModel;
    
    //优惠券使用情况
    
    NSString *title;
    
    //为真时代表已选择优惠劵
    if (shopModel.couponModel) {
        
        title = @"已使用";
        
        if (!shopModel.onlyShow) {
            [couponBtn addTarget:self action:@selector(clickToSelectCoupon) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }else
    {
        int count = (int)shopModel.couponsArray.count;
        if (count) {
            title = [NSString stringWithFormat:@"有%d张优惠券可用",count];
            
            if (!shopModel.onlyShow) {
                [couponBtn addTarget:self action:@selector(clickToSelectCoupon) forControlEvents:UIControlEventTouchUpInside];
            }
            
        }else
        {
            if (shopModel.onlyShow) {
                
                title = @"无";
            }else
            {
                title = @"暂无优惠";
                [couponBtn removeTarget:self action:@selector(clickToSelectCoupon) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    //只是展示
    if (shopModel.onlyShow) {
        
        _label_coupon.hidden = YES;
        _jiantouImage.hidden = YES;
        _tf.enabled = NO;
    }
    
    [_btn_quan setTitle:title forState:UIControlStateNormal];
    
    [self updateCouponViewDateWithModel:shopModel.couponModel];
    
    NSString *text1 = [NSString stringWithFormat:@"共%@件商品",shopModel.productNum];
    NSString *text2 = @"合计:";
    NSString *text3 = [NSString stringWithFormat:@"￥%.2f",[shopModel.total_price floatValue]];
    
    NSString *text_sum = [NSString stringWithFormat:@"%@ %@ %@",text1,text2,text3];
    NSAttributedString *temp = [[NSAttributedString alloc]initWithString:text_sum];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithAttributedString:temp];
    //        NSRange range1 = [text_sum rangeOfString:text1];
    NSRange range2 = [text_sum rangeOfString:text2];
    NSRange range3 = [text_sum rangeOfString:text3];
    
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"323232"] range:range2];
    [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:range2];
    [attString addAttribute:NSForegroundColorAttributeName value:DEFAULT_TEXTCOLOR range:range3];
    
    [_label setAttributedText:attString];
    
    //备注显示
    
    NSString *note = shopModel.note;
    if (note) {
        self.tf.text = note;
    }else
    {
        self.tf.text = @"";
    }
}

#pragma - mark UITextFieldDelegate <NSObject>

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //开始编辑
    if (self.updateCouponBlock) {
        _updateCouponBlock(textField);
    }
}
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    
//}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _shopModel.note = textField.text;
    
    return YES;
}

@end
