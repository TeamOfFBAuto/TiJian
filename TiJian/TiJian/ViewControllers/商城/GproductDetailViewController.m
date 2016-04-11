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
#import "RCDChatViewController.h"
#import "ConfirmOrderViewController.h"
#import "ProductModel.h"
#import "CouponModel.h"
#import "GoneClassListViewController.h"
#import "GmyFootViewController.h"
#import "GCustomSearchViewController.h"
#import "GUpToolView.h"
#import "GBrandHomeViewController.h"
#import "ChooseHopitalController.h"//选择分院

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
    
    
    
    GproductDetailTableViewCell *_tmpCell;
    GproductDirectoryTableViewCell *_tmpCell1;
    
    
    UIView *_downView;
    
    UITableView *_hiddenView;
    
    UILabel *_shopCarNumLabel;
    
    NSArray *_productProjectListDataArray;//项目列表
    
    NSArray *_productCommentArray;//商品评论
    
    NSMutableArray *_LookAgainProductListArray;//看了又看
    
    
    UIButton *_shoucang_btn;//收藏
    
    UIButton *_addShopCarBtn;//加入购物车按钮
    UIButton *_gouwucheOneBtn;//购物车btn
    int _gouwucheNum;//购物车里商品数量
    
    //动画相关
    CALayer     *layer;
    UIImageView *_imageView;
    UIButton    *_btn;
    UIBezierPath *_path;
    
    
    
    //顶部工具栏
    GUpToolView *_upToolView;
    
    UIView *_downToolBlackView;
    
    BOOL _toolShow;
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
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_LOGIN object:nil];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    self.rightImage = [UIImage imageNamed:@"dian_three.png"];
    
    self.myTitle = @"产品详情";
    _gouwucheNum = 0;
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCarNum) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateIsFavorAndShopCarNum) name:NOTIFICATION_LOGIN object:nil];
    
    
    [self prepareNetData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 点击处理

-(void)rightButtonTap:(UIButton *)sender{
    
    _toolShow = !_toolShow;
    
    if (_toolShow) {
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        } completion:^(BOOL finished) {
            if (!_downToolBlackView) {
                _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                _downToolBlackView.backgroundColor = [UIColor blackColor];
                _downToolBlackView.alpha = 0.6;
                [self.view addSubview:_downToolBlackView];
                
                [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
            }
            _downToolBlackView.hidden = NO;
        }];
        
        
    }else{
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0.6;
            [self.view addSubview:_downToolBlackView];
        }
        _downToolBlackView.hidden = YES;
        
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
        }];
    }
    
    
}

-(void)upToolShou{
    
    if (_toolShow) {
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0.6;
            [self.view addSubview:_downToolBlackView];
        }
        _downToolBlackView.hidden = YES;
        
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
        }];
        
        _toolShow = !_toolShow;
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        } completion:^(BOOL finished) {
            if (!_downToolBlackView) {
                _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                _downToolBlackView.backgroundColor = [UIColor blackColor];
                _downToolBlackView.alpha = 0.6;
                [self.view addSubview:_downToolBlackView];
                
                [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
            }
            _downToolBlackView.hidden = NO;
        }];
        _toolShow = !_toolShow;
    }
}



//工具栏按钮点击
-(void)upToolBtnClicked:(NSInteger)index{
    if (index == 10) {//足迹
        if ([LoginViewController isLogin]) {
            GmyFootViewController *cc = [[GmyFootViewController alloc]init];
            [self.navigationController pushViewController:cc animated:YES];
        }else{
            [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                if (success) {
                    GmyFootViewController *cc = [[GmyFootViewController alloc]init];
                    [self.navigationController pushViewController:cc animated:YES];
                }
                
            }];
        }
        
    }else if (index == 11){//搜索
        GCustomSearchViewController *cc = [[GCustomSearchViewController alloc]init];
        [self.navigationController pushViewController:cc animated:YES];
    }else if (index == 12){//首页
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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
//            _downView.top = self.view.size.height;
            self.myTitle = @"体检项目";
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _tab.top = 0;
            _hiddenView.top = CGRectGetMaxY(_tab.frame);
//            _downView.top = DEVICE_HEIGHT - 50-64;
            self.myTitle = @"产品详情";
        }];
    }
    
    
    
    
}




