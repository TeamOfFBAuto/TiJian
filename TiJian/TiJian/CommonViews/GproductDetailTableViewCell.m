//
//  GproductDetailTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GproductDetailTableViewCell.h"
#import "GproductCommentView.h"
#import "GproductDetailViewController.h"
#import "CoupeView.h"
#import "ButtonProperty.h"
#import "CouponModel.h"
#import "ProductModel.h"

@implementation GproductDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(CGFloat)loadCustomViewWithModel:(ProductModel*)theModel index:(NSIndexPath*)theindexPath productCommentArray:(NSArray*)commentArr lookAgainArray:(NSArray *)theLookArray{
    self.productModel = theModel;
    //6个section
    //0     logo图 套餐名 描述 价钱
    //1     优惠券
    //2     主要参数
    //3     评价
    //4     看了又看
    //5     上拉显示体检项目详情
    
    CGFloat height = 0;
    
    if (theindexPath.section == 0) {//logo图 套餐名 描述 价钱
        if (theindexPath.row == 0) {
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/470])];
            
            
            [imv l_setImageWithURL:[NSURL URLWithString:self.productModel.cover_pic] placeholderImage:nil];
            [self.contentView addSubview:imv];
            height += imv.frame.size.height;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(imv.frame)+15, DEVICE_WIDTH - 20, 0)];
            titleLabel.font = [UIFont systemFontOfSize:13];
            titleLabel.text = self.productModel.setmeal_name;
            titleLabel.numberOfLines = 2;
            [titleLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(imv.frame)+15) width:DEVICE_WIDTH - 20];
            [self.contentView addSubview:titleLabel];
            height += titleLabel.frame.size.height+15;
            
            
            NSString *xianjia = self.productModel.setmeal_price;
            NSString *yuanjia = self.productModel.setmeal_original_price;
            
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+12, DEVICE_WIDTH - 20, 15)];
            NSString *price = [NSString stringWithFormat:@"￥%@ ￥%@",xianjia,yuanjia];
            NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, xianjia.length+1)];
            
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
            [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length+1)];
            priceLabel.attributedText = aaa;
            [self.contentView addSubview:priceLabel];
            height += priceLabel.frame.size.height+12;
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(priceLabel.frame)+15, DEVICE_WIDTH, 5)];
            line.backgroundColor = RGBCOLOR(244, 245, 246);
            [self.contentView addSubview:line];
            height +=15+line.frame.size.height;
            
            
        }
    }else if (theindexPath.section == 1){//优惠券
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/100])];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.text = @"优惠券";
        [self.contentView addSubview:tLabel];
        height += tLabel.frame.size.height;
        
        UIButton *getCouponBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [getCouponBtn setFrame:CGRectMake(DEVICE_WIDTH - 80, 0, 80, tLabel.frame.size.height)];
        getCouponBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [getCouponBtn setTitle:@"点击领取" forState:UIControlStateNormal];
        [getCouponBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [getCouponBtn addTarget:self action:@selector(clickToCoupe) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:getCouponBtn];
        
        
        
        
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tLabel.frame), DEVICE_WIDTH, 5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:line];
        height += line.frame.size.height;
        
    }else if (theindexPath.section == 2){//主要参数
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 15)];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.text = @"主要参数";
        [self.contentView addSubview:tLabel];
        height += tLabel.frame.size.height+10;
    
        
        UIView *cView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(tLabel.frame)+5, DEVICE_WIDTH-20, 50)];
        [self.contentView addSubview:cView];
        
        //品牌名称
        UILabel *brandNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cView.frame.size.width, 12)];
        brandNameLabel.font = [UIFont systemFontOfSize:12];
        brandNameLabel.textColor = [UIColor blackColor];
        brandNameLabel.text = [NSString stringWithFormat:@"品牌名称:  %@",self.productModel.brand_name];
        [cView addSubview:brandNameLabel];
        
        //适合人群
        UILabel *suitLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(brandNameLabel.frame)+5, cView.frame.size.width, 12)];
        suitLabel.font = [UIFont systemFontOfSize:12];
        suitLabel.textColor = [UIColor blackColor];
        NSArray *suit_infoArray = self.productModel.suit_info;
        NSString *suit_info_str = @"";
        for (NSDictionary *dic in suit_infoArray) {
            NSString *ss = [NSString stringWithFormat:@"%@  %@",suit_info_str,[dic stringValueForKey:@"suit_name"]];
            suit_info_str = ss;
        }
        suitLabel.text = [NSString stringWithFormat:@"适用人群:%@",suit_info_str];
        [cView addSubview:suitLabel];
        
        //体检项目
        UILabel *projectInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(suitLabel.frame)+5, cView.frame.size.width, 12)];
        projectInfoLabel.font = [UIFont systemFontOfSize:12];
        projectInfoLabel.textColor = [UIColor blackColor];
        NSArray *projectInfoArray = self.productModel.project_info;
        NSString *projectInfo_str = @"";
        for (NSDictionary *dic in projectInfoArray) {
            NSString *ss = [NSString stringWithFormat:@"%@  %@",projectInfo_str,[dic stringValueForKey:@"project_name"]];
            projectInfo_str = ss;
        }
        projectInfoLabel.text = [NSString stringWithFormat:@"体检项目:%@",projectInfo_str];
        [cView addSubview:projectInfoLabel];
        
        //适用地区
        UILabel *cityInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(projectInfoLabel.frame)+5, cView.frame.size.width, 12)];
        cityInfoLabel.font = [UIFont systemFontOfSize:12];
        cityInfoLabel.textColor = [UIColor blackColor];
        NSArray *cityInfoArray = self.productModel.city_info;
        NSString *cityInfo_str = @"";
        for (NSDictionary *dic in cityInfoArray) {
            NSString *ss = [NSString stringWithFormat:@"%@  %@",cityInfo_str,[dic stringValueForKey:@"city_name"]];
            cityInfo_str = ss;
        }
        cityInfoLabel.text = [NSString stringWithFormat:@"适用地区:%@",cityInfo_str];
        [cView addSubview:cityInfoLabel];
        
        
        
        [brandNameLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, 0) width:cView.frame.size.width];
        [suitLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, CGRectGetMaxY(brandNameLabel.frame)+5) width:cView.frame.size.width];
        [projectInfoLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, CGRectGetMaxY(suitLabel.frame)+5) width:cView.frame.size.width];
        [cityInfoLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, CGRectGetMaxY(projectInfoLabel.frame)+5) width:cView.frame.size.width];
        
        CGFloat hh = brandNameLabel.frame.size.height + 5 + suitLabel.frame.size.height + 5 + projectInfoLabel.frame.size.height + 5 + cityInfoLabel.frame.size.height;
        
        [cView setHeight:hh];
        
        height += cView.frame.size.height+5;
        
        
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(cView.frame)+10, DEVICE_WIDTH, 5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:line];
        height += line.frame.size.height+10;
        
    }else if (theindexPath.section == 3){//评价
        
        
        if (theindexPath.row == 0) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
            [self.contentView addSubview:view];
            UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 50, view.frame.size.height)];
            tLabel.font = [UIFont systemFontOfSize:14];
            tLabel.text = @"评价";
            [view addSubview:tLabel];
            
            
            if (commentArr.count>0) {
                UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [moreBtn setFrame:CGRectMake(view.frame.size.width-60, 0, 60, view.frame.size.height)];
                moreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
                [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [moreBtn addTarget:self action:@selector(goToCommentVc) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:moreBtn];
            }
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, view.frame.size.height - 0.5, view.frame.size.width, 0.5)];
            line.backgroundColor = RGBCOLOR(220, 221, 223);
            [view addSubview:line];
            
            height += [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80];
            
        }else{
            if (commentArr.count == 0) {//暂无评论
                UILabel *tt = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH, 30)];
                tt.text = @"暂无评论";
                tt.font = [UIFont systemFontOfSize:13];
                [self.contentView addSubview:tt];
                height = 30;
            }else{
                CGFloat h_y = 0;
                for (int i = 0; i<commentArr.count; i++) {
                    GproductCommentView *view = [[GproductCommentView alloc]initWithFrame:CGRectMake(0, h_y, DEVICE_WIDTH, 10)];
                    CGFloat hh = [view loadCustomViewWithModel:commentArr[i]];
                    [self.contentView addSubview:view];
                    height += hh;
                    h_y = hh;
                }
            }
        }
        
        
        
        
        
        
    }else if (theindexPath.section == 4){//看了又看
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 15)];
        tLabel.textColor = [UIColor blackColor];
        tLabel.text = @"看了又看";
        tLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:tLabel];
        height += tLabel.frame.size.height +10;
        
        
        CGFloat theW = (DEVICE_WIDTH - 20 - 10)/3;
        CGFloat theH = [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/265];
        NSInteger count = theLookArray.count;
        for (int i = 0; i<count; i++) {
            ProductModel *amodel = theLookArray[i];
            UIView *logoAndContentView = [[UIView alloc]initWithFrame:CGRectMake(10+i*(theW+5), CGRectGetMaxY(tLabel.frame)+10, theW, theH)];
            logoAndContentView.layer.borderWidth = 0.5;
            logoAndContentView.layer.borderColor = [RGBCOLOR(235, 236, 238)CGColor];
            [self.contentView addSubview:logoAndContentView];
            logoAndContentView.tag = [amodel.product_id integerValue];
            [logoAndContentView addTaget:self action:@selector(logoAndContentViewClicked:) tag:logoAndContentView.tag];
            
            
            
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, logoAndContentView.frame.size.width, [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/145])];
            imv.userInteractionEnabled = YES;
            [imv l_setImageWithURL:[NSURL URLWithString:self.productModel.cover_pic] placeholderImage:nil];
            [logoAndContentView addSubview:imv];
            
            UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(imv.frame)+5, theW-10, [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/60])];
            titleLable.text = amodel.setmeal_name;
            titleLable.numberOfLines = 2;
            titleLable.font = [UIFont systemFontOfSize:11];
            [logoAndContentView addSubview:titleLable];
            
            
            NSString *xianjia = amodel.setmeal_price;
            NSString *yuanjia = amodel.setmeal_original_price;
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(titleLable.frame)+5, DEVICE_WIDTH - 10, 12)];
            NSString *price = [NSString stringWithFormat:@"￥%@ ￥%@",xianjia,yuanjia];
            NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, xianjia.length+1)];
            
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
            [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length+1)];
            priceLabel.attributedText = aaa;
            [logoAndContentView addSubview:priceLabel];
            
            
        }
        
        height += theH +10;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tLabel.frame)+10+theH+10, DEVICE_WIDTH, 5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:line];
        height += line.frame.size.height+10;
        
        
        
    }else if (theindexPath.section == 5){//上拉显示体检项目详情
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
        tLabel.font = [UIFont systemFontOfSize:12];
        tLabel.textAlignment = NSTextAlignmentCenter;
        tLabel.text = @"上拉显示体检项目详情";
        [self.contentView addSubview:tLabel];
        height += tLabel.frame.size.height;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tLabel.frame), DEVICE_WIDTH, 5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:line];
        height += line.frame.size.height+10;
    }
    
    
    
    return height;
    
}



