//
//  GproductDetailViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/2.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GproductDetailViewController.h"
#import "GproductDetailTableViewCell.h"
#import "GproductDirectoryTableViewCell.h"
#import "GShopCarViewController.h"
#import "ProductCommentModel.h"
#import "GcommentViewController.h"
#import "ProductModel.h"

@interface GproductDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_productDetail;
    AFHTTPRequestOperation *_request_GetShopCarNum;
    AFHTTPRequestOperation *_request_ProductProjectList;
    AFHTTPRequestOperation *_request_GetProductComment;
    AFHTTPRequestOperation *_request_LookAgain;
    int _count;
    
    NSDictionary *_shopCarDic;
    
    UITableView *_tab;
    
    ProductModel *_theProductModel;//产品model
    
    GproductDetailTableViewCell *_tmpCell;
    GproductDirectoryTableViewCell *_tmpCell1;
    
    
    UIView *_downView;
    
    UITableView *_hiddenView;
    
    UILabel *_shopCarNumLabel;
    
    NSArray *_productProjectListDataArray;//项目列表
    
    NSArray *_productCommentArray;//商品评论
    
    NSMutableArray *_LookAgainProductListArray;//看了又看
    
    
    
}

@end

@implementation GproductDetailViewController


- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    _tab.delegate = nil;
    _tab.dataSource = nil;
    _tab = nil;
    [_request removeOperation:_request_GetShopCarNum];
    [_request removeOperation:_request_productDetail];
    [_request removeOperation:_request_ProductProjectList];
    [_request removeOperation:_request_GetProductComment];
    [_request removeOperation:_request_LookAgain];
    [self removeObserver:self forKeyPath:@"_count"];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_UPDATE_TO_CART object:nil];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"产品详情";
    
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCarNum) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    
    [self prepareNetData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    
    if (scrollView.tag == 1000) {
        // 下拉到最底部时显示更多数据
        
        
        if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height + 30)))
        {
            [self moveToUp:YES];
        }
    }else if (scrollView.tag == 1001){
        if (scrollView.contentOffset.y < -30) {
            [self moveToUp:NO];
        }
    }
    
    
}


- (void)moveToUp:(BOOL)up
{
    NSLog(@"%s",__FUNCTION__);
    if (up) {
        [UIView animateWithDuration:0.3 animations:^{
            _tab.top = -500;
            _hiddenView.top = 0;
            _downView.top = self.view.size.height;
            self.myTitle = @"体检项目";
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _tab.top = 0;
            _hiddenView.top = CGRectGetMaxY(_tab.frame);
            _downView.top = DEVICE_HEIGHT - 50-64;
            self.myTitle = @"体检项目";
        }];
    }
    
    
    
    
}




#pragma mark - 网络请求
-(void)prepareNetData{
    
    _request = [YJYRequstManager shareInstance];
    _count = 0;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self getProductDetail];//单品详情
    [self getProductConmment];//产品评论
    [self prepareProductProjectList];//具体项目
    [self getshopcarNum];//购物车数量
    
}

//套餐项目列表
-(void)prepareProductProjectList{
    NSDictionary *dic = @{
                          @"product_id":self.productId
                          };
    
    _request_ProductProjectList = [_request requestWithMethod:YJYRequstMethodGet api:StoreProdectProjectList parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _productProjectListDataArray = [result arrayValueForKey:@"data"];
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKey:@"_count"];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
    
}


//套餐详情
-(void)getProductDetail{
    NSDictionary *parameters = @{
                                 @"product_id":self.productId
                                 };
    
    __weak typeof (self)bself = self;
    
    _request_productDetail = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductDetail parameters:parameters constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSDictionary *dic = [result dictionaryValueForKey:@"data"];
        
        _theProductModel = [[ProductModel alloc]initWithDictionary:dic];
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        [bself prepareLookAgainNetData];
        
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}


//看了又看
-(void)prepareLookAgainNetData{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic = @{
                          @"brand_id":_theProductModel.brand_id,
                          @"province_id":[GMAPI getCurrentProvinceId],
                          @"city_id":[GMAPI getCurrentCityId],
                          @"page":@"1",
                          @"per_page":@"3"
                          };
    
    
    _request_LookAgain = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductList parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _LookAgainProductListArray = [NSMutableArray arrayWithCapacity:1];
        NSArray *arr = [result arrayValueForKey:@"data"];
        for (NSDictionary *dic in arr) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [_LookAgainProductListArray addObject:model];
        }
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}