#pragma mark - 网络请求
-(void)prepareNetData{
    
    _request = [YJYRequstManager shareInstance];
    _count = 0;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self getProductDetail];//单品详情和看了又看
    [self getProductConmment];//产品评论
    
    [self prepareProductProjectList];//具体项目
    [self getshopcarNum];//购物车数量
    
    //浏览量加1
    [self productLiulanNum];
    
    //足迹
    [self addProductFoot];
    
    
}

//添加足迹
-(void)addProductFoot{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic;
    if ([LoginViewController isLogin]) {
        dic = @{
                @"authcode":[UserInfo getAuthkey],
                @"product_id":self.productId
                };
        
        [_request requestWithMethod:YJYRequstMethodPost api:AddMyProductFoot parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
            
        } failBlock:^(NSDictionary *result) {
            
        }];
    }
    
    
}


//商品浏览+1
-(void)productLiulanNum{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic;
    if ([LoginViewController isLogin]) {
        dic = @{
                @"product_id":self.productId,
                @"authcode":[UserInfo getAuthkey]
                };
    }else{
        dic = @{
                @"product_id":self.productId,
                };
    }
    
    [_request requestWithMethod:YJYRequstMethodGet api:StoreProductLiulanNumAdd parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
    } failBlock:^(NSDictionary *result) {
        
    }];
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
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    
}


//套餐详情
-(void)getProductDetail{
    
    NSDictionary *parameters;
    
    if ([LoginViewController isLogin]) {
        parameters = @{
                       @"product_id":self.productId,
                       @"authcode":[UserInfo getAuthkey]
                       };
    }else{
        parameters = @{
                       @"product_id":self.productId
                       };
    }
    
    __weak typeof (self)bself = self;
    
    _request_productDetail = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductDetail parameters:parameters constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSDictionary *dic = [result dictionaryValueForKey:@"data"];
        
        self.theProductModel = [[ProductModel alloc]initWithDictionary:dic];
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in self.theProductModel.coupon_list) {
            CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        self.theProductModel.coupon_list = (NSArray*)arr;

        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        [bself prepareLookAgainNetData];
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}


//看了又看
-(void)prepareLookAgainNetData{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    
    
    NSString *theP_id;
    NSString *theC_id;
    
    if (self.userChooseLocationDic) {
        
        NSString *a_p = [self.userChooseLocationDic stringValueForKey:@"province_id"];
        NSString *a_c = [self.userChooseLocationDic stringValueForKey:@"city_id"];
        if ([LTools isEmpty:a_p] || [LTools isEmpty:a_c]) {
            theP_id = [GMAPI getCurrentProvinceId];
            theC_id = [GMAPI getCurrentCityId];
        }else{
            theP_id = a_p;
            theC_id = a_c;
        }
        
    }else{
        theP_id = [GMAPI getCurrentProvinceId];
        theC_id = [GMAPI getCurrentCityId];
    }
    
    
    
    NSDictionary *dic = @{
                          @"brand_id":self.theProductModel.brand_id,
                          @"province_id":theP_id,
                          @"city_id":theC_id,
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
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}



//获取购物车数量
-(void)getshopcarNum{
    
    if ([LoginViewController isLogin]) {
       [self getShopcarNumWithLoginSuccess];
    }else{
        _count+=1;
    }
    
    
}

//获取购物车数量
-(void)getShopcarNumWithLoginSuccess{
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey]
                          };
    _request_GetShopCarNum = [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _shopCarDic = result;
        _gouwucheNum = [_shopCarDic intValueForKey:@"num"];
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
 
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}



//登录成功更新购物车数量
-(void)updateShopCarNum{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey]
                          };
    _request_GetShopCarNum = _request_GetShopCarNum = [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _shopCarDic = result;
        
        if (_shopCarNumLabel) {
            
            _shopCarNumLabel.text = [NSString stringWithFormat:@"%d",[_shopCarDic intValueForKey:@"num"]];
            _gouwucheNum = [_shopCarDic intValueForKey:@"num"];
            
            [self updateShopCarNumAndFrame];
        }
        
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}

