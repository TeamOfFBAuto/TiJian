//
//  RefreshHeaderView.h
//  TiJian
//
//  Created by lichaowei on 15/9/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOViewCommon.h"

@interface RefreshHeaderView : UIView
{
    L_EGOPullRefreshState _state;
    
    UILabel *_lastUpdatedLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImage;
    UIActivityIndicatorView *_activityView;
}

@property(nonatomic,weak)id<L_EGORefreshTableDelegate>delegate;

- (id)initWithFrame:(CGRect)frame
     arrowImageName:(NSString *)arrow
          textColor:(UIColor *)textColor;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
                                              completion:(void(^)())completion;
- (void)setState:(L_EGOPullRefreshState)aState;

@end
