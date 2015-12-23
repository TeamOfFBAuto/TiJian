//
//  GShopCarViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/6.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GShopCarViewController.h"
#import "GshopCarTableViewCell.h"
#import "ProductModel.h"
#import "GproductDetailViewController.h"
#import "ConfirmOrderViewController.h"

@interface GShopCarViewController ()<UITableViewDataSource,RefreshDelegate,UIActionSheetDelegate>
{
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_shopCarDetail;
    
    
    UIView *_downView;
    
    int _open[500];
    
    CGFloat _totolPrice;
    
    UIView *_noProductView;
    
    
    
    BOOL _deleteState;//删除状态
    
    UIButton *_jiesuanBtn;//结算 删除按钮
    
    UIButton *_rightBtn;//右边按钮
    
    NSMutableArray *_buyStateProductUserChooseArray;//购买状态用户选择的商品
    
    
}
@end

@implementation GShopCarViewController

- (void)dealloc
{
    
    [_request removeOperation:_request_shopCarDetail];
    _request = nil;
    
    self.rTab.refreshDelegate = nil;
    self.rTab.dataSource = nil;
    self.rTab = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_UPDATE_TO_CART object:nil];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    self.myTitle = @"购物车";
    _deleteState = NO;

    
    for (int i = 0; i<500; i++) {
        _open[i] = 0;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCar) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    
    _request = [YJYRequstManager shareInstance];
    _rTab.pageNum = 1;
    _totolPrice = 0;
    
    
//    [self creatNoProductView];
    
    [self creaTab];
    
    [self creatDownView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 视图创建
//创建主tableview
-(void)creaTab{
    self.rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStyleGrouped];
    self.rTab.refreshDelegate = self;
    self.rTab.dataSource = self;
    
    [self.view addSubview:self.rTab];
    
    [self.rTab showRefreshHeader:YES];
    
}

//创建下方功能view
-(void)creatDownView{
    _downView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT -64 - 50, DEVICE_WIDTH, 50)];
    _downView.backgroundColor = [UIColor whiteColor];
    
    self.allChooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.allChooseBtn setFrame:CGRectMake(10, 0, DEVICE_WIDTH*140.0/750, 50)];
    self.allChooseBtn.selected = NO;
    self.allChooseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.allChooseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.allChooseBtn setTitle:@"全选" forState:UIControlStateNormal];
    [self.allChooseBtn setImage:[UIImage imageNamed:@"xuanzhong_no.png"] forState:UIControlStateNormal];
    [self.allChooseBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self.allChooseBtn setImage:[UIImage imageNamed:@"shoppingcart_selected.png"] forState:UIControlStateSelected];
    
    
    [self.allChooseBtn addTarget:self action:@selector(downViewallChooseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [_downView addSubview:self.allChooseBtn];
    
    UIView *midleView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.allChooseBtn.frame), 0, DEVICE_WIDTH*380.0/750, 50)];
    [_downView addSubview:midleView];
    
    self.totolPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, midleView.frame.size.width, midleView.frame.size.height*0.5)];
    NSString *pStr = @"0.00";
    NSString *price = [NSString stringWithFormat:@"合计：￥%@",pStr];
    NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
    [aaa addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 3)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 3)];
    
    [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(237, 108, 22) range:NSMakeRange(3, pStr.length+1)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(3, pStr.length+1)];
    self.totolPriceLabel.attributedText = aaa;
    
    [midleView addSubview:self.totolPriceLabel];
    
    self.detailPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.totolPriceLabel.frame), self.totolPriceLabel.frame.size.width, self.totolPriceLabel.frame.size.height)];
    self.detailPriceLabel.font = [UIFont systemFontOfSize:12];
    self.detailPriceLabel.textColor = [UIColor blackColor];
    self.detailPriceLabel.text = [NSString stringWithFormat:@"总额:￥%@  优惠:￥%@",@"0.0",@"0.0"];
    [midleView addSubview:self.detailPriceLabel];
    
    
    _jiesuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _jiesuanBtn.backgroundColor = RGBCOLOR(237, 108, 22);
    _jiesuanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_jiesuanBtn setFrame:CGRectMake(CGRectGetMaxX(midleView.frame), 0, DEVICE_WIDTH*215.0/750, 50)];
    [_jiesuanBtn setTitle:@"去结算" forState:UIControlStateNormal];
    [_jiesuanBtn addTarget:self action:@selector(goToConfirmOrderVc) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:_jiesuanBtn];
    
    
    [self.view addSubview:_downView];
    
}