//登录成功更新商品收藏和购物车数量
-(void)updateIsFavorAndShopCarNum{
    NSDictionary *parameters;
    
    if ([LoginViewController isLogin]) {
        parameters = @{
                       @"product_id":self.productId,
                       @"authcode":[UserInfo getAuthkey]
                       };
    }else{
        parameters = @{
                       @"product_id":self.productId
                       };
    }
    
    _request_productDetail = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductDetail parameters:parameters constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSDictionary *dic = [result dictionaryValueForKey:@"data"];
        
        self.theProductModel = [[ProductModel alloc]initWithDictionary:dic];
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in self.theProductModel.coupon_list) {
            CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        self.theProductModel.coupon_list = (NSArray*)arr;
        
        if ([self.theProductModel.is_favor intValue] == 1) {//已收藏
            _shoucang_btn.selected = YES;
        }else{
            _shoucang_btn.selected = NO;
        }
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    
    [self updateShopCarNum];
    
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
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}



//添加商品到购物车
-(void)addProductToShopCar{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"product_id":self.productId,
                          @"product_num":@"1"
                          };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof (self)bself = self;
    [_request requestWithMethod:YJYRequstMethodPost api:ORDER_ADD_TO_CART parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        _gouwucheNum += 1;
        
        [bself startShopCarAnimation];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}


#pragma mark - 动画相关
//加入购物车动画效果
-(void)startShopCarAnimation{
    
    
    if (!_path) {
        _path = [UIBezierPath bezierPath];
        [_path moveToPoint:CGPointMake(DEVICE_WIDTH-_addShopCarBtn.frame.size.width*0.25, DEVICE_HEIGHT - _addShopCarBtn.frame.size.height - 64)];//开始点
        [_path addQuadCurveToPoint:CGPointMake(DEVICE_WIDTH - _addShopCarBtn.frame.size.width - _shoucang_btn.frame.size.width*0.5, DEVICE_HEIGHT - 64 - _shoucang_btn.frame.size.height*0.5) controlPoint:CGPointMake(DEVICE_WIDTH - _addShopCarBtn.frame.size.width, DEVICE_HEIGHT - 300)];//结束点
    }
    
    
    if (!layer) {
        _btn.enabled = NO;
        layer = [CALayer layer];
        
        layer.contents = (__bridge id)[UIImage imageNamed:@"TabCartSelected.png"].CGImage;
        if (self.gouwucheProductImage) {
            layer.contents = (__bridge id)self.gouwucheProductImage.CGImage;
        }
        layer.contentsGravity = kCAGravityResizeAspectFill;
        layer.bounds = CGRectMake(0, 0, 20, 15);
//        [layer setCornerRadius:CGRectGetHeight([layer bounds]) / 2];
        layer.masksToBounds = YES;
        layer.position =CGPointMake(50, 150);
        [self.view.layer addSublayer:layer];
    }
    [self groupAnimation];
    
}

-(void)groupAnimation{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = _path.CGPath;
    animation.rotationMode = kCAAnimationRotateAuto;
    CABasicAnimation *expandAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    expandAnimation.duration = 0.3f;
    expandAnimation.fromValue = [NSNumber numberWithFloat:1];
    expandAnimation.toValue = [NSNumber numberWithFloat:2.0f];
    expandAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *narrowAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    narrowAnimation.beginTime = 0.3;
    narrowAnimation.fromValue = [NSNumber numberWithFloat:2.0f];
    narrowAnimation.duration = 0.3f;
    narrowAnimation.toValue = [NSNumber numberWithFloat:0.5f];
    
    narrowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,expandAnimation,narrowAnimation];
    groups.duration = 0.6f;
    groups.removedOnCompletion=NO;
    groups.fillMode=kCAFillModeForwards;
    groups.delegate = self;
    [layer addAnimation:groups forKey:@"group"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [layer animationForKey:@"group"]) {
        _btn.enabled = YES;
        [layer removeFromSuperlayer];
        layer = nil;
        
        CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        shakeAnimation.duration = 0.25f;
        shakeAnimation.fromValue = [NSNumber numberWithFloat:-5];
        shakeAnimation.toValue = [NSNumber numberWithFloat:5];
        shakeAnimation.autoreverses = YES;
//        [_shopCarNumLabel.layer addAnimation:shakeAnimation forKey:nil];
//        [_gouwucheOneBtn.imageView.layer addAnimation:shakeAnimation forKey:nil];
        [_gouwucheOneBtn.layer addAnimation:shakeAnimation forKey:nil];
        
        _shopCarNumLabel.text = [NSString stringWithFormat:@"%d",_gouwucheNum];
        
        [self updateShopCarNumAndFrame];
        
    }
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
        
        
        [self creatUpToolView];
    }
    
    
}



