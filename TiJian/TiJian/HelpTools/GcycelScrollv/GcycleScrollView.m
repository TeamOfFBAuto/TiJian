//
//  GcycleScrollView.m
//  gcycleScrollview
//
//  Created by gaomeng on 15/9/1.
//  Copyright (c) 2015年 gaomeng. All rights reserved.
//

#import "GcycleScrollView.h"
#import "SGFocusImageItem.h"
#import <objc/runtime.h>

@interface GcycleScrollView () {
    UIScrollView *_scrollView;
    SMPageControl *_pagecontrol;
    UILabel *greenlabel;
}

- (void)setupViews;
- (void)switchFocusImageItems;
@end


static NSString *SG_FOCUS_ITEM_ASS_KEY = @"loopScrollview";

static CGFloat SWITCH_FOCUS_PICTURE_INTERVAL = 4.0; //switch interval time


@implementation GcycleScrollView

- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate>)delegate focusImageItems:(SGFocusImageItem *)firstItem, ...
{
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableArray *imageItems = [NSMutableArray array];
        SGFocusImageItem *eachItem;
        va_list argumentList;
        if (firstItem)
        {
            [imageItems addObject: firstItem];
            va_start(argumentList, firstItem);
            while((eachItem = va_arg(argumentList, SGFocusImageItem *)))
            {
                [imageItems addObject: eachItem];
            }
            va_end(argumentList);
        }
        
        objc_setAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY, imageItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        _isAutoPlay = YES;
        [self setupViews];
        
        [self setDelegate:delegate];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSMutableArray *imageItems = [NSMutableArray arrayWithArray:items];
        objc_setAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY, imageItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        _isAutoPlay = YES;
        [self setupViews];
        
        [self setDelegate:delegate];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate>)delegate imageItems:(NSArray *)items
{
    return [self initWithFrame:frame delegate:delegate imageItems:items isAuto:YES];
}

- (void)dealloc
{
    objc_setAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _scrollView.delegate = nil;
    [_scrollView release];
    [_pagecontrol release];
    [greenlabel release];
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto pageControlNum:(NSInteger)num
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        NSMutableArray *imageItems = [NSMutableArray arrayWithArray:items];
        objc_setAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY, imageItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        _isAutoPlay = YES;
        [self setupViewsWithPageControl:num];
        
        [self setDelegate:delegate];
    }
    return self;
}


#pragma mark - private methods

-(void)setupViewsWithPageControl:(NSInteger)num{
    NSArray *imageItems = objc_getAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY);
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor=[UIColor clearColor];
    _scrollView.scrollsToTop = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    
    [self addSubview:_scrollView];
    
    //pagecontrol
    _pagecontrol = [[SMPageControl alloc]initWithFrame:CGRectMake(-4, 1,  DEVICE_WIDTH-255, 25)];
    _pagecontrol.backgroundColor = [UIColor clearColor];
    _pagecontrol.numberOfPages = num;
    if (num == 0) {
        _pagecontrol.hidden = YES;
    }
    _pagecontrol.indicatorMargin=8.0f;
    [_pagecontrol setPageIndicatorImage:[UIImage imageNamed:@"roundgray.png"]];
    [_pagecontrol setCurrentPageIndicatorImage:[UIImage imageNamed:@"roundblue.png"]];
    _pagecontrol.center=CGPointMake(DEVICE_WIDTH*0.5, self.frame.size.height - 10);
    _pagecontrol.currentPage = 0;
    [self addSubview:_pagecontrol];
    
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:tapGestureRecognize];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * imageItems.count, _scrollView.frame.size.height);
    
    for (int i = 0; i < imageItems.count; i++) {
//        NSLog(@"%@",NSStringFromCGRect(self.bounds));
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.frame.size.width, 0, self.frame.size.width,self.frame.size.height)];
        imv.backgroundColor = RGBCOLOR_ONE;
        SGFocusImageItem *item = [imageItems objectAtIndex:i];
        [imv l_setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:DEFAULT_YIJIAYI];
        [_scrollView addSubview:imv];
        [imv release];
        
        
    }
    [tapGestureRecognize release];
    if ([imageItems count]>1)
    {
        [_scrollView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO] ;
        if (_isAutoPlay)
        {
            [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:SWITCH_FOCUS_PICTURE_INTERVAL];
        }
        
    }
}