////创建购物车没有东西的提示界面
//-(void)creatNoProductView{
//    _noProductView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
//    
//    UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
//    tishiLabel.center = _noProductView.center;
//    tishiLabel.font = [UIFont systemFontOfSize:15];
//    tishiLabel.text = @"~空空如也~";
//    tishiLabel.textAlignment = NSTextAlignmentCenter;
//    tishiLabel.textColor = [UIColor grayColor];
//    [_noProductView addSubview:tishiLabel];
//    
//    _noProductView.hidden = YES;
//    [self.view addSubview:_noProductView];
//}



#pragma mark - 点击事件
-(void)goToConfirmOrderVc{
    
    
    if (_deleteState) {//删除
        
        
        NSArray *arr = [self getChoseProducts];
        int ccc = (int)arr.count;
        
        UIActionSheet *aaa = [[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"确认要删除这%d种商品吗",ccc] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
        [aaa showInView:self.view];
        
        
    }else{
        if (_totolPrice != 0) {
            ConfirmOrderViewController *cc = [[ConfirmOrderViewController alloc]init];
            cc.lastViewController = self;
            
            NSArray *arr = [self getChoseProducts];
            
            cc.dataArray = arr;
            
            [self.navigationController pushViewController:cc animated:YES];
        }else{
            [GMAPI showAutoHiddenMBProgressWithText:@"请选择套餐" addToView:self.view];
        }
    }
    
}

//删除按钮
-(void)rightButtonTap:(UIButton *)sender{
    
    _deleteState = !_deleteState;
    
    if (_deleteState) {//删除
        
        [self recordBuyStateProductUserChoose];
        
        [self setDownViewAllChooseBtnNoSelect];
        
        [self.right_button setTitle:@"取消" forState:UIControlStateNormal];
        [_jiesuanBtn setTitle:@"删除" forState:UIControlStateNormal];
        self.totolPriceLabel.hidden = YES;
        self.detailPriceLabel.hidden = YES;
    }else{
        
        
        for (NSArray *arr in self.rTab.dataArray) {
            for (ProductModel *model in arr) {
                for (ProductModel *chooseModel in _buyStateProductUserChooseArray) {
                    if ([chooseModel.cart_pro_id intValue] == [model.cart_pro_id intValue]) {
                        model.userChoose = YES;
                    }
                }
            }
        }
        
        
        [self.rTab reloadData];
        [self updateRtabTotolPrice];
        [self isAllChooseAndUpdateState];
        
        [self.right_button setTitle:@"编辑" forState:UIControlStateNormal];
        [_jiesuanBtn setTitle:@"去结算" forState:UIControlStateNormal];
        self.totolPriceLabel.hidden = NO;
        self.detailPriceLabel.hidden = NO;
    }
    
    
}



#pragma mark - 逻辑处理

-(NSArray *)getChoseProducts{
    NSMutableArray *theArr = [NSMutableArray arrayWithCapacity:1];
    for (NSArray *arr in self.rTab.dataArray) {
        for (ProductModel *model in arr) {
            if (model.userChoose) {
                [theArr addObject:model];
            }
        }
    }
    
    return theArr;
}


-(void)deleteUserChooseProducts{
    NSMutableArray *theArr = [NSMutableArray arrayWithCapacity:1];
    
    for (NSArray *arr in self.rTab.dataArray) {
        for (ProductModel *model in arr) {
            if (model.userChoose) {
                [theArr addObject:model];
            }
        }
    }
    
    
}


//更新下边价格信息view
-(void)updateRtabTotolPrice{
    
    _totolPrice = 0;
    
    CGFloat totolPrice_o = 0;
    
    
    for (NSArray *arr in self.rTab.dataArray) {
        for (ProductModel*model in arr) {
            if (model.userChoose) {
                CGFloat current_price = [model.current_price floatValue];
                _totolPrice += current_price * [model.product_num intValue];
                
                CGFloat o_price = [model.original_price floatValue];
                totolPrice_o += o_price * [model.product_num intValue];
                
            }
            
        }
    }
    
    
    //现价统计
    NSString *pStr = [NSString stringWithFormat:@"%.2f",_totolPrice];
    NSString *price = [NSString stringWithFormat:@"合计：￥%@",pStr];
    NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
    [aaa addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 3)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 3)];
    
    [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(237, 108, 22) range:NSMakeRange(3, pStr.length+1)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(3, pStr.length+1)];
    self.totolPriceLabel.attributedText = aaa;
    
    //原价统计
    self.detailPriceLabel.text = [NSString stringWithFormat:@"总额:￥%.1f  优惠:￥%.1f",totolPrice_o,totolPrice_o - _totolPrice];
    
    
}