#pragma mark - 视图创建

-(void)creatUpToolView{
    
    _upToolView = [[GUpToolView alloc]initWithFrame:CGRectZero count:3];
    [self.view addSubview:_upToolView];
    __weak typeof (self)bself = self;
    [_upToolView setUpToolViewBlock:^(NSInteger index) {
        [bself upToolBtnClicked:index];
    }];
}

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
    
    _addShopCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _addShopCarBtn.tag = 104;
    CGFloat theW = [GMAPI scaleWithHeight:50 width:0 theWHscale:180.0/100];
    [_addShopCarBtn setFrame:CGRectMake(_downView.frame.size.width-theW, 0, theW, 50)];
    _addShopCarBtn.backgroundColor = RGBCOLOR(224, 103, 20);
    [_addShopCarBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    if (self.VoucherId) {
        [_addShopCarBtn setTitle:@"立即购买" forState:UIControlStateNormal];
    }
    [_addShopCarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _addShopCarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_addShopCarBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:_addShopCarBtn];
    
    CGFloat tw = (_downView.frame.size.width-theW)/4;
    NSArray *titleArray = @[@"客服",@"收藏",@"预约",@"购物车"];
    NSArray *imageNameArray = @[@"kefu_pd.png",@"shoucang_pd.png",@"yuyue_pd.png",@"gouwuche_pd.png"];
    for (int i = 0; i<4; i++) {
        UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [oneBtn setFrame:CGRectMake(i*tw, 0, tw, 50)];
        [oneBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        [oneBtn setImage:[UIImage imageNamed:imageNameArray[i]] forState:UIControlStateNormal];
        if (i == 1) {
            _shoucang_btn = oneBtn;
            [oneBtn setImage:[UIImage imageNamed:@"shoucang_pd.png"] forState:UIControlStateNormal];
            [oneBtn setImage:[UIImage imageNamed:@"yishoucang.png"] forState:UIControlStateSelected];
            if ([self.theProductModel.is_favor intValue] == 1) {//已收藏
                oneBtn.selected = YES;
            }else{
                oneBtn.selected = NO;
            }
            
        }
        if (i<3) {
            [oneBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 18, 25, 0)];
        }else{
            if (DEVICE_WIDTH<375) {//4s 5s
                [oneBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 19, 25, 14)];
            }else{
                [oneBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 25, 25, 0)];
            }
            
        }
        
        
        
        
        
        [oneBtn setTitleEdgeInsets:UIEdgeInsetsMake(25, -20, 0, 0)];
        oneBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        oneBtn.tag = 100+i;
        [oneBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_downView addSubview:oneBtn];
        
        if (i == 3) {
            _shopCarNumLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            _shopCarNumLabel.textColor = RGBCOLOR(242, 120, 47);
            _shopCarNumLabel.backgroundColor = [UIColor whiteColor];
            _shopCarNumLabel.layer.cornerRadius = 7;
            _shopCarNumLabel.layer.borderColor = [[UIColor whiteColor]CGColor];
            _shopCarNumLabel.layer.borderWidth = 0.5f;
            _shopCarNumLabel.layer.masksToBounds = YES;
            _shopCarNumLabel.font = [UIFont systemFontOfSize:11];
            _shopCarNumLabel.textAlignment = NSTextAlignmentCenter;
            
            _shopCarNumLabel.text = [NSString stringWithFormat:@"0"];
            
            [oneBtn addSubview:_shopCarNumLabel];
            
            _gouwucheOneBtn = oneBtn;
            
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
        [_shopCarNumLabel setFrame:CGRectMake(oneBtn.bounds.size.width - with-6, -2, with+5, 15)];
        
    }
    
}






