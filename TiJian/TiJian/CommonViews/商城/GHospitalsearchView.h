//
//  GHospitalsearchView.h
//  TiJian
//
//  Created by gaomeng on 16/7/23.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^updateBlock)(NSDictionary *dic);

@interface GHospitalsearchView : UIView<RefreshDelegate,UITableViewDataSource>
{
    NSArray *_dataArray;
}

@property(nonatomic,strong)RefreshTableView *rTab;
@property(nonatomic,strong)NSString *searchWorld;//搜索关键字
@property(nonatomic,copy)updateBlock updateBlock;

-(void)setUpdateBlock:(updateBlock)updateBlock;

-(id)initWithFrame:(CGRect)frame;

@end
