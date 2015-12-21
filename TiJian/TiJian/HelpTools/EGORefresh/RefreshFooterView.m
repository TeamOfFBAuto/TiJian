//
//  RefreshFooterView.m
//  TiJian
//
//  Created by lichaowei on 15/12/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "RefreshFooterView.h"

#define NORMAL_TEXT @"上拉加载更多"
#define NOMORE_TEXT @"没有更多数据"

@interface RefreshFooterView()

@property(nonatomic,retain)UIActivityIndicatorView *loadingIndicator;
@property(nonatomic,retain)UILabel *normalLabel;
@property(nonatomic,retain)UILabel *loadingLabel;

@end

@implementation RefreshFooterView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.loadingIndicator];
        [self addSubview:self.loadingLabel];
//        [self addSubview:self.normalLabel];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma - mark 创建所需label 和 UIActivityIndicatorView

- (UIActivityIndicatorView*)loadingIndicator
{
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingIndicator.hidden = YES;
        _loadingIndicator.backgroundColor = [UIColor clearColor];
        _loadingIndicator.hidesWhenStopped = YES;
        _loadingIndicator.frame = CGRectMake(self.frame.size.width/2 - 70 ,6+2 + (self.height - 40)/2.0, 24, 24);
    }
    return _loadingIndicator;
}

//- (UILabel*)normalLabel
//{
//    if (!_normalLabel) {
//        _normalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8 + (self.height - 40)/2.0, self.frame.size.width, 20)];
//        _normalLabel.text = NSLocalizedString(NORMAL_TEXT, nil);
//        _normalLabel.backgroundColor = [UIColor clearColor];
//        [_normalLabel setFont:[UIFont systemFontOfSize:14]];
//        _normalLabel.textAlignment = NSTextAlignmentCenter;
//        [_normalLabel setTextColor:[UIColor darkGrayColor]];
//    }
//    
//    return _normalLabel;
//    
//}

- (UILabel*)loadingLabel
{
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,8 + (self.height - 40)/2.0, self.frame.size.width, 20)];
        _loadingLabel.text = NSLocalizedString(NORMAL_TEXT, nil);
        _loadingLabel.backgroundColor = [UIColor clearColor];
        [_loadingLabel setFont:[UIFont systemFontOfSize:14]];
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        [_loadingLabel setTextColor:[UIColor darkGrayColor]];
    }
    
    return _loadingLabel;
}

#pragma mark - 控制加载状态

- (void)startLoading
{
    [self.loadingIndicator startAnimating];
    [self.loadingLabel setHidden:NO];
}

- (void)stopLoadingMoreStyle:(RefreshLoadingMoreStyle)loadingStyle
{
    [self.loadingIndicator stopAnimating];
    switch (loadingStyle) {
        case RefreshLoadingMoreStyleDefault:
            [self.normalLabel setText:NSLocalizedString(NORMAL_TEXT, nil)];
            break;
        case RefreshLoadingMoreStyleNoMore: //没有更多数据
            [self.normalLabel setText:NSLocalizedString(NOMORE_TEXT, nil)];
            break;
        case RefreshLoadingMoreStyleNoMoreAndHidden: //没有更多数据时不显示
            [self.normalLabel setHidden:YES];
            break;
        default:
            break;
    }
}

@end