//判断全选 并改变左下角全选状态
-(void)isAllChooseAndUpdateState{
    
    BOOL isAllChoose = YES;//全部全选
    
    NSInteger count = self.rTab.dataArray.count;
    
    for (int i = 0; i<count; i++) {
        BOOL isAllChooseOneSection = YES;//每个section全选
        NSArray *arr = self.rTab.dataArray[i];
        for (ProductModel *model in arr) {
            if (model.userChoose == NO) {
                isAllChooseOneSection = NO;
                isAllChoose = NO;
            }
            
        }
        if (isAllChooseOneSection) {//每个section全选
            [self setOpenArray1WithIndex:i];
        }else{
            [self setOpenArray0WithIndex:i];
        }
        
    }
    
    if (isAllChoose) {//全选
        self.allChooseBtn.selected = YES;
    }else{
        self.allChooseBtn.selected = NO;
    }
    
    [self.rTab reloadData];
}





//设置全选
-(void)setDownViewAllChooseBtnSelect{
    self.allChooseBtn.selected = YES;
    for (NSArray *arr in self.rTab.dataArray) {
        for (ProductModel*model in arr) {
            model.userChoose = YES;
        }
    }
    
    for (int i = 0; i<500; i++) {
        _open[i] = 1;
    }
    
    [self.rTab reloadData];
    [self updateRtabTotolPrice];
    
    
}

//设置全不选
-(void)setDownViewAllChooseBtnNoSelect{
    
    self.allChooseBtn.selected = NO;
    
    for (NSArray *arr in self.rTab.dataArray) {
        for (ProductModel*model in arr) {
            model.userChoose = NO;
        }
    }
    
    for (int i = 0; i<500; i++) {
        _open[i] = 0;
    }
    
    
    [self.rTab reloadData];
    [self updateRtabTotolPrice];
}


//记录购买状态下各个单品的userchoose
-(void)recordBuyStateProductUserChoose{
    _buyStateProductUserChooseArray = [NSMutableArray arrayWithCapacity:1];
    
    for (NSArray *arr in self.rTab.dataArray) {
        for (ProductModel *model in arr) {
            if (model.userChoose) {
                [_buyStateProductUserChooseArray addObject:model];
            }
        }
    }
    
    
}






//全选 反选
-(void)downViewallChooseBtnClicked:(UIButton*)sender{
    if (sender.selected) {//全部取消
        
        for (NSArray *arr in self.rTab.dataArray) {
            for (ProductModel*model in arr) {
                model.userChoose = NO;
            }
        }
        
        for (int i = 0; i<500; i++) {
            _open[i] = 0;
        }
        
    }else{//全选
        
        for (NSArray *arr in self.rTab.dataArray) {
            for (ProductModel*model in arr) {
                model.userChoose = YES;
            }
        }
        
        for (int i = 0; i<500; i++) {
            _open[i] = 1;
        }
        
    }
    
    sender.selected = !sender.selected;
    [self.rTab reloadData];
    [self updateRtabTotolPrice];
}

//设置header上的选择按钮
-(void)setOpenArray1WithIndex:(int)index{
    _open[index] = 1;
}
-(void)setOpenArray0WithIndex:(int)index{
    _open[index] = 0;
}







