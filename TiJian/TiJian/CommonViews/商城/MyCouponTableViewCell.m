//
//  MyCouponTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MyCouponTableViewCell.h"
#import "MyCouponViewController.h"
#import "CouponModel.h"
#import "MyCouponViewController.h"

@implementation MyCouponTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


//初始化
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSIndexPath*)theIndex type:(GCouponType)theType{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat height = 70;//单元格高度
        
        //选择按钮
        self.chooseBtn = [Gbtn buttonWithType:UIButtonTypeCustom];
        [self.chooseBtn setImage:[UIImage imageNamed:@"xuanzhong_no.png"] forState:UIControlStateNormal];
        [self.chooseBtn setImage:[UIImage imageNamed:@"xuanzhong.png"] forState:UIControlStateSelected];
        CGFloat wAndH = 35;//选择按钮的宽高
        if (theType == GCouponType_youhuiquan ||  theType == GCouponType_daijinquan || theType == GCouponType_disUse_youhuiquan || theType == GCouponType_disUse_daijinquan) {//查看
            [self.chooseBtn setFrame:CGRectZero];
        }else if (theType == GCouponType_use_daijinquan || theType == GCouponType_use_youhuiquan){//使用
            [self.chooseBtn setFrame:CGRectMake(5, height * 0.5 - wAndH * 0.5, wAndH, wAndH)];
        }
        
        self.chooseBtn.theIndex = theIndex;
        [self.chooseBtn addTarget:self action:@selector(chooseBtnClickedWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.chooseBtn];

        
        
        
        if (theType == GCouponType_youhuiquan || theType == GCouponType_use_youhuiquan || theType == GCouponType_disUse_youhuiquan) {
            UIImageView *logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.chooseBtn.frame)+5, 10, 50, 50)];
            
            //logo图
            if (theType == GCouponType_youhuiquan ||  theType == GCouponType_daijinquan) {//查看
                [logoImv setFrame:CGRectMake(CGRectGetMaxX(self.chooseBtn.frame)+5, 10, 50, 50)];
            }
            
            [self.contentView addSubview:logoImv];
            self.iconImageView = logoImv;
            
            
            //文字描述
            self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(logoImv.frame)+10, logoImv.frame.origin.y, DEVICE_WIDTH - 5 - self.chooseBtn.frame.size.width - 10 - logoImv.frame.size.width - 5 - 105, logoImv.frame.size.height*0.5)];
            
            if (theType == GCouponType_youhuiquan ||  theType == GCouponType_daijinquan) {//查看
                [self.contentLabel setFrame:CGRectMake(CGRectGetMaxX(logoImv.frame)+10, logoImv.frame.origin.y, DEVICE_WIDTH - 5 - self.chooseBtn.frame.size.width - 10 - logoImv.frame.size.width - 5 - 105, logoImv.frame.size.height*0.5)];
            }
            
            
            self.contentLabel.font = [UIFont systemFontOfSize:12];
            self.contentLabel.numberOfLines = 2;
            self.contentLabel.textColor = RGBCOLOR(38, 38, 39);
            [self.contentView addSubview:self.contentLabel];
            
            //使用期限
            self.useTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.contentLabel.frame.origin.x, CGRectGetMaxY(self.contentLabel.frame), self.contentLabel.frame.size.width, self.contentLabel.frame.size.height)];
            self.useTimeLabel.textColor = RGBCOLOR(81, 82, 83);
            self.useTimeLabel.numberOfLines = 2;
            self.useTimeLabel.font = [UIFont systemFontOfSize:10];
            [self.contentView addSubview:self.useTimeLabel];
            
            //优惠券图
            self.couponImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 105, 15, 100, 40)];
            [self.contentView addSubview:self.couponImv];
            
            
            self.disable_use_imv = [[UIImageView alloc]initWithFrame:CGRectMake(self.couponImv.frame.size.width*0.5-self.couponImv.frame.size.height*0.5, 0, self.couponImv.frame.size.height, self.couponImv.frame.size.height)];
            [self.couponImv addSubview:self.disable_use_imv];
            self.disable_use_imv.hidden = YES;
            
            
        }else if (theType == GCouponType_daijinquan || theType == GCouponType_use_daijinquan || theType == GCouponType_disUse_daijinquan){
            
            self.companyLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.chooseBtn.frame)+10, 10, DEVICE_WIDTH *(200/750.0), 50)];
            if (theType == GCouponType_daijinquan) {
                [self.companyLabel  setFrame:CGRectMake(CGRectGetMaxX(self.chooseBtn.frame)+10, 10, DEVICE_WIDTH *(280/750.0), 50)];
            }
            self.companyLabel .font = [UIFont systemFontOfSize:13];
            self.companyLabel.textAlignment = NSTextAlignmentCenter;
            self.companyLabel .numberOfLines = 3;
            [self.contentView addSubview:self.companyLabel ];
            
            //代金券图
            self.daijiquanImv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.companyLabel .frame)+10, 8, DEVICE_WIDTH - CGRectGetMaxX(self.companyLabel .frame) - 20, 70-16)];
            self.daijiquanImv.image = [UIImage imageNamed:@"yuyue_daijinquan.png"];
            [self.contentView addSubview:self.daijiquanImv];
            
            self.daijinquan_priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, self.daijiquanImv.frame.size.width*210/540.0-5, self.daijiquanImv.frame.size.height*0.5)];
            self.daijinquan_priceLabel.font = [UIFont systemFontOfSize:12];
            self.daijinquan_priceLabel.textAlignment = NSTextAlignmentRight;
            self.daijinquan_priceLabel.textColor = RGBCOLOR(91, 146, 199);
            [self.daijiquanImv addSubview:self.daijinquan_priceLabel];
            
            self.miaoshuLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(self.daijinquan_priceLabel.frame), self.daijinquan_priceLabel.frame.size.width, self.daijinquan_priceLabel.frame.size.height)];
            self.miaoshuLabel.font = [UIFont systemFontOfSize:11];
            self.miaoshuLabel.text = @"超额补差价";
            self.miaoshuLabel.textAlignment = NSTextAlignmentRight;
            self.miaoshuLabel.textColor = RGBCOLOR(134, 135, 136);
            [self.daijiquanImv addSubview:self.miaoshuLabel];
            
            
            self.daijinquan_brandNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.daijinquan_priceLabel.right, self.daijinquan_priceLabel.frame.origin.y, self.daijiquanImv.frame.size.width - self.daijinquan_priceLabel.frame.size.width, self.daijiquanImv.frame.size.height*0.5)];
            self.daijinquan_brandNameLabel.textAlignment = NSTextAlignmentCenter;
            self.daijinquan_brandNameLabel.font = [UIFont systemFontOfSize:12];
            self.daijinquan_brandNameLabel.textColor = RGBCOLOR(91, 146, 199);
            [self.daijiquanImv addSubview:self.daijinquan_brandNameLabel];
            
            self.daijinquan_timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.daijinquan_brandNameLabel.frame.origin.x, CGRectGetMaxY(self.daijinquan_brandNameLabel.frame), self.daijinquan_brandNameLabel.frame.size.width, self.daijinquan_brandNameLabel.frame.size.height)];
            self.daijinquan_timeLabel.textAlignment = NSTextAlignmentCenter;
            self.daijinquan_timeLabel.font = [UIFont systemFontOfSize:11];
            self.daijinquan_timeLabel.textColor = RGBCOLOR(91, 146, 199);
            [self.daijiquanImv addSubview:self.daijinquan_timeLabel];
            
            
            
            self.disable_use_imv = [[UIImageView alloc]initWithFrame:CGRectMake(self.daijiquanImv.frame.size.width*0.5-self.daijiquanImv.frame.size.height*0.5, 0, self.daijiquanImv.frame.size.height, self.daijiquanImv.frame.size.height)];
            [self.daijiquanImv addSubview:self.disable_use_imv];
            self.disable_use_imv.hidden = YES;
            
            
        }
        
        
        
        
        
        
        
    }
    
    return self;
}


