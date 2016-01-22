//
//  GUpToolView.m
//  TiJian
//
//  Created by gaomeng on 16/1/22.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GUpToolView.h"

@implementation GUpToolView


-(id)initWithFrame:(CGRect)frame count:(int)theCount{
    self = [super initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
    if (self) {
        if (theCount == 2) {
            [self creat2Btn];
        }else if (theCount == 3){
            [self creat3btn];
        }
    }
    
    return self;
}





-(void)creat2Btn{
    [self setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
    self.backgroundColor = [UIColor whiteColor];
    
    NSArray *titleArray = @[@"搜索",@"首页"];
    NSArray *imageArray = @[[UIImage imageNamed:@"uptool_search.png"],[UIImage imageNamed:@"uptool_homepage.png"]];
    
    for (int i = 0; i<2; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat w = DEVICE_WIDTH/2;
        [btn setTitleColor:RGBCOLOR(152, 153, 154) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.tag = 20+i;
        [btn setFrame:CGRectMake(i*w, 0, w, 50)];
        [self addSubview:btn];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn setImage:imageArray[i] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, -25, 0)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 18, 25, 0)];
        [btn addTarget:self action:@selector(upToolBtnClicked1:) forControlEvents:UIControlEventTouchUpInside];
    }
}


-(void)creat3btn{
    [self setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
    self.backgroundColor = [UIColor whiteColor];
    NSArray *titleArray = @[@"足迹",@"搜索",@"首页"];
    NSArray *imageArray = @[[UIImage imageNamed:@"uptool_zuji.png"],[UIImage imageNamed:@"uptool_search.png"],[UIImage imageNamed:@"uptool_homepage.png"]];
    for (int i = 0; i<3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:RGBCOLOR(152, 153, 154) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        CGFloat w = DEVICE_WIDTH/3;
        btn.tag = 10+i;
        [btn setFrame:CGRectMake(i*w, 0, DEVICE_WIDTH/3, 50)];
        [self addSubview:btn];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn setImage:imageArray[i] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, -25, 0)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 18, 25, 0)];
        [btn addTarget:self action:@selector(upToolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }

}


-(void)setUpToolViewBlock:(upToolViewBlock)upToolViewBlock{
    _upToolViewBlock = upToolViewBlock;
}


-(void)upToolBtnClicked:(UIButton*)sender{
    self.upToolViewBlock(sender.tag);
}


@end
