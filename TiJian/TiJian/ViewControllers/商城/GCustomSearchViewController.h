//
//  GCustomSearchViewController.h
//  TiJian
//
//  Created by gaomeng on 16/1/13.
//  Copyright © 2016年 lcw. All rights reserved.
//


/**
 *  搜索界面
 */
#import "MyViewController.h"

@interface GCustomSearchViewController : MyViewController

@property(nonatomic,strong)UITextField *searchTf;//搜索栏输入框;

//navigationbar ios11
@property(nonatomic,strong)UIView *searchView;
@property(nonatomic,strong)UIView *kuangView;
@property(nonatomic,strong)UIButton *myNavcRightBtn;
@property(nonatomic,assign)int editState;
@property(nonatomic,strong)UIPanGestureRecognizer *panGestureRecognizer;


-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot;

-(void)setEffectViewAlpha:(CGFloat)theAlpha;

-(void)myNavcRightBtnClicked;

@end
