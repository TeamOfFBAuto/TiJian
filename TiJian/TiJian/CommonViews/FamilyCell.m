//
//  FamilyCell.m
//  TiJian
//
//  Created by lichaowei on 16/7/22.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "FamilyCell.h"

@implementation FamilyCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat width = 50.f;
        //编辑按钮
        PropertyButton *edit = [PropertyButton buttonWithType:UIButtonTypeCustom];
        edit.frame = CGRectMake(0, 0, width, self.height);
        [edit setImage:[UIImage imageNamed:@"vip_bianji"] forState:UIControlStateNormal];
        [self.contentView addSubview:edit];
        self.editButton = edit;
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(edit.right, 0, self.width - width * 2, self.height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:nil];
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        //选择
        UIButton *selectIcon = [[UIButton alloc]initWithframe:CGRectMake(self.width - width, 0, width, self.height) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"vip_xuanze"] selectedImage:nil target:self action:nil];
        [self.contentView addSubview:selectIcon];
        self.selectButton = selectIcon;
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.selectButton.hidden = !selected;
    if (selected) {
        self.backgroundColor = [UIColor colorWithHexString:@"dbe7f0"];
    }else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
