//
//  GHospitalOfProvinceTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 16/7/23.
//  Copyright © 2016年 lcw. All rights reserved.
//

//挂号 选择医院自定义cell

#import "GHospitalOfProvinceTableViewCell.h"

@implementation GHospitalOfProvinceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor = RGBCOLOR(222, 238, 248);
    }else{
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    // Configure the view for the selected state
}

@end
