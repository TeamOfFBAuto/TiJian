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
#import "PhysicalTestResultController.h"
#import "PersonalCustomViewController.h"

#import "LBannerView.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ProgressView.h"


@interface GStoreHomeViewController ()<NewHuandengViewDelegate,RefreshDelegate,UITableViewDataSource>
{
    
    LBannerView *_bannerView;//轮播图
    
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_adv;
    AFHTTPRequestOperation *_request_ProductClass;
    AFHTTPRequestOperation *_request_ProductRecommend;
    
    RefreshTableView *_table;
    
    int _count;//网络请求个数
    
    NSDictionary *_StoreCycleAdvDic;//轮播图dic
    NSDictionary *_StoreProductClassDic;
    NSMutableArray *_StoreProductListArray;
    
    
}

@property(nonatomic,strong)NSMutableArray *upAdvArray;

@property(nonatomic,strong)UIView *theTopView;;

@end

@implementation GStoreHomeViewController


- (void)dealloc
{
    NSLog(@"dealloc %@",self);
    
    [_request removeOperation:_request_adv];
    [_request removeOperation:_request_ProductClass];
    [_request removeOperation:_request_ProductRecommend];
    
    
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
    _request_ProductRecommend = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductList parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _StoreProductListArray = [NSMutableArray arrayWithCapacity:1];
        NSArray *arr = [result arrayValueForKey:@"data"];
        for (NSDictionary *dic in arr) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [_StoreProductListArray addObject:model];
        }
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
        self.theTopView = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                               0,
                                                               DEVICE_WIDTH,
                                                               [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/300]//轮播图高度
                                                               +hang*[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/280]//分类版块高度
                                                               +5
                                                               +[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/150]//个性化定制图高度
                                                               +[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80]//精品推荐标题
                                                               )];
        self.theTopView.backgroundColor = RGBCOLOR(244, 245, 246);
        _table.tableHeaderView = self.theTopView;
        
        
        
        //设置轮播图
        [self creatUpCycleScrollView];
        
        //设置版块
        UIView *bankuaiView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_bannerView.frame), DEVICE_WIDTH, hang*[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/280])];
        bankuaiView.backgroundColor = [UIColor whiteColor];
        [self.theTopView addSubview:bankuaiView];
        
        
        
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
        
        [dingzhiImv addTaget:self action:@selector(pushToPersonalCustom) tag:0];
        
        [self.theTopView addSubview:dingzhiImv];
        
        
        
        
        //设置精品推荐
        
        UIView *jingpintuijian = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                         CGRectGetMaxY(dingzhiImv.frame),
                                                                         DEVICE_WIDTH,
                                                                         [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
        jingpintuijian.backgroundColor = RGBCOLOR(244, 245, 246);
        [self.theTopView addSubview:jingpintuijian];
        UILabel *ttl = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, jingpintuijian.frame.size.height)];
        ttl.font = [UIFont systemFontOfSize:15];
        [jingpintuijian addSubview:ttl];
        ttl.text = @"精品推荐";
        ttl.textColor = [UIColor blackColor];
        
        
        
        [_table reloadData:_StoreProductListArray pageSize:G_PER_PAGE];
        
    }
    
}


-(void)classImvClicked:(UIImageView*)sender{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%ld",(long)sender.tag);
    //数据数组
    NSArray *classData = [_StoreProductClassDic arrayValueForKey:@"data"];
    NSDictionary *dic = classData[sender.tag - 10];
    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
    cc.category_id = (int)(sender.tag - 10);
    cc.className = [dic stringValueForKey:@"name"];
    
    [self.navigationController pushViewController:cc animated:YES];
    
    
}




#pragma mark - 视图创建

//创建tabelview
-(void)creatTableView{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    [_table showRefreshHeader:YES];
    
}


-(void)creatUpCycleScrollView{
    
    
    self.upAdvArray = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *advertisements_data = [NSMutableArray arrayWithArray:[_StoreCycleAdvDic objectForKey:@"advertisements_data"]];
    
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:1];
    
    if (advertisements_data.count>0) {
        
        for (NSDictionary *dic in advertisements_data) {
            CycleAdvModel *model = [[CycleAdvModel alloc]initWithDictionary:dic];
            [self.upAdvArray addObject:model];
        }
        
        
        for (CycleAdvModel *model in self.upAdvArray) {
            [urls addObject:model.img_url];
        }
        
        
        NSMutableArray *views = [NSMutableArray arrayWithCapacity:urls.count];
        for (int i = 0; i < urls.count; i ++) {
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 300)];
            UIProgressView *progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
            [imageView sd_setImageWithURL:[NSURL URLWithString:urls[i]] placeholderImage:nil usingProgressView:progress];
            [views addObject:imageView];
            
        }
        
        
        
        
        _bannerView = [[LBannerView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 300/750.0*DEVICE_WIDTH)];
        [_bannerView setContentViews:views];
        [_bannerView showPageControl];
        [_bannerView setBackgroundColor:[UIColor lightGrayColor]];
        
        
        __weak typeof  (self)bself = self;
        
        [_bannerView setTapActionBlock:^(NSInteger index) {
            NSLog(@"--tap index %ld",index);
            
            CycleAdvModel *amodel = bself.upAdvArray[index];
            if ([amodel.redirect_type intValue] == 1) {//外链
                GwebViewController *ccc = [[GwebViewController alloc]init];
                ccc.urlstring = amodel.redirect_url;
                ccc.hidesBottomBarWhenPushed = YES;
                [bself.navigationController pushViewController:ccc animated:YES];
                
            }else if ([amodel.redirect_type intValue] == 0){//应用内
                if ([amodel.adv_type_val intValue] == 1) {//套餐 单品详情
                    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
                    cc.productId = amodel.theme_id;
                    [bself.navigationController pushViewController:cc animated:YES];
                }else if ([amodel.adv_type_val intValue] == 2){//企业预约首页
                    
                }
                
                
            }

            
            
            
            
        }];
        
        [_bannerView setAutomicScrollingDuration:3];
        
        [self.theTopView addSubview:_bannerView];
    
    
    }
    
    
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
    ProductModel *aModel = _table.dataArray[indexPath.row];
    cc.productId = aModel.product_id;
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
    
    ProductModel *model = _table.dataArray[indexPath.row];
    
    [cell loadData:model];
    
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



/**
 *  个性化定制
 */
- (void)pushToPersonalCustom
{
    __weak typeof(self)weakSelf = self;
    BOOL isLogin = [LoginViewController isLogin:self loginBlock:^(BOOL success) {
        
        if (success) {
            [weakSelf pushToPhysicaResult];
        }else
        {
            NSLog(@"没登陆成功");
        }
    }];
    //登录成功
    if (isLogin) {
        
        [weakSelf pushToPhysicaResult];
    }
}

/**
 *  跳转至个性化定制页 或者 结果页
 */
- (void)pushToPhysicaResult
{
    //先判断是否个性化定制过
    BOOL isOver = [LTools cacheBoolForKey:USER_CUSTOMIZATON_RESULT];
    if (isOver) {
        //已经个性化定制过
        PhysicalTestResultController *physical = [[PhysicalTestResultController alloc]init];
        physical.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:physical animated:YES];
    }else
    {
        PersonalCustomViewController *custom = [[PersonalCustomViewController alloc]init];
        custom.lastViewController = self;
        custom.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:custom animated:YES];
    }
}


@end