//获取购物车数量
-(void)getshopcarNum{
    
    
    
    NSDictionary *dic = @{
                          @"authcode":[GMAPI testAuth]
                          };
    _request_GetShopCarNum = _request_GetShopCarNum = [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _shopCarDic = result;
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
}

-(void)updateShopCarNum{
    
    NSDictionary *dic = @{
                          @"authcode":[GMAPI testAuth]
                          };
    _request_GetShopCarNum = _request_GetShopCarNum = [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _shopCarDic = result;
        
        if (_shopCarNumLabel) {
            
            _shopCarNumLabel.text = [NSString stringWithFormat:@"%d",[_shopCarDic intValueForKey:@"num"]];
            
            [self updateShopCarNumAndFrame];
        }
        
        
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
}





//套餐评论
-(void)getProductConmment{
    NSDictionary *dic = @{
                          @"product_id":self.productId,
                          @"page":@"1",
                          @"per_page":@"3"
                          };
    _request_GetProductComment = [_request requestWithMethod:YJYRequstMethodGet api:GET_PRODUCT_COMMENT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSArray *arr = [result arrayValueForKey:@"list"];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in arr) {
            ProductCommentModel *model = [[ProductCommentModel alloc]initWithDictionary:dic];
            [array addObject:model];
        }
        _productCommentArray = array;
        [self setValue:[NSNumber numberWithInt:_count + 1] forKey:@"_count"];
    } failBlock:^(NSDictionary *result) {
        
    }];
    
    
}



//添加商品到购物车
-(void)addProductToShopCar{

    NSDictionary *dic = @{
                          @"authcode":[GMAPI testAuth],
                          @"product_id":self.productId,
                          @"product_num":@"1"
                          };
    [_request requestWithMethod:YJYRequstMethodPost api:ORDER_ADD_TO_CART parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        int count = [_shopCarNumLabel.text intValue];
        count+=1;
        _shopCarNumLabel.text = [NSString stringWithFormat:@"%d",count];
        [self updateShopCarNumAndFrame];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
}



#pragma mark - 网络请求完成
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        return;
    }
    
    NSNumber *num = [change objectForKey:@"new"];
    
    if ([num intValue] == 5) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [self creatTabAndDownView];
        
        if (_shopCarNumLabel) {
            
            _shopCarNumLabel.text = [NSString stringWithFormat:@"%d",[_shopCarDic intValueForKey:@"num"]];
            
            [self updateShopCarNumAndFrame];
        }
    }
    
    
}



#pragma mark - 视图创建
-(void)creatTabAndDownView{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStylePlain];
    _tab.tag = 1000;
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tab];
    
    
    [self creatHiddenView];
    
    [self creatDownView];
    
}