- (void)setupViews
{
    NSArray *imageItems = objc_getAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY);
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor=[UIColor clearColor];
    _scrollView.scrollsToTop = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;

    [self addSubview:_scrollView];
    
    //pagecontrol
    _pagecontrol = [[SMPageControl alloc]initWithFrame:CGRectMake(-4, 1,  DEVICE_WIDTH-255, 25)];
    _pagecontrol.backgroundColor = [UIColor clearColor];
    _pagecontrol.numberOfPages = 2;
    _pagecontrol.indicatorMargin=8.0f;
    [_pagecontrol setPageIndicatorImage:[UIImage imageNamed:@"roundgray.png"]];
    [_pagecontrol setCurrentPageIndicatorImage:[UIImage imageNamed:@"roundblue.png"]];
    _pagecontrol.center=CGPointMake(DEVICE_WIDTH*0.5, self.frame.size.height - 10);
    _pagecontrol.currentPage = 0;
    [self addSubview:_pagecontrol];
    

    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:tapGestureRecognize];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * imageItems.count, _scrollView.frame.size.height);
    
    for (int i = 0; i < imageItems.count; i++) {
//        NSLog(@"%@",NSStringFromCGRect(self.bounds));
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(i*DEVICE_WIDTH, 0, DEVICE_WIDTH,(int)(DEVICE_WIDTH*250/750))];
        imv.backgroundColor = RGBCOLOR_ONE;
        SGFocusImageItem *item = [imageItems objectAtIndex:i];
        [imv l_setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:DEFAULT_YIJIAYI];
        [_scrollView addSubview:imv];
        [imv release];
        
        
    }
    [tapGestureRecognize release];
    if ([imageItems count]>1)
    {
        [_scrollView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO] ;
        if (_isAutoPlay)
        {
            [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:SWITCH_FOCUS_PICTURE_INTERVAL];
        }
        
    }
    
    
    
}

- (void)switchFocusImageItems
{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
    
    CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
    NSArray *imageItems = objc_getAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY);
    targetX = (int)(targetX/self.frame.size.width) * self.frame.size.width;
    [self moveToTargetPosition:targetX];
    
    if ([imageItems count]>1 && _isAutoPlay)
    {
        [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:SWITCH_FOCUS_PICTURE_INTERVAL];
    }
    
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
//    NSLog(@"%s", __FUNCTION__);
    
    NSArray *imageItems = objc_getAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY);
    int page = (int)(_scrollView.contentOffset.x / _scrollView.frame.size.width);
    if (page > -1 && page < imageItems.count) {
        SGFocusImageItem *item = [imageItems objectAtIndex:page];
        if ([self.delegate respondsToSelector:@selector(testfoucusImageFrame:didSelectItem:)]) {
            [self.delegate testfoucusImageFrame:self didSelectItem:item];
        }
    }
    
    
}






- (void)moveToTargetPosition:(CGFloat)targetX
{
    BOOL animated = YES;
    //    NSLog(@"moveToTargetPosition : %f" , targetX);
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float targetX = scrollView.contentOffset.x;
    NSArray *imageItems = objc_getAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY);
    if ([imageItems count]>=3)
    {
        if (targetX >= self.frame.size.width * ([imageItems count] -1)) {
            targetX = self.frame.size.width;
            [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
        else if(targetX <= 0)
        {
            targetX = self.frame.size.width *([imageItems count]-2);
            [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
    }
    int page = (_scrollView.contentOffset.x+self.frame.size.width/2.0) / self.frame.size.width;
    if ([imageItems count] > 1)
    {
        
        
        SGFocusImageItem *item = [imageItems objectAtIndex:page];
        
        greenlabel.text=item.title;
        page --;
        if (page >= _pagecontrol.numberOfPages)
        {
            page = 0;
        }else if(page <0)
        {
            page = _pagecontrol.numberOfPages -1;
        }
    }
    if (page!= _pagecontrol.currentPage)
    {
        if ([self.delegate respondsToSelector:@selector(testfoucusImageFrame:currentItem:)])
        {
            [self.delegate testfoucusImageFrame:self currentItem:page];
        }
    }
    _sanJiaoImageView.center=CGPointMake(237+14*_scrollView.contentOffset.x/DEVICE_WIDTH, 148+13);
    
    
    _pagecontrol.currentPage = page;
    
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
        targetX = (int)(targetX/self.frame.size.width) * self.frame.size.width;
        [self moveToTargetPosition:targetX];
        
        
        
        
    }
}


- (void)scrollToIndex:(int)aIndex
{
    NSArray *imageItems = objc_getAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY);
    if ([imageItems count]>1)
    {
        if (aIndex >= ([imageItems count]-2))
        {
            aIndex = [imageItems count]-3;
        }
        [self moveToTargetPosition:self.frame.size.width*(aIndex+1)];
    }else
    {
        [self moveToTargetPosition:0];
    }
    [self scrollViewDidScroll:_scrollView];
    
}


-(void)setimageItems:(NSArray *)items{
    
}



@end