#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        NSArray *arr = [self getChoseProducts];
        
        NSMutableArray *pidsArray = [NSMutableArray arrayWithCapacity:1];
        
        for (ProductModel* model in arr) {
            [pidsArray addObject:model.cart_pro_id];
        }
        
        
        NSString *pids_str = [pidsArray componentsJoinedByString:@","];
        if (!_request) {
            _request = [YJYRequstManager shareInstance];
        }
        
        NSDictionary *dic = @{
                              @"authcode":[UserInfo getAuthkey],
                              @"cart_pro_id":pids_str
                              };
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        __weak typeof (self)bself = self;
        
        [_request requestWithMethod:YJYRequstMethodGet api:ORDER_DEL_CART_PRODUCT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
            
            _deleteState = NO;
            [bself.right_button setTitle:@"编辑" forState:UIControlStateNormal];
            [_jiesuanBtn setTitle:@"去结算" forState:UIControlStateNormal];
            bself.totolPriceLabel.hidden = NO;
            bself.detailPriceLabel.hidden = NO;
            _totolPrice = 0;
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        } failBlock:^(NSDictionary *result) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
    
    
    
    
    
}




#pragma mark - 请求网络数据

//更新购物车
-(void)updateShopCar{
    [_rTab showRefreshHeader:YES];
}


//获取购物车数据

-(void)prepareNetData{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"page":[NSString stringWithFormat:@"%d",_rTab.pageNum],
                          @"per_page":[NSString stringWithFormat:@"%d",G_PER_PAGE]
                          };
    
    __weak typeof (self)bself = self;
    
    _request_shopCarDetail = [_request requestWithMethod:YJYRequstMethodGet api:ORDER_GET_CART_PRODCUTS parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"-------%@",result);
        
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:1];
        
        for (NSArray *arr in list) {
            NSMutableArray *oneBrandArray = [NSMutableArray arrayWithCapacity:1];
            for (NSDictionary *dic in arr) {
                ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
                if (_deleteState) {
                    
                }else{
                    model.userChoose = YES;
                }
                [oneBrandArray addObject:model];
            }
            [dataArray addObject:oneBrandArray];
        }
        
        
        if (self.rTab.pageNum == 1 && dataArray.count == 0) {
            [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
        }else{
            if (_deleteState) {
                [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
                bself.rightString = @"取消";
            }else{
                [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
                bself.rightString = @"编辑";
            }
            
        }
        
        
        [_rTab reloadData:dataArray pageSize:G_PER_PAGE noDataView:[self resultViewWithType:PageResultType_nodata]];
        [self updateRtabTotolPrice];
        [self isAllChooseAndUpdateState];
        
        if (_rTab.pageNum == 1 && list.count == 0) {
            _noProductView.hidden = NO;
            _downView.hidden = YES;
        }else{
            _noProductView.hidden = YES;
            _downView.hidden = NO;
        }
        
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        
        

        
        

        
        
        
        
    } failBlock:^(NSDictionary *result) {
        [_rTab loadFail];
    }];
    
}


-(void)loadNewDataForTableView:(UITableView *)tableView{
    
    [_request removeOperation:_request_shopCarDetail];
    
    _rTab.pageNum = 1;
    
    for (int i = 0; i<500; i++) {
        _open[i] = 0;
    }
    
    
    self.allChooseBtn.selected = NO;
    
    NSString *pStr = @"0.00";
    NSString *price = [NSString stringWithFormat:@"合计：￥%@",pStr];
    NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
    [aaa addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 3)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 3)];
    [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(237, 108, 22) range:NSMakeRange(3, pStr.length+1)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(3, pStr.length+1)];
    self.totolPriceLabel.attributedText = aaa;
    self.detailPriceLabel.text = [NSString stringWithFormat:@"总额:￥%@  优惠:￥%@",@"0.0",@"0.0"];
    
    
    
    
    [self prepareNetData];
}

-(void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}



#pragma mark - RefreshDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = self.rTab.dataArray.count;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    
    NSArray *oneArray = self.rTab.dataArray[section];
    num = oneArray.count;
    
    return num;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/90];
    return height;
}



