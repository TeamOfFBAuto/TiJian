//
//  LTextView.m
//  TiJian
//
//  Created by lichaowei on 16/7/21.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "LTextView.h"

@interface LTextView ()<UITextViewDelegate>

@property(nonatomic,retain)UILabel *placeHolderLabel;

@end

@implementation LTextView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
}

-(UILabel *)placeHolderLabel
{
    CGFloat p_width = self.width - 7 * 2;

    if (!_placeHolderLabel) {
        _placeHolderLabel = [[UILabel alloc]initWithFrame:CGRectMake(7, 3, p_width, 25)];
        _placeHolderLabel.font = [UIFont systemFontOfSize:10];
        _placeHolderLabel.textAlignment = NSTextAlignmentLeft;
        _placeHolderLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
        [self addSubview:_placeHolderLabel];
    }
    return _placeHolderLabel;
}

#pragma mark - setter

-(void)setPlaceHolder:(NSString *)placeHolder
{
    if (!placeHolder) {
        return;
    }
    
    self.placeHolderLabel.text = placeHolder;
}

//@property (nonatomic,retain)UIFont *placeHolderFont;//字体

-(void)setPlaceHolderFont:(UIFont *)placeHolderFont
{
    self.placeHolderLabel.font = placeHolderFont;
}
//@property (nonatomic,retain)UIColor *placeHolderColor;//颜色

-(void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    self.placeHolderLabel.textColor = placeHolderColor;
}
//@property (nonatomic,assign)CGRect placeHoderFrame;//frame
-(void)setPlaceHoderFrame:(CGRect)placeHoderFrame
{
    self.placeHolderLabel.frame = placeHoderFrame;
}

#pragma - mark UITextViewDelegate 

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0)
    {
        self.placeHolderLabel.hidden = YES;
    }else
    {
        self.placeHolderLabel.hidden = NO;
    }
    
}


@end
