//
//  GcustomNavcView.m
//  TiJian
//
//  Created by gaomeng on 15/11/25.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GcustomNavcView.h"

@implementation GcustomNavcView


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.theLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width/3, frame.size.height)];
        [self addSubview:self.theLeftView];
        
        self.theMidelView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.theLeftView.frame), 0, frame.size.width/3, frame.size.height)];
        [self addSubview:self.theMidelView];
        
        self.theRightView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.theMidelView.frame), 0, frame.size.width/3, frame.size.height)];
        [self addSubview:self.theRightView];
        
        
    }
    
    return self;
    
}

@end
