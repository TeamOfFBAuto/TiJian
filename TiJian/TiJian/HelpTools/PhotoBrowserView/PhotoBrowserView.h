//
//  PhotoBrowserView.h
//  TestPhotoBrowser
//
//  Created by lichaowei on 15/4/3.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

///屏幕宽度
#define DEVICE_WIDTH  [UIScreen mainScreen].bounds.size.width
///屏幕高度
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PhotoBrowserView : UIView<UIScrollViewDelegate>
{
    NSInteger _pageIndex;
    NSInteger _itemIndex;
}
@property(nonatomic,retain)UIScrollView *imageScroll;
@property(nonatomic,retain)NSArray *imageArr;
@property(nonatomic,assign)NSInteger initPage;

-(instancetype)initWithFrame:(CGRect)frame
               withImagesArr:(NSArray *)imageArray
                    initPage:(int)initPage;

@end
