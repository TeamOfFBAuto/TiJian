//
//  GPushView.h
//  TiJian
//
//  Created by gaomeng on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPushView : UIView<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray *viewsArray;

@property(nonatomic,strong)UITableView *tab1;//主筛选
@property(nonatomic,strong)UITableView *tab2;//城市选择
@property(nonatomic,strong)UITableView *tab3;//价格
@property(nonatomic,strong)UITableView *tab4;//体检品牌

@property(nonatomic,assign)BOOL gender;//没有性别选项

-(id)initWithFrame:(CGRect)frame gender:(BOOL)theGender;


@end
