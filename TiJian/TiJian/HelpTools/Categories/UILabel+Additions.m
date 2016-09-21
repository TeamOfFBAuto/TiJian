//
//  UILabel+Additions.m
//  YiYiProject
//
//  Created by lichaowei on 15/6/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "UILabel+Additions.h"

@implementation UILabel (Additions)

- (UILabel *)initWithFrame:(CGRect)aFrame
                      font:(CGFloat)size
                     align:(NSTextAlignment)align
                 textColor:(UIColor *)textColor
                     title:(NSString *)title

{
    return [self initWithFrame:aFrame title:title font:size align:align textColor:textColor];
}

- (UILabel *)initWithFrame:(CGRect)aFrame
                        title:(NSString *)title
                         font:(CGFloat)size
                        align:(NSTextAlignment)align
                    textColor:(UIColor *)textColor
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:aFrame];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:size];
    titleLabel.textAlignment = align;
    titleLabel.textColor = textColor;
    return titleLabel;
}

- (void)addTapGestureTarget:(id)target action:(SEL)selector
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
}

//设定宽度 自适应高度
-(void)setMatchedFrame4LabelWithOrigin:(CGPoint)o width:(CGFloat)theWidth{
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=10.0)){
        theWidth += 5;
    }
    
    CGRect r = [self matchedRectWithWidth:theWidth];
    [self setFrame:CGRectMake(o.x, o.y, r.size.width, r.size.height)];
    
}

-(CGRect)matchedRectWithWidth:(CGFloat)width{
    
    self.numberOfLines = 0;
    CGRect r = CGRectZero;
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        r = [self.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
    }
    return r;
    
}




//设定高度 最大宽度  自适应宽度
-(void)setMatchedFrame4LabelWithOrigin:(CGPoint)o height:(CGFloat)theHeight limitMaxWidth:(CGFloat)theWidth{
    CGRect r = [self matchedrectWithHeight:theHeight];
    if (r.size.width>theWidth) {
        [self setFrame:CGRectMake(o.x, o.y, theWidth, r.size.height)];
    }else{
        [self setFrame:CGRectMake(o.x, o.y, r.size.width, r.size.height)];
    }
    
}

-(CGRect)matchedrectWithHeight:(CGFloat)height{
    self.numberOfLines = 1;
    CGRect r = CGRectZero;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        r = [self.text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
    }
    return r;
}

@end
