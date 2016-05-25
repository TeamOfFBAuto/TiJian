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
@property(nonatomic,copy)upToolViewBlock upToolViewBlock2;//弄成属性 add by chaoweili

-(id)initWithFrame:(CGRect)frame count:(int)theCount;

/**
 *  创建view
 *
 *  @param titles          标题数组
 *  @param images          图标数组(UIImage)
 *  @param upToolViewBlock
 *
 *  @return 
 */
-(id)initWithTitles:(NSArray *)titles
             images:(NSArray *)images
      toolViewBlock:(upToolViewBlock)upToolViewBlock;//拓展 by chaoweili

@end
