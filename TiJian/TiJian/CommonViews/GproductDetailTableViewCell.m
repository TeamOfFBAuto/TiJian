//
//  GproductDetailTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GproductDetailTableViewCell.h"

@implementation GproductDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(CGFloat)loadCustomViewWithDic:(NSDictionary*)dataDic index:(NSIndexPath*)theindexPath{
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
            
            
            [imv l_setImageWithURL:[NSURL URLWithString:[dataDic stringValueForKey:@"cover_pic"]] placeholderImage:nil];
            [self.contentView addSubview:imv];
            height += imv.frame.size.height;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(imv.frame)+15, DEVICE_WIDTH - 20, 0)];
            titleLabel.font = [UIFont systemFontOfSize:13];
            titleLabel.text = [dataDic stringValueForKey:@"setmeal_name"];
            titleLabel.numberOfLines = 2;
            [titleLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(imv.frame)+15) width:DEVICE_WIDTH - 20];
            [self.contentView addSubview:titleLabel];
            height += titleLabel.frame.size.height+15;
            
            
            NSString *xianjia = [dataDic stringValueForKey:@"setmeal_price"];
            NSString *yuanjia = [dataDic stringValueForKey:@"setmeal_original_price"];
            
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+12, DEVICE_WIDTH - 20, 15)];
            NSString *price = [NSString stringWithFormat:@"￥%@ %@",xianjia,yuanjia];
            NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, xianjia.length+1)];
            
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
            [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length)];
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
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tLabel.frame), DEVICE_WIDTH, 5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:line];
        height += line.frame.size.height;
        
    }else if (theindexPath.section == 2){//主要参数
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 15)];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.text = @"主要参数";
        [self.contentView addSubview:tLabel];
        height +=tLabel.frame.size.height;
        
        UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(tLabel.frame)+10, DEVICE_WIDTH-20, 50)];
        cLabel.font = [UIFont systemFontOfSize:13];
        cLabel.text = @"主要参数介绍主要参数介绍主要参数介绍主要参数介绍主要参数介绍主要参数介绍主要参数介绍";
        [cLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(tLabel.frame)+10) width:DEVICE_WIDTH - 20];
        [self.contentView addSubview:cLabel];
        height = 25+cLabel.frame.size.height+10;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(cLabel.frame)+10, DEVICE_WIDTH, 5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:line];
        height += line.frame.size.height+10;
        
    }else if (theindexPath.section == 3){//评价
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, 0)];
        tLabel.font = [UIFont systemFontOfSize:13];
        tLabel.text  = @"评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容";
        [tLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, 10) width:DEVICE_WIDTH-20];
        [self.contentView addSubview:tLabel];
        height +=tLabel.frame.size.height;
        
        UILabel *replyNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(tLabel.frame)+10, (DEVICE_WIDTH-20)*0.5, 15)];
        replyNameLabel.font = [UIFont systemFontOfSize:12];
        replyNameLabel.textColor = RGBCOLOR(80, 81, 82);
        replyNameLabel.text = @"回复商家名称";
        [self.contentView addSubview:replyNameLabel];
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(replyNameLabel.frame), replyNameLabel.frame.origin.y, (DEVICE_WIDTH-20)*0.5, 15)];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = RGBCOLOR(80, 81, 82);
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.text = @"2015-08-20";
        [self.contentView addSubview:timeLabel];
        height +=timeLabel.frame.size.height+10;
        
        UILabel *replyContentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        replyContentLabel.font = [UIFont systemFontOfSize:10];
        replyContentLabel.text = @"商家回复内容商家回复内容商家回复内容商家回复内容商家回复内容";
        replyContentLabel.textColor = RGBCOLOR(80, 81, 82);
        [replyContentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(timeLabel.frame)+5) width:DEVICE_WIDTH-20];
        [self.contentView addSubview:replyContentLabel];
        height += 5+replyContentLabel.frame.size.height;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(replyContentLabel.frame)+10, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.contentView addSubview:line];
        height += line.frame.size.height+15;
        
        
    }else if (theindexPath.section == 4){//看了又看
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 15)];
        tLabel.textColor = [UIColor blackColor];
        tLabel.text = @"看了又看";
        tLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:tLabel];
        height += tLabel.frame.size.height +10;
        
        
        CGFloat theW = (DEVICE_WIDTH - 20 - 10)/3;
        CGFloat theH = [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/265];
        for (int i = 0; i<3; i++) {
            UIView *logoAndContentView = [[UIView alloc]initWithFrame:CGRectMake(10+i*(theW+5), CGRectGetMaxY(tLabel.frame)+10, theW, theH)];
            logoAndContentView.layer.borderWidth = 0.5;
            logoAndContentView.layer.borderColor = [RGBCOLOR(235, 236, 238)CGColor];
            [self.contentView addSubview:logoAndContentView];
            
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, logoAndContentView.frame.size.width, [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/145])];
            imv.backgroundColor = RGBCOLOR_ONE;
            [logoAndContentView addSubview:imv];
            
            UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(imv.frame)+5, theW-10, [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/60])];
            titleLable.text = @"套餐介绍套餐介绍套餐介绍套餐介绍套餐介绍";
            titleLable.numberOfLines = 2;
            titleLable.font = [UIFont systemFontOfSize:11];
            [logoAndContentView addSubview:titleLable];
            
            
            NSString *xianjia = @"578";
            NSString *yuanjia = @"963";
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(titleLable.frame)+5, DEVICE_WIDTH - 10, 12)];
            NSString *price = [NSString stringWithFormat:@"￥%@ %@",xianjia,yuanjia];
            NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, xianjia.length+1)];
            
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
            [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length)];
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

@end
