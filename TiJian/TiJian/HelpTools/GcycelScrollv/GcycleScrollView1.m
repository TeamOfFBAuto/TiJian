//
//  GcycleScrollView1.m
//  YiYiProject
//
//  Created by gaomeng on 15/9/1.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GcycleScrollView1.h"
#import "SGFocusImageItem.h"
#import <objc/runtime.h>


@interface GcycleScrollView1 () {
    UIScrollView *_scrollView;
    SMPageControl *_pagecontrol;
    UILabel *greenlabel;
}

- (void)setupViews;
- (void)switchFocusImageItems;
@end

static NSString *SG_FOCUS_ITEM_ASS_KEY = @"loopScrollview";

static CGFloat SWITCH_FOCUS_PICTURE_INTERVAL = 3.0; //switch interval time

@implementation GcycleScrollView1

- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate1>)delegate focusImageItems:(SGFocusImageItem *)firstItem, ...
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

- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate1>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto
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
- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate1>)delegate imageItems:(NSArray *)items
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


- (id)initWithFrame:(CGRect)frame delegate:(id<NewHuandengViewDelegate1>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto pageControlNum:(NSInteger)num
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
    _scrollView.showsVerticalScrollIndicator = NO;
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
    _scrollView.contentSize = CGSizeMake(self.frame.size.width, _scrollView.frame.size.height*imageItems.count);
    
    
    
    
    for (int i = 0; i < imageItems.count; i++) {
//        NSLog(@"%@",NSStringFromCGRect(self.bounds));
        
        SGFocusImageItem *item = [imageItems objectAtIndex:i];
        
        
        [self loadCustomViewWithItems:item index:i];
        

        
    }
    [tapGestureRecognize release];
    if ([imageItems count]>1)
    {
        [_scrollView setContentOffset:CGPointMake(0, self.frame.size.height) animated:NO] ;
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
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, i*self.frame.size.height, self.frame.size.width,self.frame.size.height)];
        SGFocusImageItem *item = [imageItems objectAtIndex:i];
        [imv l_setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:DEFAULT_YIJIAYI];
        [_scrollView addSubview:imv];
        [imv release];
        
        
    }
    [tapGestureRecognize release];
    if ([imageItems count]>1)
    {
        [_scrollView setContentOffset:CGPointMake(0, self.frame.size.height) animated:NO] ;
        if (_isAutoPlay)
        {
            [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:SWITCH_FOCUS_PICTURE_INTERVAL];
        }
        
    }
    
    
    
}


-(void)loadCustomViewWithItems:(SGFocusImageItem*)item index:(NSInteger)i{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, i*self.frame.size.height, self.frame.size.width,self.frame.size.height)];
//    backView.backgroundColor = RGBCOLOR_ONE;
    backView.backgroundColor = RGBCOLOR(241, 242, 244);
    [_scrollView addSubview:backView];
    
    
    //图片
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width*0.3, self.frame.size.height)];
    imv.clipsToBounds = YES;
    imv.contentMode = UIViewContentModeCenter;
    [imv sd_setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:DEFAULT_YIJIAYI];
    [backView addSubview:imv];
    [imv release];
    
    //内容
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+5, 0, self.frame.size.width - imv.frame.size.width - 10, imv.frame.size.height *2.0/3.0)];
    titleLabel.text = item.title;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.numberOfLines = 2;
    [backView addSubview:titleLabel];
    [titleLabel release];
    
    //距离
    UILabel *juliLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame), titleLabel.frame.size.width /3.0, titleLabel.frame.size.height *0.5)];
    
    if ([item.link floatValue]>=1000) {
        CGFloat aa = [item.link floatValue];
        juliLabel.text = [NSString stringWithFormat:@"%.1fkm",aa*0.001];
    }else{
        juliLabel.text = [NSString stringWithFormat:@"%.1fm",[item.link floatValue]];
    }
    
    juliLabel.font = [UIFont systemFontOfSize:11];
    juliLabel.textColor = RGBCOLOR(79, 80, 81);
    [backView addSubview:juliLabel];
    [juliLabel release];
    
    //地址
    UILabel *adressLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(juliLabel.frame), juliLabel.frame.origin.y, juliLabel.frame.size.width*2, juliLabel.frame.size.height)];
    adressLabel.textAlignment = NSTextAlignmentRight;
    adressLabel.text = item.type;
    adressLabel.font = [UIFont systemFontOfSize:11];
    adressLabel.textColor = RGBCOLOR(79, 80, 81);
    [backView addSubview:adressLabel];
    [adressLabel release];
}





- (void)switchFocusImageItems
{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
    
    CGFloat targetY = _scrollView.contentOffset.y + _scrollView.frame.size.height;
    NSArray *imageItems = objc_getAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY);
    targetY = (int)(targetY/self.frame.size.height) * self.frame.size.height;
    [self moveToTargetPosition:targetY];
    
    if ([imageItems count]>1 && _isAutoPlay)
    {
        [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:SWITCH_FOCUS_PICTURE_INTERVAL];
    }
    
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    
    NSArray *imageItems = objc_getAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY);
    int page = (int)(_scrollView.contentOffset.y / _scrollView.frame.size.height);
    if (page > -1 && page < imageItems.count) {
        SGFocusImageItem *item = [imageItems objectAtIndex:page];
        if ([self.delegate respondsToSelector:@selector(testfoucusImageFrame1:didSelectItem:)]) {
            [self.delegate testfoucusImageFrame1:self didSelectItem:item];
        }
    }
    
    
}






- (void)moveToTargetPosition:(CGFloat)targetY
{
    BOOL animated = YES;
    [_scrollView setContentOffset:CGPointMake(0, targetY) animated:animated];
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float targetY = scrollView.contentOffset.y;
    NSArray *imageItems = objc_getAssociatedObject(self, (const void *)SG_FOCUS_ITEM_ASS_KEY);
    if ([imageItems count]>=3)
    {
        if (targetY >= self.frame.size.height * ([imageItems count] -1)) {
            targetY = self.frame.size.height;
            [_scrollView setContentOffset:CGPointMake(0, targetY) animated:NO];
        }
        else if(targetY <= 0)
        {
            targetY = self.frame.size.height *([imageItems count]-2);
            [_scrollView setContentOffset:CGPointMake(0, targetY) animated:NO];
        }
    }
    int page = (_scrollView.contentOffset.y+self.frame.size.height/2.0) / self.frame.size.height;
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
    _sanJiaoImageView.center=CGPointMake(148+13,237+14*_scrollView.contentOffset.y/self.frame.size.height);
    
    
    _pagecontrol.currentPage = page;
    
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        CGFloat targetY = _scrollView.contentOffset.y + _scrollView.frame.size.height;
        targetY = (int)(targetY/self.frame.size.height) * self.frame.size.height;
        [self moveToTargetPosition:targetY];
        
        
        
        
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
        [self moveToTargetPosition:self.frame.size.height*(aIndex+1)];
    }else
    {
        [self moveToTargetPosition:0];
    }
    [self scrollViewDidScroll:_scrollView];
    
}


-(void)setimageItems:(NSArray *)items{
    
}

@end
