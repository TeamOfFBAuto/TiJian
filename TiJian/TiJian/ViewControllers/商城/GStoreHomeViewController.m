//
//  GStoreHomeViewController.m
//  TiJian
//
//  Created by gaomeng on 15/10/27.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GStoreHomeViewController.h"
#import "SGFocusImageItem.h"
#import "GcycleScrollView.h"
#import "NSDictionary+GJson.h"
#import "RefreshTableView.h"
#import "GwebViewController.h"
#import "CycleAdvModel.h"

@interface GStoreHomeViewController ()<GcycleScrollViewDelegate>
{
    NSMutableArray *_com_id_array;//幻灯的id
    NSMutableArray *_com_type_array;//幻灯的type
    NSMutableArray *_com_link_array;//幻灯的外链
    NSMutableArray *_com_title_array;//幻灯的index
    NSMutableArray *_cycleAdvViewData;//循环滚动view的数据数组
    
    GcycleScrollView *_topScrollView;
    
    YJYRequstManager *_request;
    
    RefreshHeaderView *_RefreshTabelView;
    
    
}

@property(nonatomic,strong)NSMutableArray *contentArray;

@end

@implementation GStoreHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"体检商城";
    self.myTitleLabel.textColor = RGBCOLOR(91, 147, 203);
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self prepareNetData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 循环滚动view相关=======
-(void)setTopScrollViewWithDic:(NSDictionary *)result{
    
    _com_id_array=[NSMutableArray array];
    _com_link_array=[NSMutableArray array];
    _com_type_array=[NSMutableArray array];
    _com_title_array=[NSMutableArray array];
    
    self.contentArray=[NSMutableArray arrayWithArray:[result objectForKey:@"advertisements_data"]];
    
    if (self.contentArray.count>0) {
        NSMutableArray *imgarray=[NSMutableArray array];
        _cycleAdvViewData = [NSMutableArray arrayWithCapacity:1];
        
        for ( int i=0; i<[self.contentArray count]; i++) {
            NSDictionary *dic_ofcomment=[self.contentArray objectAtIndex:i];
            NSString *strimg=[dic_ofcomment stringValueForKey:@"img_url"];
            
            CycleAdvModel *amodel = [[CycleAdvModel alloc]initWithDictionary:dic_ofcomment];
            [_cycleAdvViewData addObject:amodel];
            
            
            if ([LTools isEmpty:strimg]) {
                strimg = @" ";
            }
            [imgarray addObject:strimg];
            
            //第几个
            NSString *str_rec_title = [NSString stringWithFormat:@"%d",i];
            if ([LTools isEmpty:str_rec_title]) {
                str_rec_title = @" ";
            }
            [_com_title_array addObject:str_rec_title];
            
            //图片url
            NSString *redirect_url=[dic_ofcomment objectForKey:@"redirect_url"];
            if ([LTools isEmpty:redirect_url]) {
                redirect_url = @" ";
            }
            [_com_link_array addObject:redirect_url];
            
            //类型 暂时无用
            NSString *adv_type_val=[dic_ofcomment objectForKey:@"adv_type_val"];
            if ([LTools isEmpty:adv_type_val]) {
                adv_type_val = @" ";
            }
            [_com_type_array addObject:adv_type_val];
            
            //id 暂时无用
            NSString *str__id=[dic_ofcomment objectForKey:@"id"];
            if ([LTools isEmpty:str__id]) {
                str__id = @" ";
            }
            [_com_id_array addObject:str__id];
            
            
        }
        NSInteger length = self.contentArray.count;
        NSMutableArray *tempArray = [NSMutableArray array];
        for (int i = 0 ; i < length; i++)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@",[_com_title_array objectAtIndex:i]],@"title" ,
                                  [NSString stringWithFormat:@"%@",[imgarray objectAtIndex:i]],@"image",[NSString stringWithFormat:@"%@",[_com_link_array objectAtIndex:i]],@"link",
                                  [NSString stringWithFormat:@"%@",[_com_type_array objectAtIndex:i]],@"type",[NSString stringWithFormat:@"%@",[_com_id_array objectAtIndex:i]],@"idoftype",nil];
            
            
            [tempArray addObject:dict];
        }
        
        NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
        if (length > 1)
        {
            NSDictionary *dict = [tempArray objectAtIndex:length-1];
            SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithDict:dict tag:-1] ;
            [itemArray addObject:item];
        }
        for (int i = 0; i < length; i++)
        {
            NSDictionary *dict = [tempArray objectAtIndex:i];
            SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithDict:dict tag:i] ;
            [itemArray addObject:item];
            
        }
        //添加第一张图 用于循环
        if (length >1)
        {
            NSDictionary *dict = [tempArray objectAtIndex:0];
            SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithDict:dict tag:length];
            [itemArray addObject:item];
        }
        _topScrollView = [[GcycleScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, (int)(DEVICE_WIDTH*300/750)) delegate:self imageItems:itemArray isAuto:YES pageControlNum:self.contentArray.count];
        [_topScrollView scrollToIndex:0];
        [self.view addSubview:_topScrollView];
        
    }
}

#pragma mark-SGFocusImageItem的代理
- (void)testfoucusImageFrame:(GcycleScrollView *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    NSLog(@"%s \n click===>%@",__FUNCTION__,item.title);
    
    NSInteger index = [item.title integerValue];
    if (_cycleAdvViewData.count == 0) {
        
        return;
    }
    CycleAdvModel *amodel = _cycleAdvViewData[index];
    if ([amodel.redirect_type intValue] == 1) {//外链
        GwebViewController *ccc = [[GwebViewController alloc]init];
        ccc.urlstring = amodel.theme_id;
        ccc.isSaoyisao = YES;
        ccc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:ccc];
        [self presentViewController:navc animated:YES completion:^{
            
        }];
    }else if ([amodel.redirect_type intValue] == 0){//应用内
        
    }
    
}
#pragma mark - 循环滚动view相关=======




#pragma mark - 请求网络数据

-(void)prepareNetData{
    _request = [YJYRequstManager shareInstance];
    [_request requestWithMethod:YJYRequstMethodGet api:StoreCycleAdv parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [self setTopScrollViewWithDic:result];
        
    } failBlock:^(NSDictionary *result) {
        NSLog(@"%s",__FUNCTION__);
    }];
    
    
}



#pragma mark - 视图创建







@end
