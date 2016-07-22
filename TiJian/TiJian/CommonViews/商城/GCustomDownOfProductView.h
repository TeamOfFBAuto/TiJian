//
//  GCustomDownOfProductView.h
//  TiJian
//
//  Created by gaomeng on 16/7/20.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    TheDownViewType_gouwuche,
    TheDownViewType_yuyue
}TheDownViewType;

typedef void(^downViewClickedBlock)(NSInteger theTag);

@interface GCustomDownOfProductView : UIView

@property(nonatomic,copy)downViewClickedBlock downViewClickedBlock;

-(void)setDownViewClickedBlock:(downViewClickedBlock)downViewClickedBlock;

+(GCustomDownOfProductView*)customViewWithType:(TheDownViewType)theType;



@end
