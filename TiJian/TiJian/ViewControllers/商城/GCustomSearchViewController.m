//
//  GCustomSearchViewController.m
//  TiJian
//
//  Created by gaomeng on 16/1/13.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GCustomSearchViewController.h"
#import "NSDictionary+GJson.h"
#import "RefreshTableView.h"
#import "CycleAdvModel.h"
#import "GoneClassListViewController.h"
#import "GproductDetailViewController.h"
#import "GProductCellTableViewCell.h"
#import "PhysicalTestResultController.h"
#import "PersonalCustomViewController.h"

#import "LBannerView.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ProgressView.h"

#import "GShopCarViewController.h"

#import "DLNavigationEffectKit.h"

#import "GSearchView.h"

#import "RCDChatViewController.h"

#import "ProductListViewController.h"

@interface GCustomSearchViewController ()<UITextFieldDelegate,UIScrollViewDelegate,GsearchViewDelegate>
{
    
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_hotSearch;
    
    UIView *_mySearchView;//点击搜索盖上的搜索浮层
    UIView *_searchView;//输入框下层view
    GSearchView *_theCustomSearchView;//自定义搜索view
    NSArray *_hotSearchArray;//热门搜索
    
    UIBarButtonItem *_rightItem1;
    UILabel *_rightItem2Label;
    UIView *_kuangView;
    
}

@property(nonatomic,strong)NSMutableArray *upAdvArray;

@property(nonatomic,strong)UIView *theTopView;

@end

@implementation GCustomSearchViewController

- (void)dealloc
{
    NSLog(@"dealloc %@",self);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hiddenNavigationBar:YES animated:animated];
    
    if (_theCustomSearchView) {
        [_theCustomSearchView.tab reloadData];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hiddenNavigationBar:NO animated:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavigation];
    [self creatMysearchView];
    [self getHotSearch];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"%s",__FUNCTION__);
    _mySearchView.hidden = NO;
    _theCustomSearchView.dataArray = [GMAPI cacheForKey:USERCOMMONLYUSEDSEARCHWORD];
    
    [_theCustomSearchView.tab reloadData];

    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        alphaView.alpha = 1;
    }
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField{

}




- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self searchBtnClickedWithStr:self.searchTf.text isHotSearch:NO];
    
    return YES;
}



-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot{
    
    
    [_searchTf resignFirstResponder];

    if (!isHot) {
        if (![LTools isEmpty:self.searchTf.text]) {
            [GMAPI setuserCommonlyUsedSearchWord:self.searchTf.text];
        }
        
    }
    
    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
    cc.theSearchWorld = theWord;
    [self.navigationController pushViewController:cc animated:YES];
    
    
}


