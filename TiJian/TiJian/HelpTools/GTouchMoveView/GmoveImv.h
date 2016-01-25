//
//  GmoveImv.h
//  testTouchMove
//
//  Created by gaomeng on 15/4/1.
//  Copyright (c) 2015年 gaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GmoveImvDelegate <NSObject>

- (void)theValue:(CGFloat)chooseValue;

@end

@interface GmoveImv : UIView
{
    CGPoint _startPoint;
}

@property(nonatomic,assign)id<GmoveImvDelegate>delegate;
@property(nonatomic,strong)NSString *imageName;

@property(nonatomic,assign)CGFloat targetX;//目标x


- (id)initWithFrame:(CGRect)frame imageName:(NSString*)imvName;

@end
