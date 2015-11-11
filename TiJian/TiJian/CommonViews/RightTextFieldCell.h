//
//  RightTextFieldCell.h
//  TiJian
//
//  Created by lichaowei on 15/11/10.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightTextFieldCell : UITableViewCell

@property(nonatomic,retain)UITextField *tf_right;//右侧输入框

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
           textFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate;

@end
