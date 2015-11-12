//
//  GcycleScrollView1.h
//  YiYiProject
//
//  Created by gaomeng on 15/9/1.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"
@class SGFocusImageItem;
@class NewHuandengView;

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBCOLOR_ONE RGBCOLOR(arc4random()%255, arc4random()%255, arc4random()%255)
#define MY_MACRO_NAME ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
///屏幕宽度
#define DEVICE_WIDTH  [UIScreen mainScreen].bounds.size.width

#pragma mark - SGFocusImageFrameDelegate
@protocol NewHuandengViewDelegate1 <NSObject>
@optional
- (void)testfoucusImageFrame1:(NewHuandengView *)imageFrame didSelectItem:(SGFocusImageItem *)item;
- (void)testfoucusImageFrame1:(NewHuandengView *)imageFrame currentItem:(int)index;

@end


@interface GcycleScrollView1 : UIView
{
    BOOL _isAutoPlay;
}
- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate1>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto;
- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate1>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto pageControlNum:(NSInteger)num;

- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate1>)delegate focusImageItems:(SGFocusImageItem *)items, ... NS_REQUIRES_NIL_TERMINATION;

- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate1>)delegate imageItems:(NSArray *)items;

- (void)scrollToIndex:(int)aIndex;

-(void)setimageItems:(NSArray *)items;

@property(nonatomic,strong)UIImageView *sanJiaoImageView;
@property (nonatomic, assign) id<NewHuandengViewDelegate1> delegate;

@end
