//
//  LSuitableView.m
//  TiJian
//
//  Created by lichaowei on 15/12/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "LSuitableView.h"

#define SUITABLE_LEFT 15.f //左右间距
#define SUITABLE_DIS 10.f //视图之间的间距
#define SUITABLE_TOP 5.f //视图之间的间距

@interface LSuitableView ()
{
    CGFloat _left;//左间距
    CGFloat _remainWidth;//剩下的宽度
    
    CGFloat _top;//记录y坐标
    CGFloat _labelBottom;//记录上个视图底部
}


@end

@implementation LSuitableView

/**
 *  初始化LSuitableView,自动适应大小
 *
 *  @param frame
 *  @param itemViewArray view数组
 *
 *  @return
 */
-(instancetype)initWithFrame:(CGRect)frame
                   itemViewArray:(NSArray *)itemViewArray
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (itemViewArray.count == 0) {
            return self;
        }
        
        NSMutableArray *temp = [NSMutableArray arrayWithArray:itemViewArray];
        
        _top = 0;
        _left = SUITABLE_LEFT;
        
        CGFloat maxWidth = self.width - _left * 2;
        
        _remainWidth = maxWidth;
        
        CGFloat dis = SUITABLE_DIS;//间距
        
        while (temp.count > 0) {
            
            CGFloat width = 0.f;
            
            BOOL isOK = NO;
            //查找符合宽度要求的title
            
            UIView *tempView = nil;
            for (UIView *view in temp) {
                
                width = view.width;
                //最大边界
                if (width >= maxWidth) {
                    width = maxWidth;
                }
                
                if (width <= _remainWidth) { //适合
                    
                    isOK = YES;
                    tempView = view;
                    break;//跳出for循环
                }
            }
            
            if (isOK) {
                                
                tempView.left = _left;
                tempView.top = _top;
                [self addSubview:tempView];
                _labelBottom = tempView.bottom;
                [temp removeObject:tempView];//移除掉
                
                _remainWidth -= (dis + width);//剩下的宽度
                _left = tempView.right + dis;
                
                //满足此条件换行
                if (_remainWidth <= 0 || _remainWidth <= 10 * 2) {
                    
                    _left = 15.f;
                    _remainWidth = frame.size.width - _left * 2;
                    _top = _labelBottom + 7 + SUITABLE_TOP;
                }
            }else
            {
                //都不满足换行
                _left = 15.f;
                _remainWidth = frame.size.width - _left * 2;
                _top = _labelBottom + 7 + SUITABLE_TOP;
                
                continue;//重新开始
            }
        }
        
        frame.size.height = _labelBottom;
        self.frame = frame;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
                  itemsArray:(NSArray *)itemsArray
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (itemsArray.count == 0) {
            return self;
        }
        
        NSMutableArray *temp = [NSMutableArray arrayWithArray:itemsArray];
        
        _top = 0;
        _left = SUITABLE_LEFT;
        
        CGFloat maxWidth = self.width - _left * 2;

        _remainWidth = maxWidth;

        CGFloat dis = SUITABLE_DIS;//间距
        
        while (temp.count > 0) {
            
            NSString *text = nil;
            CGFloat width = 0.f;
            
            BOOL isOK = NO;
            //查找符合宽度要求的title
            for (NSString *title in temp) {
                
                text = title;
                width = [LTools widthForText:title font:15.f];//字本身宽度
                width += 10 * 2;//左右各加10
                
                //最大边界
                if (width >= maxWidth) {
                    width = maxWidth;
                }
                
                if (width <= _remainWidth) { //适合
                    
                    isOK = YES;
                    break;//跳出for循环
                }
            }
            
            if (isOK) {
                UILabel *label = [self labelWithFrame:CGRectMake(_left, _top, width, 25) text:text];
                [self addSubview:label];
                _labelBottom = label.bottom;
                [temp removeObject:text];//移除掉
                
                _remainWidth -= (dis + width);//剩下的宽度
                _left = label.right + dis;
                
                //满足此条件换行
                if (_remainWidth <= 0 || _remainWidth <= 10 * 2) {
                    
                    _left = 15.f;
                    _remainWidth = frame.size.width - _left * 2;
                    _top = _labelBottom + 7;
                }
            }else
            {
                //都不满足换行
                _left = 15.f;
                _remainWidth = frame.size.width - _left * 2;
                _top = _labelBottom + 7;
                
                continue;//重新开始
            }
        }
        
        frame.size.height = _labelBottom;
        self.frame = frame;
    }
    return self;
}

- (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
{
    UIColor *textColor = [UIColor randomColorWithoutWhiteAndBlack];
    UILabel *label = [[UILabel alloc]initWithFrame:frame title:text font:11 align:NSTextAlignmentCenter textColor:textColor];
    [label setBorderWidth:0.5 borderColor:textColor];
    [label addCornerRadius:3.f];
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

@end