-(void)creatDownView{
    _downView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 50-64, DEVICE_WIDTH, 50)];
    _downView.backgroundColor = RGBCOLOR(38, 51, 62);
    
    UIButton *addShopCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addShopCarBtn.tag = 104;
    CGFloat theW = [GMAPI scaleWithHeight:50 width:0 theWHscale:180.0/100];
    [addShopCarBtn setFrame:CGRectMake(_downView.frame.size.width-theW, 0, theW, 50)];
    addShopCarBtn.backgroundColor = RGBCOLOR(224, 103, 20);
    [addShopCarBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    [addShopCarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addShopCarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [addShopCarBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:addShopCarBtn];
    
    CGFloat tw = (_downView.frame.size.width-theW)/4;
    NSArray *titleArray = @[@"客服",@"收藏",@"品牌店",@"购物车"];
    for (int i = 0; i<4; i++) {
        UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [oneBtn setFrame:CGRectMake(i*tw, 0, tw, 50)];
        [oneBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        oneBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        oneBtn.tag = 100+i;
        [oneBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_downView addSubview:oneBtn];
        
        if (i == 3) {
            _shopCarNumLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            _shopCarNumLabel.textColor = [UIColor whiteColor];
            _shopCarNumLabel.backgroundColor = RGBCOLOR(255, 126, 170);
            _shopCarNumLabel.layer.cornerRadius = 5;
            _shopCarNumLabel.layer.borderColor = [RGBCOLOR(255, 126, 170)CGColor];
            _shopCarNumLabel.layer.borderWidth = 0.5f;
            _shopCarNumLabel.layer.masksToBounds = YES;
            _shopCarNumLabel.font = [UIFont systemFontOfSize:11];
            _shopCarNumLabel.textAlignment = NSTextAlignmentCenter;
            
            _shopCarNumLabel.text = [NSString stringWithFormat:@"0"];
            
            [oneBtn addSubview:_shopCarNumLabel];
        }
        
    }
    [self.view addSubview:_downView];
}

-(void)updateShopCarNumAndFrame{
    
    if ([_shopCarNumLabel.text intValue] == 0) {
        _shopCarNumLabel.hidden = YES;
    }else{
        _shopCarNumLabel.hidden = NO;
        [_shopCarNumLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, 0) height:11 limitMaxWidth:45];
        CGFloat with = _shopCarNumLabel.frame.size.width + 5;
        UIButton *oneBtn = (UIButton*)[_downView viewWithTag:103];
        [_shopCarNumLabel setFrame:CGRectMake(oneBtn.bounds.size.width - with, -2, with, 11)];
        
    }
    
}






-(void)creatHiddenView{
    _hiddenView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tab.frame), DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _hiddenView.delegate = self;
    _hiddenView.dataSource = self;
    _hiddenView.tag = 1001;
    [self.view addSubview:_hiddenView];
    
}


-(void)downBtnClicked:(UIButton *)sender{
    if (sender.tag == 100) {//客服
        
    }else if (sender.tag == 101){//收藏
        
    }else if (sender.tag == 102){//品牌店
        
    }else if (sender.tag == 103){//购物车
        
        if (self.isShopCarPush) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            GShopCarViewController *cc = [[GShopCarViewController alloc]init];
            [self.navigationController pushViewController:cc animated:YES];
        }
        
    }else if (sender.tag == 104){//加入购物车
        
        [self addProductToShopCar];
        
    }
}



