//
//  GTouchMoveView.h
//  scrollDemo
//
//  Created by gaomeng on 15/10/21.
//  Copyright © 2015年 gaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GmoveImv.h"

@interface GTouchMoveView : UIView<GmoveImvDelegate>



@property(nonatomic,strong)NSString *theValue;//值

/**
 *  初始化方法
 *  @param frame    最小height为53
 *  @param theColor   进度条颜色
 *  @param theTitle   左下角文字
 *  @param theRangeLow 最低范围
 *  @param theRangeHigh 最高范围
 *  @param imvName 下面滑块的图片名称
 *  @param theCustomValue 初始值
 */
-(id)initWithFrame:(CGRect)frame color:(UIColor *)theColor title:(NSString *)theTitle rangeLow:(int)theRangeLow rangeHigh:(int)theRangeHigh imageName:(NSString*)imvName;


//设置滑块位置
-(void)setCustomValueWithStr:(NSString *)value;

@end
