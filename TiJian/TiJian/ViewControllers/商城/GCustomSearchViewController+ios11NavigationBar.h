//
//  GCustomSearchViewController+ios11NavigationBar.h
//  TiJian
//
//  Created by gaomeng on 2017/12/11.
//  Copyright © 2017年 lcw. All rights reserved.
//

#import "GCustomSearchViewController.h"

@interface GCustomSearchViewController (ios11NavigationBar)<UITextFieldDelegate>
/**
 自定义导航栏
 */
-(void)setUpNavitationBar;

-(void)changeNavigationBarSearchViewState:(int)state;
@end
