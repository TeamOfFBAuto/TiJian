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


-(CGFloat)loadCustomViewWithIndex:(NSIndexPath*)theindexPath productCommentArray:(NSArray*)commentArr lookAgainArray:(NSArray *)theLookArray{
    
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
            
            __weak typeof (self)bself = self;
            [imv l_setImageWithURL:[NSURL URLWithString:self.delegate.theProductModel.cover_pic] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (bself.delegate) {
                    bself.delegate.gouwucheProductImage = image;
                }
                
            }];
            [self.contentView addSubview:imv];
            height += imv.frame.size.height;
            
            
            //商品名
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(imv.frame)+15, DEVICE_WIDTH - 20, 0)];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.text = [NSString stringWithFormat:@"%@ %@",[LTools isEmpty:self.delegate.theProductModel.brand_name]?@"":self.delegate.theProductModel.brand_name,[LTools isEmpty:self.delegate.theProductModel.setmeal_name]?@"":self.delegate.theProductModel.setmeal_name];
            [titleLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(imv.frame)+15) width:DEVICE_WIDTH - 20];
            [self.contentView addSubview:titleLabel];
            height += titleLabel.frame.size.height+15;
            
            //商品描述
            UILabel *setmeal_descLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+10, DEVICE_WIDTH - 20, 0)];
            setmeal_descLabel.font = [UIFont systemFontOfSize:12];
            setmeal_descLabel.textColor = RGBCOLOR(220, 103, 21);
            setmeal_descLabel.text = self.delegate.theProductModel.setmeal_desc;
            [setmeal_descLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(titleLabel.frame)+10) width:DEVICE_WIDTH - 20];
            [self.contentView addSubview:setmeal_descLabel];
            
            //价格
            NSString *xianjia = self.delegate.theProductModel.setmeal_price;
            NSString *yuanjia = self.delegate.theProductModel.setmeal_original_price;
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+12, DEVICE_WIDTH - 20, 15)];
            if ([LTools isEmpty:self.delegate.theProductModel.setmeal_desc]) {
                [priceLabel setFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+12, DEVICE_WIDTH - 20, 15)];
            }else{
                [priceLabel setFrame:CGRectMake(10, CGRectGetMaxY(setmeal_descLabel.frame)+12, DEVICE_WIDTH - 20, 15)];
                height += setmeal_descLabel.frame.size.height + 12;
            }
            
            
            if ([LTools isEmpty:xianjia] || [LTools isEmpty:yuanjia]) {
                
            }else{
                NSString *price = [NSString stringWithFormat:@"￥%@ ￥%@",xianjia,yuanjia];
                NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
                [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
                [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, xianjia.length+1)];
                
                [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
                [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
                [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length+1)];
                priceLabel.attributedText = aaa;
            }
            
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
        
        //领取优惠券按钮
        UIButton *getCouponBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [getCouponBtn setFrame:CGRectMake(DEVICE_WIDTH - 80, 0, 80, tLabel.frame.size.height)];
        getCouponBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [getCouponBtn setTitle:@" " forState:UIControlStateNormal];
        [getCouponBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [getCouponBtn addTarget:self action:@selector(clickToCoupe) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:getCouponBtn];
        
        
        
        
        
        if (self.delegate.theProductModel.coupon_list.count>0) {
            getCouponBtn.hidden = YES;
            
            NSInteger count = self.delegate.theProductModel.coupon_list.count;
            if (count>3) {
                count = 3;
            }
            
            CGFloat v_high = tLabel.frame.size.height - 18;
            CGFloat v_width = v_high *2.66;
            
            for (int i = 0; i<count; i++) {
                 UIView *view = [self coupeViewWithCoupeModel:self.delegate.theProductModel.coupon_list[i] frame:CGRectMake(DEVICE_WIDTH - 5 - (i+1) * v_width, 9, v_width, v_high)];
                [self.contentView addSubview:view];
            }
            
            
        }else{
            [getCouponBtn setTitle:@"暂无优惠券" forState:UIControlStateNormal];
        }
        
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tLabel.frame), DEVICE_WIDTH, 5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:line];
        height += line.frame.size.height;
        
    }else if (theindexPath.section == 2){//主要参数
        
        //点击跳转到品牌店
        UIView *brandNameView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
        [brandNameView addTaget:self action:@selector(brandStoreClicked) tag:20000];
        [self.contentView addSubview:brandNameView];
        height += brandNameView.frame.size.height;
        
        UIImageView *logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
        [logoImv l_setImageWithURL:[NSURL URLWithString:self.delegate.theProductModel.brand_logo] placeholderImage:nil];
        logoImv.layer.cornerRadius = 10;
        [brandNameView addSubview:logoImv];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(logoImv.right + 5, 40*0.5-10, DEVICE_WIDTH - 10 - 20 - 5 - 10 - 8 - 5, 20)];
        titleLabel.text = self.delegate.theProductModel.brand_name;
        titleLabel.font = [UIFont systemFontOfSize:12];
        [brandNameView addSubview:titleLabel];
        
        UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 18, 40*0.5-7.5, 8, 15)];
        [jiantouImv setImage:[UIImage imageNamed:@"personal_jiantou_small.png"]];
        [brandNameView addSubview:jiantouImv];
        
        
        //分割线
        UIView *fen_lin = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(brandNameView.frame) , DEVICE_WIDTH, 5)];
        fen_lin.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:fen_lin];
        
        
        //主要参数
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(fen_lin.frame)+10, 60, 15)];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.text = @"主要参数";
        [self.contentView addSubview:tLabel];
        height += tLabel.frame.size.height+10;
    
        UIView *cView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(tLabel.frame)+5, DEVICE_WIDTH-20, 50)];
        [self.contentView addSubview:cView];
        
        //品牌名称
        UILabel *brandNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        brandNameLabel.textColor = [UIColor blackColor];
        brandNameLabel.text = [NSString stringWithFormat:@"品牌名称:  %@",[LTools isEmpty:self.delegate.theProductModel.brand_name]?@"":self.delegate.theProductModel.brand_name];
        [cView addSubview:brandNameLabel];
        
        //适用性别
        UILabel *genderLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        NSString *attributedText1 = @"适用性别：";
        NSString *attributedText2 = @"";
        if ([self.delegate.theProductModel.gender_id intValue] == 1) {//男
            attributedText2 = @"[仅供男性使用]";
        }else if ([self.delegate.theProductModel.gender_id intValue] == 2){//女
            attributedText2 = @"[仅供女性使用]";
        }else if ([self.delegate.theProductModel.gender_id intValue] == 99){
            attributedText2 = @"[男女不限]";
        }
        
        
        
        NSAttributedString *attributedText4 = [LTools attributedString:[NSString stringWithFormat:@"%@%@",attributedText1,attributedText2] keyword:attributedText2 color:RGBCOLOR(224, 103, 20)];
        [genderLabel setAttributedText:attributedText4];
        [cView addSubview:genderLabel];
        
        
        
        //适合人群
        UILabel *suitLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        suitLabel.textColor = [UIColor blackColor];
        suitLabel.text = @"适用人群：";
        [cView addSubview:suitLabel];
        
        UILabel *suitLabel_info = [[UILabel alloc]initWithFrame:CGRectZero];
        [cView addSubview:suitLabel_info];
        
        NSArray *suit_infoArray = self.delegate.theProductModel.suit_info;
        NSString *suit_info_str;
        NSMutableArray *suit_info_mArray = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in suit_infoArray) {
            NSString *ss = [dic stringValueForKey:@"suit_name"];
            [suit_info_mArray addObject:ss];
        }
        suit_info_str = [suit_info_mArray componentsJoinedByString:@" "];
        
        suitLabel_info.text = suit_info_str;
        
        
        
        //体检项目
        UILabel *projectInfoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        projectInfoLabel.textColor = [UIColor blackColor];
        NSArray *projectInfoArray = self.delegate.theProductModel.project_info;
        
        NSString *projectInfo_str;
        NSMutableArray *arrrr = [NSMutableArray arrayWithCapacity:1];
        
        for (NSDictionary *dic in projectInfoArray) {
            [arrrr addObject:[dic stringValueForKey:@"project_name"]];
        }
        
        projectInfo_str = [arrrr componentsJoinedByString:@" "];
        projectInfoLabel.text = [NSString stringWithFormat:@"体检项目：%@",projectInfo_str];
        [cView addSubview:projectInfoLabel];
        

        
        //适用地区
        UILabel *city_titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        city_titleLabel.text = @"适用地区:";
        [cView addSubview:city_titleLabel];
        
        UILabel *cityInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(city_titleLabel.frame), city_titleLabel.frame.origin.y, cView.frame.size.width - city_titleLabel.frame.size.width, 12)];
        cityInfoLabel.textColor = [UIColor blackColor];
        
        NSMutableArray *cityInfoArray = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in self.delegate.theProductModel.city_info) {
            NSString *str = [dic stringValueForKey:@"city_name"];
            [cityInfoArray addObject:str];
        }
        NSString *cityInfo_str = [cityInfoArray componentsJoinedByString:@" "];
        cityInfoLabel.text = [NSString stringWithFormat:@"%@",cityInfo_str];
        [cView addSubview:cityInfoLabel];

        //品牌名称
        brandNameLabel.font = [UIFont systemFontOfSize:12];
        [brandNameLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, 0) width:cView.frame.size.width];
        
        //适用性别
        genderLabel.font = [UIFont systemFontOfSize:12];
        [genderLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, CGRectGetMaxY(brandNameLabel.frame)+5) width:cView.frame.size.width];
        
        //适用人群
        suitLabel.font = [UIFont systemFontOfSize:12];
        [suitLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, CGRectGetMaxY(genderLabel.frame)+5) width:60];
        suitLabel_info.font = [UIFont systemFontOfSize:12];
        [suitLabel_info setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(suitLabel.frame), suitLabel.frame.origin.y) width:cView.frame.size.width - suitLabel.frame.size.width];
        
        //体检项目
        projectInfoLabel.font = [UIFont systemFontOfSize:12];
        if (suitLabel_info.frame.size.height == 0) {
            [suitLabel_info setFrame:CGRectMake(CGRectGetMaxX(suitLabel.frame), suitLabel.frame.origin.y, 20, suitLabel.frame.size.height)];
        }
        [projectInfoLabel setFrame:CGRectMake(0, CGRectGetMaxY(suitLabel_info.frame)+5, cView.frame.size.width, 14)];
        
        //适用地区
        city_titleLabel.font = [UIFont systemFontOfSize:12];
        [city_titleLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, CGRectGetMaxY(projectInfoLabel.frame)+5) width:52];
        cityInfoLabel.font = [UIFont systemFontOfSize:12];
        [cityInfoLabel setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(city_titleLabel.frame)+5, CGRectGetMaxY(projectInfoLabel.frame)+5) width:cView.frame.size.width - city_titleLabel.frame.size.width];
        if (cityInfoLabel.frame.size.height == 0) {
            [cityInfoLabel setFrame:CGRectMake(CGRectGetMaxX(city_titleLabel.frame), city_titleLabel.frame.origin.y, 20, city_titleLabel.frame.size.height)];
        }
        
        
        
        //自适应高度
        CGFloat hh = brandNameLabel.frame.size.height + 5 +genderLabel.frame.size.height + 5 + suitLabel_info.frame.size.height + 5 + projectInfoLabel.frame.size.height + 5 + cityInfoLabel.frame.size.height;
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
            tLabel.font = [UIFont systemFontOfSize:13];
            tLabel.text = @"评价";
            [view addSubview:tLabel];
            
            
            if (commentArr.count>0) {
                UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [moreBtn setFrame:CGRectMake(view.frame.size.width-70, 0, 60, view.frame.size.height)];
                moreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
                [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
                [moreBtn setImage:[UIImage imageNamed:@"personal_jiantou_r.png"] forState:UIControlStateNormal];
                [moreBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
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
                UILabel *tt = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, DEVICE_WIDTH, 30)];
                tt.text = @"暂无数据";
                tt.textColor = [UIColor grayColor];
                tt.font = [UIFont systemFontOfSize:11];
                [self.contentView addSubview:tt];
                height = 30;
            }else{
                CGFloat h_y = 0;
                for (int i = 0; i<commentArr.count; i++) {
                    GproductCommentView *view = [[GproductCommentView alloc]initWithFrame:CGRectMake(0, h_y, DEVICE_WIDTH, 10)];
                    view.delegate = self.delegate;
                    CGFloat hh = [view loadCustomViewWithModel:commentArr[i]];
                    [self.contentView addSubview:view];
                    height += hh;
                    h_y = hh;
                }
            }
        }
        
    
    }else if (theindexPath.section == 4){//看了又看
        
        UIView *upline = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
        upline.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:upline];
        height += upline.frame.size.height;
        
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, height + 10, 60, 15)];
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
            [imv l_setImageWithURL:[NSURL URLWithString:amodel.cover_pic] placeholderImage:nil];
            [logoAndContentView addSubview:imv];
            
            UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(imv.frame)+5, theW-10, [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/60])];
            titleLable.text = amodel.setmeal_name;
            titleLable.numberOfLines = 2;
            titleLable.font = [UIFont systemFontOfSize:11];
            [logoAndContentView addSubview:titleLable];
            
            
            NSString *xianjia = [NSString stringWithFormat:@"%.1f",[amodel.setmeal_price floatValue]];
            NSString *yuanjia = [NSString stringWithFormat:@"%.1f",[amodel.setmeal_original_price floatValue]];
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(titleLable.frame)+5, imv.frame.size.width - 5, 12)];
            NSString *price = [NSString stringWithFormat:@"￥%@ ￥%@",xianjia,yuanjia];
            NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, xianjia.length+1)];
            
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
            [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length+1)];
            priceLabel.attributedText = aaa;
            [logoAndContentView addSubview:priceLabel];
            
            
        }
        
        if (count>0) {
            height += theH +20;
        }else{
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, height+10, DEVICE_WIDTH, 0.5)];
            line.backgroundColor = RGBCOLOR(244, 245, 246);
            [self.contentView addSubview:line];
            height+=line.frame.size.height+10;
            
            UILabel *tt = [[UILabel alloc]initWithFrame:CGRectMake(20, height, DEVICE_WIDTH, 30)];
            tt.text = @"暂无数据";
            tt.font = [UIFont systemFontOfSize:11];
            tt.textColor = [UIColor grayColor];
            [self.contentView addSubview:tt];
            height += tt.frame.size.height;
        }
        
        
        
        
        
    }else if (theindexPath.section == 5){//上拉显示体检项目详情
        
        UIView *upline = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
        upline.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:upline];
        height += upline.frame.size.height;
        
        UIButton *tishiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [tishiBtn setFrame:CGRectMake(0, height, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
        tishiBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [tishiBtn setImage:[UIImage imageNamed:@"jiantou_up.png"] forState:UIControlStateNormal];
        [tishiBtn setTitle:@"上拉显示体检项目详情" forState:UIControlStateNormal];
        [tishiBtn setTitleColor:RGBCOLOR(26, 27, 28) forState:UIControlStateNormal];
        
        [tishiBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        
        
        [self.contentView addSubview:tishiBtn];
        height += tishiBtn.frame.size.height;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tishiBtn.frame), DEVICE_WIDTH, 5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:line];
        height += line.frame.size.height+10;
    }
    
    
    
    return height;
    
}