#pragma mark - 赋值
-(void)loadDataWithModel:(CouponModel*)theModel type:(GCouponType)theType{
    
    self.chooseBtn.selected = theModel.isUsed;
    
    
    //控制选中按钮
    if (theType == GCouponType_use_youhuiquan) {
        for (CouponModel *model in self.delegate.userChooseYouhuiquanArray) {
            NSLog(@"%@",model.coupon_id);
            if (model.coupon_id == theModel.coupon_id) {
                theModel.isUsed = YES;
                self.chooseBtn.selected = YES;
            }
        }
    }else if (theType == GCouponType_use_daijinquan){
        for (CouponModel *model in self.delegate.userChooseDaijinquanArray) {
            NSLog(@"%@",model.coupon_id);
            if (model.coupon_id == theModel.coupon_id) {
                theModel.isUsed = YES;
                self.chooseBtn.selected = YES;
            }
        }
    }
    
    
    
    
    if (theType == GCouponType_youhuiquan || theType == GCouponType_use_youhuiquan || theType == GCouponType_disUse_youhuiquan) {
        [self.iconImageView l_setImageWithURL:[NSURL URLWithString:theModel.cover_pic] placeholderImage:nil];
        
        self.contentLabel.text = theModel.brand_name;
        NSString *a = [GMAPI timechangeYMD:theModel.use_start_time];
        NSString *b = [GMAPI timechangeMD:theModel.use_end_time];
        self.useTimeLabel.text = [NSString stringWithFormat:@"使用期限:%@-%@",a,b];
        
        UIImage *aImage = [LTools imageForCoupeColorId:theModel.color];
        [self.couponImv setImage:aImage];
        
        int type = [theModel.type intValue];
        
        NSString *title_minus;
        NSString *title_full;
        NSString *title;
        //满减
        if (type == 1) {
            
            title_minus = [NSString stringWithFormat:@"￥%@",theModel.minus_money];
            title_full = [NSString stringWithFormat:@"满%@即可使用",theModel.full_money];
            title = [NSString stringWithFormat:@"满%@减%@",theModel.full_money,theModel.minus_money];
        }else if (type == 2){//折扣
            
            NSString *discount = [NSString stringWithFormat:@"%.1f",[theModel.discount_num floatValue] * 10];
            discount = [NSString stringWithFormat:@"%@",[discount stringByRemoveTrailZero]];
            title_minus = @"优惠券";
            title_full = [NSString stringWithFormat:@"本店享%@折优惠",discount];
            title = [NSString stringWithFormat:@"%@折",discount];
        }
        
        //优惠标题
        UILabel *label = [[UILabel alloc]initWithFrame:self.couponImv.bounds];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:11];
        [self.couponImv addSubview:label];
        
        
        if (theModel.enable_use == 0){//不可用
            if (theModel.disable_use_reason == 1) {//已经使用
                [self.disable_use_imv setImage:[UIImage imageNamed:@"youhuiquan_yishiyong.png"]];
            }else if (theModel.disable_use_reason == 2){//已过期
                [self.disable_use_imv setImage:[UIImage imageNamed:@"youhuiquan_yiguoqi.png"]];
            }
            
            self.disable_use_imv.hidden = NO;
            
            [self.couponImv setImage:[UIImage imageNamed:@"youhuiquan_g.png"]];
            
        }else if (theModel.enable_use == 1){//可用
            self.disable_use_imv.hidden = YES;
        }
        
        
        
        
        
    }else if (theType == GCouponType_daijinquan || theType == GCouponType_use_daijinquan || theType == GCouponType_disUse_daijinquan){
        self.companyLabel.text = theModel.company_name;
        self.daijinquan_priceLabel.text = [NSString stringWithFormat:@"%@元",theModel.vouchers_price];
        self.daijinquan_brandNameLabel.text = theModel.brand_name;
        NSString *start_time = [GMAPI timechangeYMD:theModel.use_start_time];
        NSString *end_time = [GMAPI timechangeMD:theModel.use_end_time];
        self.daijinquan_timeLabel.text = [NSString stringWithFormat:@"%@-%@",start_time,end_time];
        
        
        if (theModel.enable_use == 0){//不可用
            
            if (theModel.disable_use_reason == 1) {//已经使用
                [self.disable_use_imv setImage:[UIImage imageNamed:@"youhuiquan_yishiyong.png"]];
            }else if (theModel.disable_use_reason == 2){//已过期
                [self.disable_use_imv setImage:[UIImage imageNamed:@"youhuiquan_yiguoqi.png"]];
            }
            
            self.disable_use_imv.hidden = NO;
            
            [self.daijiquanImv setImage:[UIImage imageNamed:@"daijinquan_bukeyong.png"]];
            
            self.miaoshuLabel.textColor = RGBCOLOR(204, 204, 204);
            self.daijinquan_brandNameLabel.textColor = RGBCOLOR(204, 204, 204);
            self.daijinquan_priceLabel.textColor = RGBCOLOR(204, 204, 204);
            self.daijinquan_timeLabel.textColor = RGBCOLOR(204, 204, 204);
            
            
        }else if (theModel.enable_use == 1){//可用
            self.disable_use_imv.hidden = YES;
            self.daijiquanImv.image = [UIImage imageNamed:@"yuyue_daijinquan.png"];
            self.miaoshuLabel.textColor = RGBCOLOR(134, 135, 136);
            self.daijinquan_brandNameLabel.textColor = RGBCOLOR(91, 146, 199);
            self.daijinquan_priceLabel.textColor = RGBCOLOR(91, 146, 199);
            self.daijinquan_timeLabel.textColor = RGBCOLOR(91, 146, 199);
        }
        
        
        
    }

    
    
    
    
    
    
    
}


#pragma mark - 点击方法
//选中按钮点击
-(void)chooseBtnClickedWithIndex:(Gbtn*)sender{
    
    self.chooseBtn.selected = !self.chooseBtn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellSelectBtnClickedWithIndex:select:)]) {
        [self.delegate cellSelectBtnClickedWithIndex:sender.theIndex select:sender.selected];
    }
    
    
    
//    NSArray *arr = self.delegate.rTab.dataArray[self.theIndexPath.section];
//    ProductModel *model = arr[self.theIndexPath.row];
//    model.userChoose = !model.userChoose;
//    self.chooseBtn.selected = model.userChoose;
//    
//    [self.delegate isAllChooseAndUpdateState];
//    [self.delegate updateRtabTotolPrice];
}

@end
