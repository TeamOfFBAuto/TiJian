//
//  PropertyButton.m
//  TiJian
//
//  Created by lichaowei on 15/10/27.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PropertyButton.h"

@implementation PropertyButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setSelectedState:(BOOL)selectedState
{
    _selectedState = selectedState;
    self.selectedButton.hidden = !selectedState;//记录选中状态
}

@end
