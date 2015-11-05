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

@property(nonatomic,strong)UITableView *tab1;
@property(nonatomic,strong)UITableView *tab2;
@property(nonatomic,strong)UITableView *tab3;

@property(nonatomic,assign)BOOL noGender;//没有性别选项

-(id)initWithFrame:(CGRect)frame noGender:(BOOL)theGender;


@end
