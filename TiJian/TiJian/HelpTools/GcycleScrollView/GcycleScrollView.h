//
//  GcycleScrollView.h
//  TiJian
//
//  Created by gaomeng on 15/10/27.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"
#import "SGFocusImageItem.h"
@class GcycleScrollView;

@protocol GcycleScrollViewDelegate <NSObject>
@optional
- (void)testfoucusImageFrame:(GcycleScrollView *)imageFrame didSelectItem:(SGFocusImageItem *)item;
- (void)testfoucusImageFrame:(GcycleScrollView *)imageFrame currentItem:(int)index;
@end


@interface GcycleScrollView : UIView
{
    BOOL _isAutoPlay;
}
- (id)initWithFrame:(CGRect)frame delegate:(id<GcycleScrollViewDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto;
- (id)initWithFrame:(CGRect)frame delegate:(id<GcycleScrollViewDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto pageControlNum:(NSInteger)num;

- (id)initWithFrame:(CGRect)frame delegate:(id<GcycleScrollViewDelegate>)delegate focusImageItems:(SGFocusImageItem *)items, ... NS_REQUIRES_NIL_TERMINATION;

- (id)initWithFrame:(CGRect)frame delegate:(id<GcycleScrollViewDelegate>)delegate imageItems:(NSArray *)items;

- (void)scrollToIndex:(int)aIndex;

-(void)setimageItems:(NSArray *)items;

@property(nonatomic,strong)UIImageView *sanJiaoImageView;
@property (nonatomic, assign) id<GcycleScrollViewDelegate> delegate;

@end