-(void)creatHiddenView{
    _hiddenView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tab.frame), DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStyleGrouped];
    _hiddenView.delegate = self;
    _hiddenView.dataSource = self;
    _hiddenView.backgroundColor = [UIColor whiteColor];
    _hiddenView.tag = 1001;
    [self.view addSubview:_hiddenView];
    
}

/**
 *  开启客服
 */
- (void)clickToChat
{
    [MiddleTools pushToChatWithSourceType:SourceType_ProductDetail fromViewController:self model:_theProductModel];
}


-(void)downBtnClicked:(UIButton *)sender{
    
    if (sender.tag == 100) {//客服
        
        [LoginViewController isLogin:self loginBlock:^(BOOL success) {
            if (success) {//登录成功
                
                [self clickToChat];
                
            }else{
                
            }
        }];
        
    }else if (sender.tag == 101){//收藏
        
        if ([LoginViewController isLogin]) {//已登录
            [self shoucangProductWithState:sender.selected];
        }else{
            [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                if (success) {//登录成功
                    
                }else{
                    
                }
            }];
        }
        
        
    }else if (sender.tag == 102){//预约
        
        if (self.VoucherId) {//企业代金券
            
        }else{
            //update by lcw 2期 直接预约
            if ([LoginManager isLogin:self]) {//已登录
                ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
                [choose apppointNoPayWithProductModel:self.theProductModel
                                               gender:[_theProductModel.gender_id intValue]
                                         noAppointNum:1000];
                choose.lastViewController = self;
                [self.navigationController pushViewController:choose animated:YES];
            }
        }
        
        
        
    }else if (sender.tag == 103){//购物车
        
        if (self.isShopCarPush) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            if ([LoginViewController isLogin]) {//已登录
                GShopCarViewController *cc = [[GShopCarViewController alloc]init];
                [self.navigationController pushViewController:cc animated:YES];
            }else{
                [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                    if (success) {
                        GShopCarViewController *cc = [[GShopCarViewController alloc]init];
                        [self.navigationController pushViewController:cc animated:YES];
                    }else{
                        
                    }
                }];
            }
        }
        
    }else if (sender.tag == 104){//加入购物车
        
        [LoginViewController isLogin:self loginBlock:^(BOOL success) {
            if (success) {
                //代金券过来 直接去确认订单
                if (self.VoucherId) {
                    
                    [self pushToConfirmOrder];
                    
                }else
                {
                    [self addProductToShopCar];
                }
            }
        }];
    }
}


- (void)pushToConfirmOrder
{
    ConfirmOrderViewController *cc = [[ConfirmOrderViewController alloc]init];
    cc.lastViewController = self;
    cc.voucherId = self.VoucherId;
//    aModel.current_price\product_num、brand_name、cover_pic
    self.theProductModel.product_num = @"1";
    self.theProductModel.current_price = _theProductModel.setmeal_price;
    self.theProductModel.product_name = _theProductModel.setmeal_name;
    cc.dataArray = [NSArray arrayWithObject:self.theProductModel];
    [self.navigationController pushViewController:cc animated:YES];
}

/**
 *  收藏 取消收藏商品
 *
 *  @param type 1 收藏 2 取消收藏
 */
