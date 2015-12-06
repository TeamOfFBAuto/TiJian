//
//  PhotoBrowserView.m
//  TestPhotoBrowser
//
//  Created by lichaowei on 15/4/3.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "PhotoBrowserView.h"
#import "ZoomScrollView.h"

#define kCurrentTag 1000
#define kNextTag 1001
#define kLastTag 1002

@implementation PhotoBrowserView

-(instancetype)initWithFrame:(CGRect)frame withImagesArr:(NSArray *)imageArray initPage:(int)initPage
{
    self = [super initWithFrame:frame];
    if (self) {
        
        initPage --;
        
        self.imageArr = [NSArray arrayWithArray:imageArray];
        NSLog(@"个数%d",(int)imageArray.count);
        self.imageScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageScroll.contentSize = CGSizeMake(frame.size.width * (imageArray.count), frame.size.height);
        _imageScroll.backgroundColor = [UIColor orangeColor];
        _imageScroll.showsHorizontalScrollIndicator = NO;
        _imageScroll.showsVerticalScrollIndicator = NO;
        _imageScroll.delegate = self;
        _imageScroll.pagingEnabled = YES;
        _imageScroll.scrollEnabled = YES;
        _imageScroll.bounces = NO;
        _imageScroll.contentOffset = CGPointMake(_imageScroll.frame.size.width*initPage, 0);
        [self addSubview:_imageScroll];
        if (_initPage == 0) {
            [self configScrowViewWithIndex:initPage withForward:NO withOrigin:YES];
        }else
        {
            [self configScrowViewWithIndex:initPage withForward:NO withOrigin:YES];
        }
        _pageIndex = _itemIndex = initPage;
    }
    return self;
}

-(void)setInitPage:(NSInteger)initPage
{
    [self configScrowViewWithIndex:initPage withForward:NO withOrigin:YES];
}

#pragma mark - configScrollView

//根据页数,创建imageView
- (ZoomScrollView *)configItemWithIndex:(NSInteger)pageIndex
{
    if (pageIndex < 0 || pageIndex > [_imageArr count]-1) {
        NSLog(@"图片个数:%d",(int)_imageArr.count);
        return nil;
    }
    ZoomScrollView *firstView = [[ZoomScrollView alloc]initWithFrame:CGRectMake(_imageScroll.frame.size.width*pageIndex, 0, _imageScroll.frame.size.width, _imageScroll.frame.size.height) ];
//    NSURL *url = [NSURL URLWithString:[_imageArr objectAtIndex:pageIndex]];
    id image = [_imageArr objectAtIndex:pageIndex];
    if ([image isKindOfClass:[UIImage class]]) {
        firstView.imageView.image = image;
    }else
    {
        
        [firstView.imageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:DEFAULT_HEADIMAGE completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
//        [firstView.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"car.png"] success:^(UIImage *image) {
//            [self imageFinishDownLoad];
//        } failure:^(NSError *error) {
//            NSLog(@"图片错误");
//        }];
    }
    
 
    return firstView;
}

- (void)imageFinishDownLoad
{
    NSLog(@"下载完成");
}
//配置index 第几页 forward是否向前滑动 origin,是否第一次
- (void)configScrowViewWithIndex:(NSInteger)index withForward:(BOOL)isForward withOrigin:(BOOL)isOrigin
{
    if ([_imageArr count] < 1) {
        return;
    }
    //当偏移量是0的话加载当前的索引的视图和前后的视图（如果存在的话）
    if (isOrigin) {
        ZoomScrollView *currentView = [self configItemWithIndex:index];
        if (currentView) {
            currentView.tag = kCurrentTag;
            [_imageScroll addSubview:currentView];
            
        }
        
        ZoomScrollView *nextView = [self configItemWithIndex:index+1];
        if (nextView) {
            nextView.tag = kNextTag;
            [_imageScroll addSubview:nextView];
            
        }
        ZoomScrollView *lastView = [self configItemWithIndex:index-1];
        if(lastView)
        {
            lastView.tag = kLastTag;
            [_imageScroll addSubview:lastView];
        }
        
    }
    else {
        //如果向前滑动的话，加载下一张试图的后一张试图，同时移除上一张试图的前一张试图
        if (isForward) {
            if ([_imageScroll viewWithTag:kLastTag])
            {
                //                UIImageView *view = (UIImageView*)[_imageScroll viewWithTag:kLastTag];
                //                [view cancelCurrentImageLoad];
                
                [[_imageScroll viewWithTag:kLastTag]removeFromSuperview];//移出前一个视图
            }
            if ([_imageScroll viewWithTag:kNextTag])
            {
                //如果下个视图存在
                UIView *currentView = [_imageScroll viewWithTag:kCurrentTag];
                currentView.tag = kLastTag;
                UIView *view =  [_imageScroll viewWithTag:kNextTag];
                view.tag = kCurrentTag;
                
                ZoomScrollView *nextView = [self configItemWithIndex:index+1];
                if (nextView) {
                    nextView.tag = kNextTag;
                    [_imageScroll addSubview:nextView];
                }
                
            }
        }
        //如果向后滑动的话，加载上一张试图的前一张试图，同时移除下一张试图的后一张试图
        else {
            if ([_imageScroll viewWithTag:kNextTag]) {
                [[_imageScroll viewWithTag:kNextTag]removeFromSuperview];//移出后一个视图
                //                UIImageView *view = (UIImageView*)[_imageScroll viewWithTag: kNextTag];
                //                [view cancelCurrentImageLoad];
            }
            if ([_imageScroll viewWithTag:kLastTag]) { //如果上个视图存在
                UIView *currentView = [_imageScroll viewWithTag:kCurrentTag];
                currentView.tag = kNextTag;
                UIView *view =  [_imageScroll viewWithTag:kLastTag];
                view.tag     = kCurrentTag;
                ZoomScrollView *lastView = [self configItemWithIndex:index-1];
                if (lastView) {
                    lastView.tag = kLastTag;
                    [_imageScroll addSubview:lastView];
                }
            }
            
        }
        
    }
    
}
#pragma mark UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int beforeIndex = (int)_pageIndex;
    _pageIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;//只要大于半页就算下一页
    if (_pageIndex>beforeIndex) {
        _itemIndex ++;
        [self configScrowViewWithIndex:_itemIndex withForward:YES withOrigin:NO];
    }
    else if(_pageIndex<beforeIndex) {
        _itemIndex --;
        [self configScrowViewWithIndex:_itemIndex withForward:NO withOrigin:NO];
        
    }
//    [self hiddenNavigationBar];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

}



@end
