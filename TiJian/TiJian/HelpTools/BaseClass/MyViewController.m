//
//  MyViewController.m
//  FBCircle
//
//  Created by soulnear on 14-5-12.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "MyViewController.h"

@interface MyViewController ()
{
    UISwipeGestureRecognizer * swipe;
    UIButton *_backButton;//返回按钮
    
    MyViewControllerLeftbuttonType leftType;
    MyViewControllerRightbuttonType myRightType;
}
//右上角按钮
@property(nonatomic,strong)UILabel * navTitleLabel;//导航栏label
@property(nonatomic,strong)UIButton *topButton;//置顶按钮
@property(nonatomic,retain)UIScrollView *scrollView;
@property(nonatomic,retain)UIButton *leftButton;
@property(nonatomic,retain)UIButton *leftButton2;
@property(nonatomic,retain)UIBarButtonItem *rightButtonItem;//右
@property(nonatomic,retain)UIBarButtonItem *rightButtonItem2;//右2
@property(nonatomic,retain)UIBarButtonItem *leftButtonItem;//左
@property(nonatomic,retain)UIBarButtonItem *leftButtonItem2;//左2

@end

@implementation MyViewController

@synthesize rightString = _rightString;
@synthesize leftImageName = _leftImageName;
@synthesize rightImageName = _rightImageName;
@synthesize leftString = _leftString;
@synthesize right_button = _right_button;

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
       self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:self.lastPageNavigationHidden animated:animated];
    
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,44)];
    _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    _navTitleLabel.text = _myTitle;
    _navTitleLabel.textColor = DEFAULT_TEXTCOLOR;
    _navTitleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = _navTitleLabel;
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
}


#pragma mark - 视图个性化method

