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
#import "GoneClassListViewController.h"
#import "GproductDetailViewController.h"
#import "GProductCellTableViewCell.h"

@interface GStoreHomeViewController ()<NewHuandengViewDelegate,RefreshDelegate,UITableViewDataSource>
{
    NSMutableArray *_com_id_array;//幻灯的id
    NSMutableArray *_com_type_array;//幻灯的type
    NSMutableArray *_com_link_array;//幻灯的外链
    NSMutableArray *_com_title_array;//幻灯的index
    NSMutableArray *_cycleAdvViewData;//循环滚动view的数据数组
    
    GcycleScrollView *_topScrollView;
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_adv;
    AFHTTPRequestOperation *_request_ProductClass;
    AFHTTPRequestOperation *_request_ProductRecommend;
    
    RefreshTableView *_table;
    
    int _count;//网络请求个数
    
    NSDictionary *_StoreCycleAdvDic;
    NSDictionary *_StoreProductClassDic;
    NSDictionary *_StoreProductRecommendDic;
    
    
}

@property(nonatomic,strong)NSMutableArray *contentArray;

@property(nonatomic,strong)UIView *topView;;

@end

@implementation GStoreHomeViewController


- (void)dealloc
{
    NSLog(@"dealloc %@",self);
    
    [_request removeOperation:_request_adv];
    [_request removeOperation:_request_ProductClass];
    [_request removeOperation:_request_ProductRecommend];
    
    _topScrollView.delegate = nil;
    _topScrollView = nil;
    
    [self removeObserver:self forKeyPath:@"_count"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"体检商城";
    self.myTitleLabel.textColor = RGBCOLOR(91, 147, 203);
    
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self creatTableView];
    
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
        
        
        if (!_topScrollView) {
            _topScrollView = [[GcycleScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, (int)(DEVICE_WIDTH*300/750)) delegate:self imageItems:itemArray isAuto:YES pageControlNum:self.contentArray.count];
            
            
        }
        
        [_topScrollView scrollToIndex:0];
        [self.topView addSubview:_topScrollView];
        
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

- (void)testfoucusImageFrame:(GcycleScrollView *)imageFrame currentItem:(int)index{
    
}
#pragma mark - 循环滚动view相关=======




#pragma mark - 请求网络数据

-(void)prepareNetData{
    
    _request = [YJYRequstManager shareInstance];
    _count = 0;
    
    //轮播图
    _request_adv = [_request requestWithMethod:YJYRequstMethodGet api:StoreCycleAdv parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _StoreCycleAdvDic = result;
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        
        
    } failBlock:^(NSDictionary *result) {
        NSLog(@"%s",__FUNCTION__);
    }];
    
    
    //商城套餐分类
    _request_ProductClass = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductClass parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _StoreProductClassDic = result;
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
    
    //首页精品推荐
    _request_ProductRecommend = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductRecommend parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _StoreProductRecommendDic = result;
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
    
    
    
}

