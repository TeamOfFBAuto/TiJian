//
//  GproductCommentView.h
//  TiJian
//
//  Created by gaomeng on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//


//商品评价oneView

#import <UIKit/UIKit.h>

#import "ProductCommentModel.h"

@interface GproductCommentView : UIView
{
    UIScrollView *_scrollView;
    ProductCommentModel* _theModel;
}

@property(nonatomic,assign)UIViewController *delegate;

-(CGFloat)loadCustomViewWithModel:(ProductCommentModel*)model;

@end