-(void)shoucangProductWithState:(BOOL)type{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    NSDictionary *dic = @{
                          @"product_id":self.theProductModel.product_id,
                          @"authcode":[UserInfo getAuthkey]
                          };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *api;
    if (type) {//已收藏
        api = QUXIAOSHOUCANG;
    }else{
        api = SHOUCANGRODUCT;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [_request requestWithMethod:YJYRequstMethodGet api:api parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (type) {//已收藏变未收藏
            _shoucang_btn.selected = NO;
        }else{
            _shoucang_btn.selected = YES;
        }
        
        [GMAPI showAutoHiddenMBProgressWithText:[result stringValueForKey:@"msg"] addToView:self.view];
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}





#pragma mark - UITableViewDelegate && UITableViewDataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1000) {//单品详情
        static NSString *identifier = @"identifier";
        GproductDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[GproductDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.delegate = self;
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        [cell loadCustomViewWithIndex:indexPath productCommentArray:_productCommentArray lookAgainArray:_LookAgainProductListArray];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (tableView.tag == 1001){//项目详情
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
        num = 1;
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
            _tmpCell.delegate = self;
        }
        for (UIView *view in _tmpCell.contentView.subviews) {
            [view removeFromSuperview];
        }
        height = [_tmpCell loadCustomViewWithIndex:indexPath productCommentArray:_productCommentArray lookAgainArray:_LookAgainProductListArray];
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
        if (section == 0) {
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
            
            UIButton *tishiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [tishiBtn setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60])];
            tishiBtn.backgroundColor = [UIColor whiteColor];
            tishiBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            [tishiBtn setTitleColor:RGBCOLOR(26, 27, 28) forState:UIControlStateNormal];
            [tishiBtn setImage:[UIImage imageNamed:@"jiantou_down"] forState:UIControlStateNormal];
            [tishiBtn setTitle:@"下拉显示套餐详情" forState:UIControlStateNormal];
            [tishiBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            [view addSubview:tishiBtn];
            
            UIView *titleView =[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tishiBtn.frame),DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/100])];
            titleView.backgroundColor = [UIColor whiteColor];
            [view addSubview:titleView];
            
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, [GMAPI scaleWithHeight:titleView.frame.size.height width:0 theWHscale:145.0/100], titleView.frame.size.height)];
            [imv setImage:[UIImage imageNamed:@"tijianxiangmu1.png"]];
            [titleView addSubview:imv];
            
            UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+10, 0, titleView.frame.size.width - 10 - imv.frame.size.width - 5 - 5, titleView.frame.size.height)];
            tLabel.font = [UIFont systemFontOfSize:15];
            tLabel.textColor = [UIColor blackColor];
//            tLabel.backgroundColor = [UIColor orangeColor];
            tLabel.numberOfLines = 2.f;
            tLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            tLabel.text = self.theProductModel.setmeal_name;
            [titleView addSubview:tLabel];
            
            UIView *blueView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleView.frame), DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60])];
            blueView.backgroundColor = RGBCOLOR(222, 245, 255);
            [view addSubview:blueView];
            
            UILabel *xuhaoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, blueView.frame.size.width*1/7, blueView.frame.size.height)];
            xuhaoLabel.text = @"序号";
            xuhaoLabel.font = [UIFont systemFontOfSize:12];
            xuhaoLabel.textAlignment = NSTextAlignmentCenter;
            [blueView addSubview:xuhaoLabel];
            
            UILabel *mingxiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(xuhaoLabel.frame), 0, blueView.frame.size.width*2/7, xuhaoLabel.frame.size.height)];
            mingxiLabel.text = @"明细";
            mingxiLabel.font = [UIFont systemFontOfSize:12];
            mingxiLabel.textAlignment = NSTextAlignmentCenter;
            [blueView addSubview:mingxiLabel];
            
            
            UILabel *zuheneirongLbel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(mingxiLabel.frame), 0, blueView.frame.size.width*4/7, blueView.frame.size.height)];
            zuheneirongLbel.text = @"组合内容";
            zuheneirongLbel.font = [UIFont systemFontOfSize:12];
            zuheneirongLbel.textAlignment = NSTextAlignmentCenter;
            [blueView addSubview:zuheneirongLbel];
            
            
            
        }else{
            
//            [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/60])];
//            view.backgroundColor = RGBCOLOR(222, 245, 255);
//            
//            UILabel *canhouxiangmuLabel = [[UILabel alloc]initWithFrame:view.bounds];
//            canhouxiangmuLabel.textAlignment = NSTextAlignmentCenter;
//            canhouxiangmuLabel.text = @"餐后项目";
//            canhouxiangmuLabel.font = [UIFont systemFontOfSize:12];
//            [view addSubview:canhouxiangmuLabel];
            
            
            
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
    cc.userChooseLocationDic = self.userChooseLocationDic;
    [self.navigationController pushViewController:cc animated:YES];
}

//跳转品牌店
-(void)goToBrandStoreHomeVc{
    GBrandHomeViewController *cc = [[GBrandHomeViewController alloc]init];
    cc.brand_name = self.theProductModel.brand_name;
    cc.brand_id = self.theProductModel.brand_id;
    [self.navigationController pushViewController:cc animated:YES];
}



@end
