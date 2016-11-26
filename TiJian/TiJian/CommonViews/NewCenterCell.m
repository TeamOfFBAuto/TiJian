//
//  NewCenterCell.m
//  TiJian
//
//  Created by lichaowei on 16/7/18.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "NewCenterCell.h"
#import "HospitalModel.h"

@implementation NewCenterCell


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.recommendLabel addCornerRadius:3.f];
    [self.recommendLabel setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
    [self.recommendLabel setFont:[UIFont systemFontOfSize:12.f]];
}

-(void)setCenterModel:(HospitalModel *)centerModel
{
    [self.iconImgeView l_setImageWithURL:[NSURL URLWithString:centerModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
    self.centerNameLabel.text = [NSString stringWithFormat:@"%@  %@",centerModel.brand_name,centerModel.center_name];
    self.addressLabel.text = centerModel.address;
    self.distanceLabel.text = [LTools distanceString:centerModel.distance];
    
    NSArray *products = centerModel.product;
    if (products.count == 2) {
        for (int i = 0; i < 2; i ++) {
            NSDictionary *dic = products[i];
            NSString *p_name = dic[@"setmeal_name"];
            NSString *current_price = dic[@"current_price"];
            current_price = [NSString stringWithFormat:@"¥%@",current_price];
            NSString *temp = [NSString stringWithFormat:@"%@  %@",p_name,current_price];
            
            NSAttributedString *attString = [LTools attributedString:temp keyword:current_price color:DEFAULT_TEXTCOLOR_TITLE_THIRD];
            
            if (i == 0) {
                [self.pLabelOne setAttributedText:attString];
            }else
            {
                [self.pLabelTwo setAttributedText:attString];
            }
        }
    }
}

@end