//三个网络请求完成
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        return;
    }
    
    NSNumber *num = [change objectForKey:@"new"];
    
    if ([num intValue] == 3) {
        //数据数组
        NSArray *classData = [_StoreProductClassDic arrayValueForKey:@"data"];
        
        //共几行
        int hang = (int)classData.count/2;
        if (hang<classData.count/2.0) {
            hang+=1;
        };
        //每行几列
        int lie = 2;
        
        
        
        //refresh头部
        self.topView = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                               0,
                                                               DEVICE_WIDTH,
                                                               [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/300]//轮播图高度
                                                               +hang*[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/280]//分类版块高度
                                                               +5
                                                               +[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/150]//个性化定制图高度
                                                               +[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80]//精品推荐标题
                                                               )];
        self.topView.backgroundColor = RGBCOLOR(244, 245, 246);
        _table.tableHeaderView = self.topView;
        
        
        
        //设置轮播图
        [self setTopScrollViewWithDic:_StoreCycleAdvDic];
        
        //设置版块
        UIView *bankuaiView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_topScrollView.frame), DEVICE_WIDTH, hang*[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/280])];
        bankuaiView.backgroundColor = [UIColor whiteColor];
        [self.topView addSubview:bankuaiView];
        
        
        
        //宽
        CGFloat kk = DEVICE_WIDTH*0.5;
        //高
        CGFloat hh = [GMAPI scaleWithHeight:0 width:kk theWHscale:375.0/280];
        
        
        for (int i = 0; i<classData.count; i++) {
            
            NSDictionary *dic = classData[i];
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i%lie*DEVICE_WIDTH*0.5, i/hang*hh, kk, hh)];
            [bankuaiView addSubview:view];
            view.backgroundColor = RGBCOLOR_ONE;
            
            
            //图片
            UIImageView *imv = [[UIImageView alloc]initWithFrame:view.bounds];
            [imv l_setImageWithURL:[NSURL URLWithString:[dic stringValueForKey:@"cover_pic"]] placeholderImage:nil];
            [view addSubview:imv];
            //标题
//            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, imv.frame.size.width, imv.frame.size.height * 0.25)];
//            titleLabel.text = [dic stringValueForKey:@"name"];
//            titleLabel.textColor = [UIColor blackColor];
//            titleLabel.font = [UIFont systemFontOfSize:15];
//            [imv addSubview:titleLabel];
            
            
            int imvTag = i+10;
            
            [imv addTaget:self action:@selector(classImvClicked:) tag:imvTag];
            
            
        }
        
        UIImageView *dingzhiImv = [[UIImageView alloc]initWithFrame:CGRectMake(0,
                                                                               CGRectGetMaxY(bankuaiView.frame)+5,
                                                                               DEVICE_WIDTH,
                                                                               [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/150]
                                                                               )];
        [dingzhiImv setImage:[UIImage imageNamed:@"gexingdingzhi.png"]];
        [self.topView addSubview:dingzhiImv];
        
        
        
        
        //设置精品推荐
        
        UIView *jingpintuijian = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                         CGRectGetMaxY(dingzhiImv.frame),
                                                                         DEVICE_WIDTH,
                                                                         [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
        jingpintuijian.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.topView addSubview:jingpintuijian];
        UILabel *ttl = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, jingpintuijian.frame.size.height)];
        ttl.font = [UIFont systemFontOfSize:15];
        [jingpintuijian addSubview:ttl];
        ttl.text = @"精品推荐";
        ttl.textColor = [UIColor blackColor];
        
        
        
        
        NSArray *RecommendArray = [_StoreProductRecommendDic arrayValueForKey:@"data"];
        
        [_table reloadData:RecommendArray pageSize:20];
        
    }
    
}


-(void)classImvClicked:(UIImageView*)sender{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%ld",(long)sender.tag);
    //数据数组
    NSArray *classData = [_StoreProductClassDic arrayValueForKey:@"data"];
    NSDictionary *dic = classData[sender.tag - 10];
    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
    cc.className = [dic stringValueForKey:@"name"];
    [self.navigationController pushViewController:cc animated:YES];
    
    
}




#pragma mark - 视图创建

-(void)creatTableView{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    [_table showRefreshHeader:YES];
    
    
    
    
}


#pragma - mark RefreshDelegate


- (void)loadNewDataForTableView:(UITableView *)tableView{
    
    [_request removeOperation:_request_adv];
    [_request removeOperation:_request_ProductClass];
    [_request removeOperation:_request_ProductRecommend];
    
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    
    [self prepareNetData];

}


- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    NSDictionary *dic = _table.dataArray[indexPath.row];
    cc.productId = [dic stringValueForKey:@"product_id"];
    [self.navigationController pushViewController:cc animated:YES];
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 100;
    return height;
}
//将要显示
- (void)refreshTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
    });
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GProductCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GProductCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *dic = _table.dataArray[indexPath.row];
    
    [cell loadData:dic];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

@end
