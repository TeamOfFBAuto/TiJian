//
//  CycleAdvModel.h
//  TiJian
//
//  Created by gaomeng on 15/10/28.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "BaseModel.h"

@interface CycleAdvModel : BaseModel

@property(nonatomic,strong)NSString *img_url;//活动图
@property(nonatomic,strong)NSString *adv_type_val; //广告类型1=》外链 2=》商场活动 3=》商铺活动 4=》单品  根据这个参数进行跳转
@property(nonatomic,strong)NSString *redirect_type;//0 原生 1 h5打开
@property(nonatomic,strong)NSString *theme_id;//关联id

@end
