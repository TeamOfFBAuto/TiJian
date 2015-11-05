//
//  GproductDirectoryTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GproductDirectoryTableViewCell.h"

@implementation GproductDirectoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(CGFloat)loadCustomViewWithData:(NSDictionary*)dic indexPath:(NSIndexPath*)theIndex{
    CGFloat height = 0;
    if (theIndex.row ==0) {
        UIView *blueView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60])];
        blueView.backgroundColor = RGBCOLOR(222, 245, 255);
        [self.contentView addSubview:blueView];
        height += blueView.frame.size.height;
    }else{
        height = 50;
    }

    return height;
}

@end
