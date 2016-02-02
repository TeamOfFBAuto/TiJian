//
//  GUpToolView.h
//  TiJian
//
//  Created by gaomeng on 16/1/22.
//  Copyright © 2016年 lcw. All rights reserved.
//

/**
 *  单品详情页上方工具条
 */

#import <UIKit/UIKit.h>

typedef void (^upToolViewBlock)(NSInteger index);//定义block

@interface GUpToolView : UIView

@property(nonatomic,copy)upToolViewBlock upToolViewBlock;//弄成属性

-(id)initWithFrame:(CGRect)frame count:(int)theCount;

@end
