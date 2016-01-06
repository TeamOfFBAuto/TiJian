//
//  RootViewController.m
//  TestClouth
//
//  Created by lichaowei on 14/12/9.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "PersonalCenterController.h"
#import "MedicalReportController.h"//体检报告
#import "NewMedicalReportController.h"//新版体检报告

@interface RootViewController ()<UITabBarControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{

}

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.delegate = self;
    
    [self prepareItems];
    
    [LTools updateTabbarUnreadMessageNumber];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareItems
{
    
    NSArray *classNames = @[@"HomeViewController",@"NewMedicalReportController",@"PersonalCenterController"];
    NSArray *item_names = @[@"首页",@"体检报告",@"个人中心"];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:classNames.count];
    for (int i = 0; i < classNames.count;i ++) {
            
        NSString *className = classNames[i];
        UIViewController *vc = [[NSClassFromString(className) alloc]init];
        LNavigationController *unvc = [[LNavigationController alloc]initWithRootViewController:vc];
        [items addObject:unvc];
    }
    
    self.viewControllers = [NSArray arrayWithArray:items];
    
    NSArray *selectedImages = @[@"homepage_b",
                              @"report_b",
                              @"personal_b"];
    NSArray *normalImages = @[@"homepage_g",
                                @"report_g",
                                @"personal_g"];
    
    for (int i = 0; i < normalImages.count; i ++) {
        
        UITabBarItem *item = self.tabBar.items[i];
        UIImage *aImage = [UIImage imageNamed:[normalImages objectAtIndex:i]];
        aImage = [aImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.image = aImage;
        
        UIImage *selectImage = [UIImage imageNamed:[selectedImages objectAtIndex:i]];
        selectImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = selectImage;
        
        item.title = [item_names objectAtIndex:i];

    }
    
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"323232"],                                                                                                              NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_TEXTCOLOR,                                                                                                              NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
}


- (void)pushToViewController:(UIViewController *)viewController
{
    viewController.hidesBottomBarWhenPushed = YES;
    [(UINavigationController *)self.selectedViewController pushViewController:viewController animated:YES];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"--> %d  %@",(int)tabBarController.selectedIndex,viewController);
    
}

@end