-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{

    return [GshopCarTableViewCell heightForCell];
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    
    CGFloat v_height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/90];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
    line.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:line];
    
    UIButton *chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chooseBtn setFrame:CGRectMake(5, v_height*0.5-17.5, 35, 35)];
    [chooseBtn setImage:[UIImage imageNamed:@"xuanzhong_no"] forState:UIControlStateNormal];
    [chooseBtn setImage:[UIImage imageNamed:@"shoppingcart_selected.png"] forState:UIControlStateSelected];
    chooseBtn.selected = _open[section];
    chooseBtn.tag = 10+section;
    [chooseBtn addTarget:self action:@selector(headerViewchooseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:chooseBtn];

    
    
    NSArray *arr = self.rTab.dataArray[section];
    ProductModel *model = arr[0];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(chooseBtn.frame)+5, chooseBtn.frame.origin.y, DEVICE_WIDTH - 50, 35)];
    titleLabel.text = model.brand_name;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor blackColor];
    [view addSubview:titleLabel];
    
    [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/90])];
    view.backgroundColor = [UIColor whiteColor];
    
    return view;
}




-(void)headerViewchooseBtnClicked:(UIButton *)sender{
     NSArray* arr = _rTab.dataArray[sender.tag - 10];
    
    int a = _open[sender.tag - 10];
    if (a == 0) {
        _open[sender.tag - 10] = 1;
        sender.selected = YES;
        for (ProductModel*model in arr) {
            model.userChoose = YES;
        }
        
    }else if (a == 1){
        _open[sender.tag - 10] = 0;
        sender.selected = NO;
        for (ProductModel*model in arr) {
            model.userChoose = NO;
        }
    }
    
    [_rTab reloadData];
    
    
    [self isAllChooseAndUpdateState];
    
    [self updateRtabTotolPrice];
    
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GshopCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GshopCarTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.delegate = self;
    [cell loadCustomViewWithIndex:indexPath];
    
    return cell;
}


- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
    
    NSArray *arr = self.rTab.dataArray[indexPath.section];
    ProductModel *model = arr[indexPath.row];
    
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    cc.isShopCarPush = YES;
    cc.productId = model.product_id;
    
    [self.navigationController pushViewController:cc animated:YES];
    
    
}


#pragma mark - 滑动删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle ==UITableViewCellEditingStyleDelete)
        
    {
        
        NSLog(@"%ld",(long)indexPath.section);
        NSLog(@"%ld", (long)indexPath.row);
        
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.rTab.dataArray[indexPath.section]];
        ProductModel *model = arr[indexPath.row];
        [self huadongshanchuWithcartProId:model.cart_pro_id];

            [arr removeObjectAtIndex:indexPath.row];
            [self.rTab.dataArray replaceObjectAtIndex:indexPath.section withObject:arr];
        
        [self.rTab deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        
        if (arr.count == 0) {
            [self.rTab.dataArray removeObjectAtIndex:indexPath.section];
            [self.rTab reloadData];
        }
        
        if (self.rTab.dataArray.count == 0) {
            [self.rTab reloadData:self.rTab.dataArray pageSize:G_PER_PAGE noDataView:[self resultViewWithType:PageResultType_nodata]];
            _downView.hidden = YES;
            [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
            self.right_button.hidden = YES;
        }
        
        [self isAllChooseAndUpdateState];
        [self updateRtabTotolPrice];
        
        
    }
}



-(void)huadongshanchuWithcartProId:(NSString *)thePid{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"cart_pro_id":thePid
                          };
    

    [_request requestWithMethod:YJYRequstMethodGet api:ORDER_DEL_CART_PRODUCT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"%@",result);
    } failBlock:^(NSDictionary *result) {
        NSLog(@"%@",result);
        
    }];
}






#pragma mark - 无数据默认view
-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    if (type == PageResultType_nodata){
        
        content = @"购物车还是空的";
        
    }
    

    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"gouwuche-kong.png"]
                                                    title:@"温馨提示"
                                                  content:content];
    
    
    
    return result;
}



@end
