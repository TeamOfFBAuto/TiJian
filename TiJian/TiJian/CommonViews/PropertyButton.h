//
//  PropertyButton.h
//  TiJian
//
//  Created by lichaowei on 15/10/27.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PropertyButton : UIButton

@property(nonatomic,retain)UIButton *selectedButton;//选择状态
@property(nonatomic,assign)BOOL selectedState;//是否选中
@property(nonatomic,retain)id aModel;

@end
