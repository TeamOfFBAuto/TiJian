//
//  MoreReportViewController.m
//  TiJian
//
//  Created by lichaowei on 15/12/5.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MoreReportViewController.h"
#import "FBPhotoBrowserController.h"
#import "PhotoCell.h"
#import "PhotoBrowserView.h"

@interface MoreReportViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, retain) UICollectionView *collectionView;

@end

@implementation MoreReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"更多报告";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    if (self.imageUrlArray.count > 0) {
        [self.collectionView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSString *kPhotoCellIdentifier = @"kPhotoCellIdentifier";

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageUrlArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
    [cell setImageUrl:self.imageUrlArray[indexPath.row]];
    [cell setBorderWidth:0.5 borderColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];

    return cell;
    
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (DEVICE_WIDTH - 30) / 3.f ;
    return CGSizeMake(width, width * 1.3);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",(long)[indexPath row]);
    FBPhotoBrowserController *browser = [[FBPhotoBrowserController alloc]init];
    browser.showIndex = (int)indexPath.row;
    browser.imagesArray = self.imageUrlArray;
    [self.navigationController pushViewController:browser animated:YES];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5.0;
        layout.minimumInteritemSpacing = 5.0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        layout.headerReferenceSize = CGSizeMake(DEVICE_WIDTH, 10);
        layout.footerReferenceSize = CGSizeMake(DEVICE_WIDTH , 10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, DEVICE_HEIGHT - 64) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor orangeColor];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:_collectionView];
        
    }
    return _collectionView;
}

@end
