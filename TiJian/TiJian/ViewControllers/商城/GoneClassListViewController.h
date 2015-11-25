//
//  GoneClassListViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/2.
//  Copyright © 2015年 lcw. All rights reserved.
//



//商城单一分类列表页
#import "MyViewController.h"

@interface GoneClassListViewController : MyViewController

@property(nonatomic,assign)int category_id;//分类id

@property(nonatomic,strong)NSString *className;//分类名称


-(void)therightSideBarDismiss;



@end