#pragma mark - 返回上个界面
-(void)gogoback{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - 请求网络数据

//热门搜索
-(void)getHotSearch{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    _request_hotSearch = [_request requestWithMethod:YJYRequstMethodGet api:ProductHotSearch parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _hotSearchArray = [result arrayValueForKey:@"list"];
        _theCustomSearchView.hotSearch = _hotSearchArray;
        [_theCustomSearchView.tab reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
}



#pragma mark - 改变searchTf和框的大小
/**
 *  改变searchTf和框的大小
 *
 *  @param state 1 编辑状态 0常态
 */
-(void)changeSearchViewAndKuangFrameAndTfWithState:(int)state{
    if (state == 0) {//常态
        [_searchView setFrame:CGRectMake(0, 7, DEVICE_WIDTH - 70, 30)];
        [_kuangView setFrame:CGRectMake(0, 0, _searchView.frame.size.width, 30)];
        [self.searchTf setFrame:CGRectMake(30, 0, _kuangView.frame.size.width - 30, 30)];
        
    }else if (state == 1){//编辑状态
        [_searchView setFrame:CGRectMake(0, 7, DEVICE_WIDTH - 20, 30)];
        [_kuangView setFrame:CGRectMake(0, 0, _searchView.frame.size.width - 30, 30)];
        [self.searchTf setFrame:CGRectMake(30, 0, _kuangView.frame.size.width - 30, 30)];
        [self.navigationController.navigationBar bringSubviewToFront:_searchView];
    }
}


#pragma mark - 视图创建

//创建自定义navigation
- (void)setupNavigation{
    
    [self resetShowCustomNavigationBar:YES];

    _searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 7, DEVICE_WIDTH - 70, 30)];
    
    //带框的view
    _kuangView = [[UIView alloc]initWithFrame:CGRectZero];
    _kuangView.layer.cornerRadius = 5;
    _kuangView.layer.borderColor = [RGBCOLOR(192, 193, 194)CGColor];
    _kuangView.layer.borderWidth = 0.5;
    [_searchView addSubview:_kuangView];
    
    
    UIImageView *fdjImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 13, 13)];
    [fdjImv setImage:[UIImage imageNamed:@"search_fangdajing.png"]];
    [_searchView addSubview:fdjImv];
    
    self.searchTf = [[UITextField alloc]initWithFrame:CGRectZero];
    self.searchTf.font = [UIFont systemFontOfSize:13];
    self.searchTf.backgroundColor = [UIColor whiteColor];
    self.searchTf.layer.cornerRadius = 5;
    self.searchTf.placeholder = @"输入您要找的商品";
    self.searchTf.delegate = self;
    self.searchTf.returnKeyType = UIReturnKeySearch;//lcw
    [_kuangView addSubview:self.searchTf];
    
    
    _rightItem1 = [[UIBarButtonItem alloc]initWithCustomView:_searchView];
    
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:      UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spaceButtonItem setWidth:-5];
    
    self.currentNavigationItem.rightBarButtonItems = @[spaceButtonItem,_rightItem1];

    
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [[UIView alloc] initWithFrame:effectView.bounds];
        [effectView addSubview:alphaView];
        alphaView.backgroundColor = [UIColor whiteColor];
        alphaView.tag = 10000;
    }
    
    
    [self changeSearchViewAndKuangFrameAndTfWithState:1];
    
    if (!_rightItem2Label) {
        _rightItem2Label = [[UILabel alloc]initWithFrame:CGRectMake(_searchView.frame.size.width - 45, 0, 45, 30)];
        _rightItem2Label.text = @"取消";
        _rightItem2Label.font = [UIFont systemFontOfSize:13];
        _rightItem2Label.textColor = RGBCOLOR(134, 135, 136);
        _rightItem2Label.textAlignment = NSTextAlignmentRight;
        [_rightItem2Label addTaget:self action:@selector(myNavcRightBtnClicked) tag:0];
    }
    [_searchView addSubview:_rightItem2Label];
    
    [self.searchTf becomeFirstResponder];
}


//创建搜索界面
-(void)creatMysearchView{
    
    _mySearchView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _mySearchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_mySearchView];
    
    
    _theCustomSearchView = [[GSearchView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, _mySearchView.frame.size.height)];
    _theCustomSearchView.delegate = self;
    
    __weak typeof (self)bself = self;
    
    [_theCustomSearchView setKuangBlock:^(NSString *theStr) {
        [bself searchBtnClickedWithStr:theStr isHotSearch:NO];
    }];
    
    [_mySearchView addSubview:_theCustomSearchView];
    
    
}


#pragma mark - 点击方法


-(void)myNavcRightBtnClicked{
    
    [self changeSearchViewAndKuangFrameAndTfWithState:0];
    
    [_rightItem2Label removeFromSuperview];
    [_searchTf resignFirstResponder];
    
    [self gogoback];

}


-(void)hotSearchBtnClicked:(UIButton *)sender{
    NSLog(@"%d",(int)sender.tag);
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
        ProductListViewController *cc = [[ProductListViewController alloc]init];
        [self.navigationController pushViewController:cc animated:YES];
        
        
    }else if (sender.tag == 102){//品牌店
        
        
    }else if (sender.tag == 103){//购物车
        
        if ([LoginViewController isLogin]) {//已登录
            GShopCarViewController *cc = [[GShopCarViewController alloc]init];
            [self.navigationController pushViewController:cc animated:YES];
        }else{
            [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                if (success) {
                    GShopCarViewController *cc = [[GShopCarViewController alloc]init];
                    [self.navigationController pushViewController:cc animated:YES];
                }
            }];
            
            
        }
        
    }else if (sender.tag == 104){//加入购物车
        
    }
}


- (void)clickToChat
{
    //update by lcw
    [MiddleTools pushToChatWithSourceType:SourceType_Normal fromViewController:self model:nil];
}



#pragma - mark RefreshDelegate

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        
        if (_searchTf.isFirstResponder) {
            alphaView.alpha = 1;
        }else{
            if (scrollView.contentOffset.y > 64) {
                CGFloat alpha = (scrollView.contentOffset.y -64)/200.0f;
                alpha = MIN(alpha, 1);
                alphaView.alpha = alpha;
            }else{
                alphaView.alpha = 0;
            }
        }
        
        
    }
    
    [self controlTopButtonWithScrollView:scrollView];
}

-(void)setEffectViewAlpha:(CGFloat)theAlpha{
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        alphaView.alpha = theAlpha;
    }
}









@end