-(UIButton *)topButton
{
    if (!_topButton) {
        self.topButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.topButton.frame =CGRectMake(DEVICE_WIDTH - 20 - 40, DEVICE_HEIGHT - 50 - 40 - 64, 40, 40);
        [self.topButton setImage:[UIImage imageNamed:@"home_button_top"] forState:UIControlStateNormal];
        [self.view addSubview:self.topButton];
        [self.topButton addTarget:self action:@selector(clickToTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.view bringSubviewToFront:_topButton];
    }
    return _topButton;
}

/**
 *  控制置顶按钮,需要时在scrollDelegate里面调用
 *
 *  @param scrollView
 */
- (void)controlTopButtonWithScrollView:(UIScrollView *)scrollView
{
    self.scrollView = scrollView;
    if (!_topButton) {
        self.topButton.bottom = scrollView.bottom - 40 - 20;
    }
    
    UIScrollView *scroll = scrollView;
    
    if ([scroll isKindOfClass:[UIScrollView class]] && scroll.contentOffset.y > DEVICE_HEIGHT) {
        
        self.topButton.hidden = NO;
    }else
    {
        self.topButton.hidden = YES;
    }
}
/**
 *  置顶
 *
 *  @param button
 */
- (void)clickToTop:(UIButton *)button
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)setNavigationStyle:(NAVIGATIONSTYLE)style
                     title:(NSString *)title
{
    if (style == NAVIGATIONSTYLE_BLUE) {
        
        if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
        {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:IOS7_OR_LATER?IOS7DAOHANGLANBEIJING_PUSH:IOS6DAOHANGLANBEIJING] forBarMetrics: UIBarMetricsDefault];
            [self.leftButton setImage:[UIImage imageNamed:@"back_w"] forState:UIControlStateNormal];//白色返回按钮
            _navTitleLabel.textColor = [UIColor whiteColor];//白色字体
        }
    }else if (style == NAVIGATIONSTYLE_WHITE){
        
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics: UIBarMetricsDefault];
        [self.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];//白色返回按钮
        _navTitleLabel.textColor = DEFAULT_TEXTCOLOR;
        
    }else if (style == NAVIGATIONSTYLE_CUSTOM){
                
        [self.navigationController setNavigationBarHidden:YES];
        
        UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, IOS7_OR_LATER ? 0 : 20, DEVICE_WIDTH, IOS7_OR_LATER ? 64 : 44)];
        [self.view addSubview:navigationView];
        navigationView.backgroundColor = DEFAULT_TEXTCOLOR;
        
        //标题
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 44)];
        label.font = [UIFont systemFontOfSize:17];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [navigationView addSubview:label];
        _navTitleLabel = label;
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"back_w"] forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0, navigationView.height - 44, 44, 44);
        [navigationView addSubview:backButton];
        [backButton addTarget:self action:@selector(leftButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    _navTitleLabel.text = title;
}

-(void)setUpdateParamsBlock:(UpdateParamsBlock)updateParamsBlock
{
    _updateParamsBlock = updateParamsBlock;
}

-(void)setResultView:(ResultView *)resultView
{
    _resultView = resultView;
}

-(void)setMyViewControllerLeftButtonType:(MyViewControllerLeftbuttonType)theType WithRightButtonType:(MyViewControllerRightbuttonType)rightType
{
    
    leftType = theType;
    myRightType = rightType;
    
    if (theType == MyViewControllerLeftbuttonTypeBack)
    {
        //调整与左边的间距
        UIBarButtonItem * spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButton1.width = -7;
        self.navigationItem.leftBarButtonItems = @[spaceButton1, self.leftButtonItem];
        
    }else if(theType == MyViewControllerLeftbuttonTypeOther)
    {
        [self.leftButton setImage:[UIImage imageNamed:self.leftImageName] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItems = @[self.leftButtonItem];
        
    }else if (theType == MyViewControllerLeftbuttonTypeText)
    {
        [self.leftButton setTitle:self.leftString forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItems = @[self.leftButtonItem];
        
    }else if (theType == MyViewControllerLeftbuttonTypeNull)
    {
        self.navigationItem.leftBarButtonItems = nil;
    }else if (theType == MyViewControllerLeftbuttonTypeDouble)
    {
        if (self.leftString) {
            [self.leftButton setTitle:self.leftString forState:UIControlStateNormal];
        }
       
        if (self.leftImageName) {
            [self.leftButton setImage:[UIImage imageNamed:self.leftImageName] forState:UIControlStateNormal];
        }
        
        if (self.leftString2) {
            [self.leftButton2 setTitle:self.leftString2 forState:UIControlStateNormal];
        }
        
        if (self.leftImageName2) {
            [self.leftButton2 setImage:[UIImage imageNamed:self.leftImageName2] forState:UIControlStateNormal];
        }
        
        self.navigationItem.leftBarButtonItems = @[self.leftButtonItem,self.leftButtonItem2];
    }
    
    
    if(rightType == MyViewControllerRightbuttonTypeText)
    {
        [self.right_button setTitle:self.rightString forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItems = @[self.rightButtonItem];
        
    }else if(rightType == MyViewControllerRightbuttonTypeOther)
    {
        UIImage * rightImage;
        if (self.rightImageName) {
            
            rightImage = [UIImage imageNamed:_rightImageName];
        }
        
        if (self.rightImage) {
            rightImage = self.rightImage;
        }
        
        [self.right_button setImage:rightImage forState:UIControlStateNormal];
        self.right_button.frame = CGRectMake(0, 0, rightImage.size.width, rightImage.size.height);
        self.navigationItem.rightBarButtonItems = @[self.rightButtonItem];
        
    }
    else if (rightType == MyViewControllerRightbuttonTypeDouble)
    {
        UIImage * rightImage;
        if (self.rightImageName) {
            
            rightImage = [UIImage imageNamed:_rightImageName];
        }
        
        if (self.rightImage) {
            rightImage = self.rightImage;
        }
        
        if (self.rightImage2) {
            [self.right_button2 setImage:self.rightImage2 forState:UIControlStateNormal];
        }
        
        [self.right_button setImage:rightImage forState:UIControlStateNormal];
        self.right_button.frame = CGRectMake(0, 0, rightImage.size.width, rightImage.size.height);
        
        self.navigationItem.rightBarButtonItems = @[self.rightButtonItem,self.rightButtonItem2];
        
    }else if (theType == MyViewControllerLeftbuttonTypeNull)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)setMyTitle:(NSString *)myTitle
{
    _myTitle = myTitle;
    _navTitleLabel.text = _myTitle;
}

-(void)setLeftString:(NSString *)leftString
{
    _leftString = leftString;
    [self setMyViewControllerLeftButtonType:leftType WithRightButtonType:myRightType];
}
-(void)setRightString:(NSString *)rightString
{
    _rightString = rightString;
    [self setMyViewControllerLeftButtonType:leftType WithRightButtonType:myRightType];
}
-(void)setRightImageName:(NSString *)rightImageName
{
    _rightImageName = rightImageName;
    [self setMyViewControllerLeftButtonType:leftType WithRightButtonType:myRightType];
}

-(void)setRightImage:(UIImage *)rightImage
{
    _rightImage = rightImage;
    [self setMyViewControllerLeftButtonType:leftType WithRightButtonType:myRightType];
}

-(void)setLeftImageName:(NSString *)leftImageName
{
    _leftImageName = leftImageName;
    [self setMyViewControllerLeftButtonType:leftType WithRightButtonType:myRightType];
}

#pragma mark - 视图创建

-(UIBarButtonItem *)rightButtonItem
{
    if (!_rightButtonItem) {
        
        _rightButtonItem =[[UIBarButtonItem alloc]initWithCustomView:self.right_button];
    }
    return _rightButtonItem;
}

-(UIBarButtonItem *)rightButtonItem2
{
    if (!_rightButtonItem2) {
        
        _rightButtonItem2 =[[UIBarButtonItem alloc]initWithCustomView:self.right_button2];
    }
    return _rightButtonItem2;
}

-(UIBarButtonItem *)leftButtonItem
{
    if (!_leftButtonItem) {
        _leftButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftButton];
    }
    return _leftButtonItem;
}

-(UIBarButtonItem *)leftButtonItem2
{
    if (!_leftButtonItem2) {
        _leftButtonItem2 = [[UIBarButtonItem alloc]initWithCustomView:self.leftButton2];
    }
    return _leftButtonItem2;
}

-(UIButton *)right_button
{
    if (!_right_button) {
        _right_button = [UIButton buttonWithType:UIButtonTypeCustom];
        _right_button.frame = CGRectMake(0,0,60,44);
        _right_button.titleLabel.textAlignment = NSTextAlignmentRight;
        [_right_button setTitle:_rightString forState:UIControlStateNormal];
        [_right_button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        _right_button.titleLabel.font = [UIFont systemFontOfSize:15];
        [_right_button setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        [_right_button addTarget:self action:@selector(rightButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//        _right_button.backgroundColor = [UIColor redColor];
    }
    return _right_button;
}

-(UIButton *)right_button2
{
    if (!_right_button2) {
        _right_button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _right_button2.frame = CGRectMake(0,0,60,44);
        _right_button2.titleLabel.textAlignment = NSTextAlignmentRight;
        [_right_button2 setTitle:@"" forState:UIControlStateNormal];
        [_right_button2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        _right_button2.titleLabel.font = [UIFont systemFontOfSize:15];
        [_right_button2 setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        [_right_button2 addTarget:self action:@selector(rightButtonTap2:) forControlEvents:UIControlEventTouchUpInside];
//        _right_button2.backgroundColor = [UIColor orangeColor];

    }
    return _right_button2;
}

-(UIButton *)leftButton
{
    if (!_leftButton) {
        
        UIButton *button_back=[[UIButton alloc]initWithFrame:CGRectMake(0,8,40,44)];
        [button_back addTarget:self action:@selector(leftButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//        button_back.backgroundColor = [UIColor orangeColor];
        [button_back setImage:BACK_DEFAULT_IMAGE forState:UIControlStateNormal];
        [button_back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _leftButton = button_back;
    }
    return _leftButton;
}

-(UIButton *)leftButton2
{
    if (!_leftButton2) {
        
        UIButton *button_back=[[UIButton alloc]initWithFrame:CGRectMake(0,8,40,44)];
        [button_back addTarget:self action:@selector(leftButtonTap2:) forControlEvents:UIControlEventTouchUpInside];
//        [button_back setImage:BACK_DEFAULT_IMAGE forState:UIControlStateNormal];
        [button_back setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button_back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [button_back.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _leftButton2 = button_back;
    }
    return _leftButton2;
}

#pragma mark - 事件处理method

-(void)rightButtonTap:(UIButton *)sender
{
    
}

-(void)rightButtonTap2:(UIButton *)sender
{
    
}

-(void)leftButtonTap:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftButtonTap2:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