#pragma mark - 点击方法

//跳转评论界面
-(void)goToCommentVc{
    [self.delegate goToCommentVc];
}

//跳转单品详情页
-(void)logoAndContentViewClicked:(UIView*)sender{
    NSString *product_id = [NSString stringWithFormat:@"%ld",(long)sender.tag];
    [self.delegate goToProductDetailVcWithId:product_id];
}


/**
 *  点击去获取优惠劵
 */
- (void)clickToCoupe
{
    if (_coupeView) {
        [_coupeView removeFromSuperview];
        _coupeView = nil;
    }
    
    NSArray *arr = self.productModel.coupon_list;
    NSMutableArray *coupons = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in arr) {
        CouponModel *amodel = [[CouponModel alloc]initWithDictionary:dic];
        [coupons addObject:amodel];
    }
    
    _coupeView = [[CoupeView alloc]initWithCouponArray:coupons userStyle:USESTYLE_Get];
    
    __weak typeof(self)weakSelf = self;
    
    _coupeView.coupeBlock = ^(NSDictionary *params){
        
        ButtonProperty *btn = params[@"button"];
        CouponModel *aModel = params[@"model"];
        
        [weakSelf netWorkForCouponModel:aModel button:btn];
    };
    [_coupeView show];
}

/**
 *  领取优惠劵
 *
 *  @param aModel 优惠劵model
 *  @param sender
 */
- (void)netWorkForCouponModel:(CouponModel *)aModel
                       button:(UIButton *)sender
{
    //    __weak typeof(self)weakSelf = self;
    
//    if (![LTools isLogin:self]) {
//        
//        [_coupeView removeFromSuperview];
//        _coupeView = nil;
//        
//        return;
//    }
    
    
    YJYRequstManager *rr = [YJYRequstManager shareInstance];
    NSDictionary *dic = @{
                          @"coupon_id":aModel.coupon_id,
                          @"authcode":[GMAPI testAuth]
                          };
    
    [rr requestWithMethod:YJYRequstMethodPost api:USER_GETCOUPON parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result %@",result);
        aModel.enable_receive = @"0";
        sender.selected = YES;
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
}







@end
