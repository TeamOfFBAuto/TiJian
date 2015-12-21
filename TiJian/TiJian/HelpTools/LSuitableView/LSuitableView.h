//
//  LSuitableView.h
//  TiJian
//
//  Created by lichaowei on 15/12/21.
//  Copyright © 2015年 lcw. All rights reserved.

/**
 *  根据宽度自动布局
 */

#import <UIKit/UIKit.h>

@interface LSuitableView : UIView

-(instancetype)initWithFrame:(CGRect)frame
                  itemsArray:(NSArray *)itemsArray;

@end
