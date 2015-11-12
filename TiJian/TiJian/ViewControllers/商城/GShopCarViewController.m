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

@interface GShopCarViewController ()<UITableViewDataSource,RefreshDelegate>
{
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_shopCarDetail;
    
    int _page;
    int _per_page;
    
    UIView *_downView;
    
    int _open[500];
    
    
}
@end

@implementation GShopCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"购物车";
    
    for (int i = 0; i<500; i++) {
        _open[i] = 0;
    }
    
    
    _request = [YJYRequstManager shareInstance];
    _page = 1;
    _per_page = 20;
    
    
    [self creaTab];
    
    [self creatDownView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)creaTab{
    self.rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    self.rTab.refreshDelegate = self;
    self.rTab.dataSource = self;
    
    [self.view addSubview:self.rTab];
    
    [self.rTab showRefreshHeader:YES];
    
}


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
    [self.allChooseBtn setImage:[UIImage imageNamed:@"xuanzhong.png"] forState:UIControlStateSelected];
    
    
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
    
    
    UIButton *jiesuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    jiesuanBtn.backgroundColor = RGBCOLOR(237, 108, 22);
    jiesuanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [jiesuanBtn setFrame:CGRectMake(CGRectGetMaxX(midleView.frame), 0, DEVICE_WIDTH*215.0/750, 50)];
    [jiesuanBtn setTitle:@"去结算" forState:UIControlStateNormal];
    [_downView addSubview:jiesuanBtn];
    
    
    [self.view addSubview:_downView];
    
}


#pragma mark - 请求网络数据
-(void)prepareNetData{
    
    NSDictionary *dic = @{
                          @"authcode":[GMAPI testAuth],
                          @"page":[NSString stringWithFormat:@"%d",_page],
                          @"per_page":[NSString stringWithFormat:@"%d",_per_page]
                          };
    
    _request_shopCarDetail = [_request requestWithMethod:YJYRequstMethodGet api:ORDER_GET_CART_PRODCUTS parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"-------%@",result);
        
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:1];
        
        for (NSArray *arr in list) {
            NSMutableArray *oneBrandArray = [NSMutableArray arrayWithCapacity:1];
            for (NSDictionary *dic in arr) {
                ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
                [oneBrandArray addObject:model];
            }
            [dataArray addObject:oneBrandArray];
        }
        
        [self.rTab reloadData:dataArray pageSize:_per_page];
        
        
    } failBlock:^(NSDictionary *result) {
        NSLog(@"aa");
    }];
}


-(void)loadNewDataForTableView:(UITableView *)tableView{
    
    [_request removeOperation:_request_shopCarDetail];
    
    _page = 1;
    _per_page = 20;
    
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
    CGFloat height = 0;
    height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/250];
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    
    CGFloat v_height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/90];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
    line.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:line];
    
    UIButton *chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chooseBtn setFrame:CGRectMake(5, v_height*0.5-17.5, 35, 35)];
    [chooseBtn setImage:[UIImage imageNamed:@"xuanzhong_no.png"] forState:UIControlStateNormal];
    [chooseBtn setImage:[UIImage imageNamed:@"xuanzhong.png"] forState:UIControlStateSelected];
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
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
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




//更新下边价格信息view
-(void)updateRtabTotolPrice{
    
    CGFloat totolPrice = 0;
    
    CGFloat totolPrice_o = 0;
    
    
    for (NSArray *arr in self.rTab.dataArray) {
        for (ProductModel*model in arr) {
            if (model.userChoose) {
                CGFloat current_price = [model.current_price floatValue];
                totolPrice += current_price * [model.product_num intValue];
                
                CGFloat o_price = [model.original_price floatValue];
                totolPrice_o += o_price * [model.product_num intValue];
                
            }
            
        }
    }
    
    
    //现价统计
    NSString *pStr = [NSString stringWithFormat:@"%.2f",totolPrice];
    NSString *price = [NSString stringWithFormat:@"合计：￥%@",pStr];
    NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
    [aaa addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 3)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 3)];
    
    [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(237, 108, 22) range:NSMakeRange(3, pStr.length+1)];
    [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(3, pStr.length+1)];
    self.totolPriceLabel.attributedText = aaa;
    
    //原价统计
    self.detailPriceLabel.text = [NSString stringWithFormat:@"总额:￥%.1f  优惠:￥%.1f",totolPrice_o,totolPrice_o - totolPrice];
    
    
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


@end
