//
//  RightTextFieldCell.m
//  TiJian
//
//  Created by lichaowei on 15/11/10.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "RightTextFieldCell.h"

@implementation RightTextFieldCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
           textFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.tf_right = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, DEVICE_WIDTH - 100 - 10, 55)];
        _tf_right.font = [UIFont systemFontOfSize:15];
        _tf_right.textAlignment = NSTextAlignmentRight;
        _tf_right.delegate = textFieldDelegate;
        _tf_right.clearButtonMode = UITextFieldViewModeWhileEditing;

        [self.contentView addSubview:_tf_right];
    }
    return self;
}

@end