//创建优惠券
- (UIView *)coupeViewWithCoupeModel:(CouponModel *)aModel
                              frame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    
    UIImage *aImage = [LTools imageForCoupeColorId:aModel.color];
    
    //券
    UIButton *btn = [[UIButton alloc]initWithframe:view.bounds buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil nornalImage:aImage selectedImage:nil target:self action:nil];
    [view addSubview:btn];
    [btn addTarget:self action:@selector(clickToCoupe) forControlEvents:UIControlEventTouchUpInside];
    
    
    int type = [aModel.type intValue];
    
    NSString *title_minus;
    NSString *title_full;
    NSString *title;
    //满减
    if (type == 1) {
        
        title_minus = [NSString stringWithFormat:@"￥%@",aModel.minus_money];
        title_full = [NSString stringWithFormat:@"满%@即可使用",aModel.full_money];
        title = [NSString stringWithFormat:@"满%@减%@",aModel.full_money,aModel.minus_money];
    }
    //折扣
    else if (type == 2){
        
        NSString *discount = [NSString stringWithFormat:@"%.1f",[aModel.discount_num floatValue] * 10];
        discount = [NSString stringWithFormat:@"%@",[discount stringByRemoveTrailZero]];
        title_minus = @"优惠券";
        title_full = [NSString stringWithFormat:@"本店享%@折优惠",discount];
        title = [NSString stringWithFormat:@"%@折",discount];
    }
    
    CGFloat aHeight = btn.height / 2.f - 5;
    UILabel *minusLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, btn.width - 10, aHeight) title:title_minus font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:minusLabel];
    UILabel *fullLabel = [[UILabel alloc]initWithFrame:CGRectMake(minusLabel.left, minusLabel.bottom, minusLabel.width, aHeight) title:title_full font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:fullLabel];
    
    
    return view;
    
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

