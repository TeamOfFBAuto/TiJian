//
//  GcommentTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GcommentTableViewCell.h"
#import "GproductCommentView.h"

@implementation GcommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(CGFloat)loadCustomViewWithModel:(ProductCommentModel*)model{
    GproductCommentView *vv = [[GproductCommentView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 10)];
    CGFloat hh = [vv loadCustomViewWithModel:model];
    [self.contentView addSubview:vv];
    
    return hh;
}


@end
