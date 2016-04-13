//
//  ActivityView.m
//  TiJian
//
//  Created by lichaowei on 16/1/11.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "ActivityView.h"
#import "ActivityModel.h"

@interface ActivityView ()<UIScrollViewDelegate>
{
    NSInteger _currentPage;//当前页数
    BOOL _show;//是否在显示
}

@property(nonatomic,retain)UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation ActivityView
{
    __block UIButton *bigImageBtn;
    UIButton *_clostBtn;
    CGFloat _realHeight;//图片显示高度
    ActionBlock _actionBlock;//回调block
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    }
    return self;
}


-(id)initWithActivityArray:(NSArray *)itemArray
               actionBlock:(void (^)(ActionStyle style,NSInteger index))actionBlock
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Initialization code
        
        if (actionBlock) {
            _actionBlock = actionBlock;
        }
        
        self.frame = [UIScreen mainScreen].bounds;
        self.window.windowLevel = UIAlertViewStyleDefault;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        CGFloat width = 570 / 2.f;
        CGFloat height = 760 / 2.f;
        
        
        width = FitScreen(width);
        height = FitScreen(height);
        if (iPhone4) {
            
            width *= 0.85;
            height *= 0.85;
        }
        CGFloat top = (DEVICE_HEIGHT - height) / 2.f - 20;
        CGFloat left = (DEVICE_WIDTH - width) / 2.f;
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(left, top, width, height)];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
//        self.scrollView.bounces = NO;
        self.scrollView.decelerationRate = 0.1;
        [self addSubview:self.scrollView];
        
        [self.scrollView addCornerRadius:5.f];
        self.scrollView.clipsToBounds = YES;
        self.scrollView.backgroundColor = [UIColor clearColor];
        
        //加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickAtIndex:)];
        [self.scrollView addGestureRecognizer:tap];
        
        //点击空白关闭
        UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidden)];
        [self addGestureRecognizer:closeTap];
        
        //
        int count = (int)itemArray.count;
        
        for (int i = 0;i < count;i ++) {
            
            ActivityModel *aModel = itemArray[i];
            UIImageView *item = [[UIImageView alloc]initWithFrame:CGRectMake(width * i, 0, width, height)];
            [_scrollView addSubview:item];
            [item l_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
            _scrollView.contentSize = CGSizeMake(width * count, height);
//            item.backgroundColor = [UIColor redColor];
        }
        
        if (count > 1) {
            [self addSubview:self.pageControl];
            self.pageControl.numberOfPages = count;
        }
        
        //右上角关闭按钮
        
        _clostBtn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 27 - 15 + 2, 20 + (49 - 30)/2.f - 5, 30, 30) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"homepage_close"] selectedImage:nil target:self action:@selector(clickToClose:)];
        [self addSubview:_clostBtn];
        _clostBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        
    }
    return self;
}

#pragma mark - getter

- (UIPageControl *)pageControl {
    if (nil == _pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _scrollView.bottom - 30, self.width, 30)];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
        _pageControl.currentPageIndicatorTintColor = DEFAULT_TEXTCOLOR;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

#pragma - mark 事件处理

- (void)clickAtIndex:(UITapGestureRecognizer *)tap
{
    [self hidden];
    
    _show = YES;
    if (_actionBlock) {
        _actionBlock(ActionStyle_Select,_currentPage);
    }
}

- (void)clickToClose:(UIButton *)sender
{
    [self hidden];
    
    if (_actionBlock) {
        _actionBlock(ActionStyle_Close,0);//关闭
    }
}

- (void)show
{
    _show = YES;
    UIView *root = [UIApplication sharedApplication].keyWindow;
    [root addSubview:self];
    
    @WeakObj(_scrollView);
    [UIView animateWithDuration:0.3 animations:^{
        
        _clostBtn.alpha = 1.f;
        self.alpha = 1.0;
        Weak_scrollView.alpha = 1.f;
    }];
}

- (void)updateShowWithViewWillAppear
{
    if (_show) {
        
        [self show];
    }
}

- (void)showWithView:(UIView *)view
{
    if (nil == view) {
        return;
    }
    _show = YES;

    [view addSubview:self];
    
    @WeakObj(_scrollView);
    [UIView animateWithDuration:0.3 animations:^{
        
        _clostBtn.alpha = 1.f;
        self.alpha = 1.0;
        Weak_scrollView.alpha = 1.f;
    }];
}

- (void)hidden
{
    _show = NO;
    
     @WeakObj(_scrollView);
    [UIView animateWithDuration:0.3 animations:^{
        
        _clostBtn.alpha = 0.f;
        self.alpha = 0.f;
        Weak_scrollView.alpha = 0.f;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 
#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger index = scrollView.contentOffset.x/CGRectGetWidth(self.scrollView.frame);
    self.pageControl.currentPage = index;
    _currentPage = index;
}


@end