#pragma mark - UITableViewDelegate && UITableViewDataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1000) {
        static NSString *identifier = @"identifier";
        GproductDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[GproductDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.delegate = self;
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        [cell loadCustomViewWithModel:_theProductModel index:indexPath productCommentArray:_productCommentArray lookAgainArray:_LookAgainProductListArray];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (tableView.tag == 1001){
        static NSString *identi = @"identi";
        GproductDirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
        if (!cell) {
            cell = [[GproductDirectoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
        }
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        
        NSArray *arr = _productProjectListDataArray[indexPath.section];
        NSDictionary *dic = arr[indexPath.row];
        
        [cell loadCustomViewWithData:dic indexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
    
    
    return [[UITableViewCell alloc]init];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSInteger num = 1;
    
    if (tableView.tag == 1000) {
        //6个section
        //0     logo图 套餐名 描述 价钱
        //1     优惠券
        //2     主要参数
        //3     评价
        //4     看了又看
        //5     上拉显示体检项目详情
        num = 6;
    }else if (tableView.tag == 1001){
        num = _productProjectListDataArray.count;
    }
    
    return num;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    
    if (tableView.tag == 1000) {
        if (section == 0) {
            num = 1;
        }else if (section == 1){
            num = 1;
        }else if (section == 2){
            num = 1;
        }else if (section == 3){
            num = 2;
        }else if (section == 4){
            num = 1;
        }else if (section == 5){
            num = 1;
        }
    }else if (tableView.tag == 1001){
        NSArray *arr = _productProjectListDataArray[section];
        num = arr.count;
    }
    
    
    
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger height = 0;
    
    
    if (tableView.tag == 1000) {
        if (!_tmpCell) {
            _tmpCell = [[GproductDetailTableViewCell alloc]init];
        }
        for (UIView *view in _tmpCell.contentView.subviews) {
            [view removeFromSuperview];
        }
        height = [_tmpCell loadCustomViewWithModel:_theProductModel index:indexPath productCommentArray:_productCommentArray lookAgainArray:_LookAgainProductListArray];
    }else if (tableView.tag == 1001){
        if (!_tmpCell1) {
            _tmpCell1 = [[GproductDirectoryTableViewCell alloc]init];
        }
        for (UIView *view in _tmpCell1.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        NSArray *arr = _productProjectListDataArray[indexPath.section];
        NSDictionary *dic = arr[indexPath.row];
        
        height = [_tmpCell1 loadCustomViewWithData:dic indexPath:indexPath];
    }
    
    
    
    
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0.01;
    
    if (tableView.tag == 1000) {
        
    }else if (tableView.tag == 1001){
        if (section == 0.01) {
            height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/220];
        }else{
            height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60];
        }
        
        
    }
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 0.01;
    
    if (tableView.tag == 1000) {
        
    }else if (tableView.tag == 1001){
        
    }
    
    return height;
}


-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    if (tableView.tag == 1000) {
        
    }else if (tableView.tag == 1001){
        
    }
    return view;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    
    if (tableView.tag == 1000) {
        
    }else if (tableView.tag == 1001){
        if (section == 0) {
            [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/220])];
            UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60])];
            tishiLabel.backgroundColor = [UIColor whiteColor];
            tishiLabel.font = [UIFont systemFontOfSize:12];
            tishiLabel.textAlignment = NSTextAlignmentCenter;
            tishiLabel.textColor = [UIColor blackColor];
            tishiLabel.text = @"下拉显示套餐详情";
            [view addSubview:tishiLabel];
            
            UIView *titleView =[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tishiLabel.frame),DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/100])];
            titleView.backgroundColor = [UIColor whiteColor];
            [view addSubview:titleView];
            
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, [GMAPI scaleWithHeight:titleView.frame.size.height width:0 theWHscale:145.0/100], titleView.frame.size.height)];
            [imv setImage:[UIImage imageNamed:@"tijianxiangmu1.png"]];
            [titleView addSubview:imv];
            
            UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+10, 0, titleView.frame.size.width - 10-imv.frame.size.width-5, titleView.frame.size.height)];
            tLabel.font = [UIFont systemFontOfSize:15];
            tLabel.textColor = [UIColor blackColor];
            tLabel.text = @"健康优选套餐(男/女二选一)";
            [titleView addSubview:tLabel];
            
            UIView *blueView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleView.frame), DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60])];
            blueView.backgroundColor = RGBCOLOR(222, 245, 255);
            [view addSubview:blueView];
            
            UILabel *xuhaoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, blueView.frame.size.width/4, blueView.frame.size.height)];
            xuhaoLabel.text = @"序号";
            xuhaoLabel.font = [UIFont systemFontOfSize:12];
            xuhaoLabel.textAlignment = NSTextAlignmentCenter;
            [blueView addSubview:xuhaoLabel];
            
            UILabel *mingxiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(xuhaoLabel.frame), 0, xuhaoLabel.frame.size.width, xuhaoLabel.frame.size.height)];
            mingxiLabel.text = @"明细";
            mingxiLabel.font = [UIFont systemFontOfSize:12];
            mingxiLabel.textAlignment = NSTextAlignmentCenter;
            [blueView addSubview:mingxiLabel];
            
            
            UILabel *zuheneirongLbel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(mingxiLabel.frame), 0, blueView.frame.size.width/2, blueView.frame.size.height)];
            zuheneirongLbel.text = @"组合内容";
            zuheneirongLbel.font = [UIFont systemFontOfSize:12];
            zuheneirongLbel.textAlignment = NSTextAlignmentCenter;
            [blueView addSubview:zuheneirongLbel];
            
            
            
        }else{
            
            [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60])];
            view.backgroundColor = RGBCOLOR(222, 245, 255);
            
            UILabel *canhouxiangmuLabel = [[UILabel alloc]initWithFrame:view.bounds];
            canhouxiangmuLabel.textAlignment = NSTextAlignmentCenter;
            canhouxiangmuLabel.text = @"餐后项目";
            canhouxiangmuLabel.font = [UIFont systemFontOfSize:12];
            [view addSubview:canhouxiangmuLabel];
            
            
            
        }
    }
    
    
    
    return view;
}

//跳转评论界面
-(void)goToCommentVc{
    GcommentViewController *cc = [[GcommentViewController alloc]init];
    cc.productId = self.productId;
    [self.navigationController pushViewController:cc animated:YES];
}

//跳转单品详情页
-(void)goToProductDetailVcWithId:(NSString *)productId{
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    cc.productId = productId;
    [self.navigationController pushViewController:cc animated:YES];
}




@end
