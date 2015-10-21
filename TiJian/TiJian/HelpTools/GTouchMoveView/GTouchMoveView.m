//
//  GTouchMoveView.m
//  scrollDemo
//
//  Created by gaomeng on 15/10/21.
//  Copyright © 2015年 gaomeng. All rights reserved.
//

#import "GTouchMoveView.h"
#import "UILabel+GautoMatchedText.h"

@implementation GTouchMoveView
{
    CGRect _theFrame;
    CGFloat _theRangeLow;
    CGFloat _theRangeHigh;
    
    UILabel *_progressNumLabel;
    
    CGFloat _titleTextWidth;
    UILabel *_titelLabel;
    GmoveImv *_moveImv;
}

/**
 *  初始化方法
 *  @param frame    最小height为53
 *  @param theColor   进度条颜色
 *  @param theTitle   左下角文字
 *  @param theRangeLow 最低范围
 *  @param theRangeHigh 最高范围
 *  @param imvName 下面滑块的图片名称
 */
-(id)initWithFrame:(CGRect)frame color:(UIColor *)theColor title:(NSString *)theTitle rangeLow:(int)theRangeLow rangeHigh:(int)theRangeHigh imageName:(NSString*)imvName{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _theFrame = frame;
        _theRangeLow = theRangeLow;
        _theRangeHigh = theRangeHigh;
        
        //数字
        _progressNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 18)];
        _progressNumLabel.textAlignment = NSTextAlignmentCenter;
        
        _progressNumLabel.font = [UIFont systemFontOfSize:14];
        _progressNumLabel.textColor = theColor;
        [self addSubview:_progressNumLabel];
        
        //进度条
        UIView *progressView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_progressNumLabel.frame), frame.size.width, 10)];
        progressView.layer.cornerRadius = 5;
        progressView.backgroundColor = theColor;
        [self addSubview:progressView];
        
        //项目名称
        _titelLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(progressView.frame), frame.size.width, 22)];
        _titelLabel.textColor = theColor;
        _titelLabel.font = [UIFont systemFontOfSize:14];
        _titelLabel.text = theTitle;
        _titleTextWidth = [_titelLabel getTextWidth];
        
        [self addSubview:_titelLabel];
        
        //滑块
        UIView *backMoveView = [[UIView alloc]initWithFrame:CGRectMake(0, _titelLabel.frame.origin.y, frame.size.width, 25)];
        [self addSubview:backMoveView];
        _moveImv = [[GmoveImv alloc]initWithFrame:CGRectMake(frame.size.width*0.5 - frame.size.height/3*0.5, 0, 25, 25) imageName:imvName];
        _moveImv.delegate = self;
        [backMoveView addSubview:_moveImv];
        
        
        CGFloat chooseValue = _moveImv.frame.origin.x +_moveImv.frame.size.width*0.5;
        int switchValue = [self valueSwitch:chooseValue];
        //调整数字Label的frame
        CGRect r = _progressNumLabel.frame;
        r.origin.x = chooseValue - r.size.width*0.5;
        _progressNumLabel.frame = r;
         _progressNumLabel.text = [NSString stringWithFormat:@"%d",switchValue];
        
        self.TheValue = _progressNumLabel.text;
        
        
    }
    
    
    
    return self;
}



-(void)theValue:(CGFloat)chooseValue{
    NSLog(@"--->%.2f",chooseValue);
    
    //调整数字Label的frame
    CGRect r = _progressNumLabel.frame;
    r.origin.x = chooseValue - r.size.width*0.5;
    _progressNumLabel.frame = r;
    
    
    
    int switchValue = [self valueSwitch:chooseValue];
    if (_titleTextWidth>=(chooseValue-_moveImv.frame.size.width*0.5)) {
        NSLog(@"消失");
        _titelLabel.textAlignment = NSTextAlignmentRight;
    }else{
        _titelLabel.textAlignment = NSTextAlignmentLeft;
        NSLog(@"出现");
    }
    
   
    
    
    _progressNumLabel.text = [NSString stringWithFormat:@"%d",switchValue];
    self.TheValue = _progressNumLabel.text;
    
}


-(int)valueSwitch:(CGFloat)value{
    //范围转换
    CGFloat a = (value/_theFrame.size.width);
    CGFloat aa = (_theRangeHigh - _theRangeLow);
    CGFloat aaa = a * aa;
    int switchValue = (int)aaa;
    return switchValue;
}






@end
