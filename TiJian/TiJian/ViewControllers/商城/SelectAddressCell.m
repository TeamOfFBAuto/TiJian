//
//  SelectAddressCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/20.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "SelectAddressCell.h"
#import "AddressModel.h"

@implementation SelectAddressCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(AddressModel *)aModel
{
    self.nameLabel.text = [NSString stringWithFormat:@"%@  %@",aModel.receiver_username,aModel.mobile];
    CGFloat width = [LTools widthForText:aModel.receiver_username font:15];
    
    self.addressLabel.text = aModel.address;
    
//    default_address
    
    int isDefault = [aModel.default_address intValue];
    
    NSString *keyword = isDefault ? @"[默认]" : @"";
    
    NSString *content = [NSString stringWithFormat:@"%@%@",keyword,aModel.address];
    NSAttributedString *string = [LTools attributedString:content keyword:keyword color:DEFAULT_TEXTCOLOR];
    [self.addressLabel setAttributedText:string];
}

@end
