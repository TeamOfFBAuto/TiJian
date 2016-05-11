//
//  GView.m
//  TiJian
//
//  Created by gaomeng on 16/5/10.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GView.h"

@implementation GView

-(void)setClassViewClickedBlock:(classViewClickedBlock)classViewClickedBlock{
    _classViewClickedBlock = classViewClickedBlock;
}

-(id)initWithFrame:(CGRect)frame tag:(int)theTag type:(ClassViewType)theType{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.tag = theTag;
        
        if (theType == ClassViewType_qiyetijian) {//企业体检
            self.logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
            self.logoImv.center = self.center;
            CGPoint center = self.center;
            center.y -= 10;
            self.logoImv.center = center;
            [self addSubview:self.logoImv];
            
            self.titleLabel_black = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.logoImv.frame)+5, frame.size.width, 15)];
            self.titleLabel_black.font = [UIFont systemFontOfSize:14];
            self.titleLabel_black.textAlignment = NSTextAlignmentCenter;
            self.titleLabel_black.textColor = [UIColor blackColor];
            [self addSubview:self.titleLabel_black];
            
            self.titleLabel_gray = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel_black.frame), frame.size.width, 15)];
            self.titleLabel_gray.textColor = [UIColor grayColor];
            self.titleLabel_gray.font = [UIFont systemFontOfSize:12];
            self.titleLabel_gray.textAlignment = NSTextAlignmentCenter;
            [self addSubview:self.titleLabel_gray];
            
        }else if (theType == ClassViewType_youshang){//右上
            
            UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width*275/375, frame.size.height)];
            [self addSubview:backView];
            
            self.titleLabel_black = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, backView.frame.size.width, 15)];
            self.titleLabel_black.font = [UIFont systemFontOfSize:14];
            self.titleLabel_black.textColor = [UIColor blackColor];
            self.titleLabel_black.textAlignment = NSTextAlignmentCenter;
            CGPoint p = backView.center;
            p.y -= 7;
            [backView addSubview:self.titleLabel_black];
            self.titleLabel_black.center = p;
            
            self.titleLabel_gray = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel_black.frame), backView.frame.size.width, 15)];
            self.titleLabel_gray.font = [UIFont systemFontOfSize:12];
            self.titleLabel_gray.textColor = [UIColor grayColor];
            self.titleLabel_gray.textAlignment = NSTextAlignmentCenter;
            [backView addSubview:self.titleLabel_gray];
            
            self.logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(backView.right, backView.frame.size.height*0.5-15, 30, 30)];
            [self addSubview:self.logoImv];
            
        }else if (theType == ClassViewType_smallfenlei){//小分类
            self.logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width*0.5-15, self.frame.size.height*0.5-15-10, 30, 30)];
            [self addSubview:self.logoImv];
            
            self.titleLabel_black = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.logoImv.frame)+7, frame.size.width, 15)];
            self.titleLabel_black.textColor = [UIColor blackColor];
            self.titleLabel_black.font = [UIFont systemFontOfSize:13];
            self.titleLabel_black.textAlignment = NSTextAlignmentCenter;
            [self addSubview:self.titleLabel_black];
            
        }
    }
    return self;
}

@end
