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
    
    
    NSString *xuhao = [dic stringValueForKey:@"sn"];//序号
    NSString *project_name = [dic stringValueForKey:@"project_name"];//项目名
    NSString *project_desc = [dic stringValueForKey:@"project_desc"];//项目描述
    
    
    UILabel *xuhaoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    xuhaoLabel.font = [UIFont systemFontOfSize:12];
    xuhaoLabel.text = xuhao;
    [self.contentView addSubview:xuhaoLabel];
    
    UILabel *mingxiLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    mingxiLabel.text = project_name;
    mingxiLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:mingxiLabel];
    
    UILabel *zuheneirongLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    zuheneirongLabel.font = [UIFont systemFontOfSize:12];
    zuheneirongLabel.text = project_desc;
    [self.contentView addSubview:zuheneirongLabel];
    
    
    
    //自适应高度
    [xuhaoLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, 0) width:DEVICE_WIDTH/4];
    [mingxiLabel setMatchedFrame4LabelWithOrigin:CGPointMake(DEVICE_WIDTH/4, 0) width:DEVICE_WIDTH/4];
    [zuheneirongLabel setMatchedFrame4LabelWithOrigin:CGPointMake(DEVICE_WIDTH/2, 0) width:DEVICE_WIDTH/2];
    
    [xuhaoLabel setWidth:DEVICE_WIDTH/4];
    [mingxiLabel setWidth:DEVICE_WIDTH/4];
    [zuheneirongLabel setWidth:DEVICE_WIDTH/2];
    
    
    xuhaoLabel.textAlignment = NSTextAlignmentCenter;
    mingxiLabel.textAlignment = NSTextAlignmentCenter;
    zuheneirongLabel.textAlignment = NSTextAlignmentCenter;
    
    if ([xuhao isEqualToString:@"1"] || [xuhao isEqualToString:@"2"] || [xuhao isEqualToString:@"3"]) {
        
        
    }
    
    NSArray *arr = @[xuhaoLabel,mingxiLabel,zuheneirongLabel];
    CGFloat maxHeight = 0;
    int flag = 0;
    for (int i = 0; i<3; i++) {
        UILabel *ll = arr[i];
        if (maxHeight<ll.frame.size.height) {
            maxHeight = ll.frame.size.height;
            flag = i;
        }
    }
    
    height = maxHeight;
    
    if (height<[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60]) {
        height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60];
    }
    
    [xuhaoLabel setHeight:height];
    [mingxiLabel setHeight:height];
    [zuheneirongLabel setHeight:height];
    
    return height;
}

@end