//跳转品牌店
-(void)brandStoreClicked{
    [self.delegate goToBrandStoreHomeVc];
}



/**
 *  点击去获取优惠劵
 */
- (void)clickToCoupe
{
    
    if ([LoginViewController isLogin]) {
        
        if (self.delegate.theProductModel.coupon_list.count>0) {
            if (_coupeView) {
                [_coupeView removeFromSuperview];
                _coupeView = nil;
            }
            
            NSArray *coupons = self.delegate.theProductModel.coupon_list;
            
            _coupeView = [[CoupeView alloc]initWithCouponArray:coupons userStyle:USESTYLE_Get];
            
            __weak typeof(self)weakSelf = self;
            
            _coupeView.coupeBlock = ^(NSDictionary *params){
                
                ButtonProperty *btn = params[@"button"];
                CouponModel *aModel = params[@"model"];
                
                [weakSelf netWorkForCouponModel:aModel button:btn];
            };
            [_coupeView show];
        }
        
        
    }else{
        [LoginViewController isLogin:self.delegate loginBlock:^(BOOL success) {
            
            
        }];
    }
    
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

    YJYRequstManager *rr = [YJYRequstManager shareInstance];
    NSDictionary *dic = @{
                          @"coupon_id":aModel.coupon_id,
                          @"authcode":[LTools objectForKey:USER_AUTHOD]
                          };
    
    [rr requestWithMethod:YJYRequstMethodGet api:USER_GETCOUPON parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        aModel.enable_receive = @"0";
        sender.selected = YES;
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
}

@end
