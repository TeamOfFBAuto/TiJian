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
            
            
            [imv l_setImageWithURL:[NSURL URLWithString:[dataDic stringValueForKey:@"brand_cover"]] placeholderImage:nil];
            [self.contentView addSubview:imv];
            height += imv.frame.size.height;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(imv.frame)+15, DEVICE_WIDTH - 20, 0)];
            titleLabel.text = @"套餐名称简介套餐名称简介套餐名称简介套餐名称简介套餐名称简介套餐名称简介";
            titleLabel.numberOfLines = 2;
            titleLabel.backgroundColor = [UIColor orangeColor];
            [titleLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(imv.frame)+15) width:DEVICE_WIDTH - 20];
            [self.contentView addSubview:titleLabel];
            height += titleLabel.frame.size.height;
            
            
            NSString *xianjia = [dataDic stringValueForKey:@"setmeal_price"];
            NSString *yuanjia = [dataDic stringValueForKey:@"setmeal_original_price"];
            
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+12, DEVICE_WIDTH - 20, 15)];
            NSString *price = [NSString stringWithFormat:@"￥%@ %@",xianjia,yuanjia];
            NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, xianjia.length+1)];
            
            [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
            [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length)];
            priceLabel.attributedText = aaa;
            [self.contentView addSubview:priceLabel];
            height += priceLabel.frame.size.height;
            
        }
    }else if (theindexPath.section == 1){//优惠券
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/110])];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.text = @"优惠券";
        [self.contentView addSubview:tLabel];
        height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/110];
    }else if (theindexPath.section == 2){//主要参数
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 15)];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.text = @"主要参数";
        [self.contentView addSubview:tLabel];
        height +=tLabel.frame.size.height;
        
        UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(tLabel.frame), DEVICE_WIDTH-20, 50)];
        cLabel.text = @"主要参数介绍主要参数介绍主要参数介绍主要参数介绍主要参数介绍主要参数介绍主要参数介绍";
        [cLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, 10) width:DEVICE_WIDTH - 20];
        height = 25+cLabel.frame.size.height;
    }else if (theindexPath.section == 3){//评价
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, 50)];
        tLabel.font = [UIFont systemFontOfSize:13];
        tLabel.text  = @"评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容评论内容";
        [tLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, 10) width:DEVICE_WIDTH-20];
        [self.contentView addSubview:tLabel];
        
    }else if (theindexPath.section == 4){//看了又看
        
    }else if (theindexPath.section == 5){//上拉显示体检项目详情
        
    }
    
    
    
    
    
//    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/700];
//        }
//    }else if (indexPath.section == 1){
//        
//    }else if (indexPath.section == 2){
//        height = 50;
//    }else if (indexPath.section == 3){
//        height = 50;//1为暂无评论
//    }else if (indexPath.section == 4){
//        height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/355];
//    }else if (indexPath.section == 5){
//        height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/90];
//    }
    
    
    return height;
    
}

@end
