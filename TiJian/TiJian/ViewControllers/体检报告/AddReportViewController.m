//
//  AddReportViewController.m
//  TiJian
//
//  Created by lichaowei on 15/12/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AddReportViewController.h"
#import "JKImagePickerController.h"
#import "PeopleManageController.h"
#import "PhotoCell.h"
#import "LDatePicker.h"
#import <Photos/Photos.h> //iOS8之后才有

@interface AddReportViewController ()<JKImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIScrollView *_scrollView;
    BOOL _isMyself;//是否是自己
    NSString *_familyUid;
    NSString *_checkUpTime;//体检时间
}

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray   *assetsArray;
@property(nonatomic,strong)NSMutableArray *uploadImageArray;
@property(nonatomic,strong)LDatePicker *datePicker;

@end

@implementation AddReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"添加报告";
    self.rightString = @"提交";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _scrollView.contentSize = CGSizeMake(DEVICE_WIDTH, _scrollView.height);
    _scrollView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < 2; i ++) {
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5 + (50 + 5) * i, DEVICE_WIDTH, 50)];
        view.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:view];
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, 50)];
        arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
        arrow.contentMode = UIViewContentModeCenter;
        [view addSubview:arrow];
        
        NSString *title = i == 0 ? @"选择体检人" : @"选择体检时间";
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 150, 50) title:title font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB];
        [view addSubview:label];
        
        CGFloat width = arrow.left - label.right - 20;
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 20, 0, width, 50) title:nil font:14 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE];
        [view addSubview:contentLabel];
//        contentLabel.backgroundColor = [UIColor redColor];
        contentLabel.tag = 100 + i;
        
        if (i == 0) {
            [view addTaget:self action:@selector(clickToSelectPeople) tag:0];
        }else
        {
            [view addTaget:self action:@selector(clickToSelectTime) tag:0];
        }
    }
    
    [self.collectionView reloadData];
    
//    //底部按钮
//    for (int i = 0; i < 2; i ++) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(DEVICE_WIDTH / 2.f * i, DEVICE_HEIGHT - 50 - 64, DEVICE_WIDTH/2.f, 50);
//        [self.view addSubview:btn];
//        btn.backgroundColor = i == 0 ? DEFAULT_TEXTCOLOR_ORANGE : DEFAULT_TEXTCOLOR;
//        [btn setImage:(i == 0 ? [UIImage imageNamed:@"report_zhaopian"] : [UIImage imageNamed:@"report_paizhao"]) forState:UIControlStateNormal];
//        [btn setTitle:(i == 0 ? @"  相册" : @"  拍照") forState:UIControlStateNormal];
//        if (i == 0) {
//            
//            [btn addTarget:self action:@selector(clickToAlbum) forControlEvents:UIControlEventTouchUpInside];
//        }else
//        {
//            [btn addTarget:self action:@selector(clickToTakePhoto) forControlEvents:UIControlEventTouchUpInside];
//
//        }
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

- (UILabel *)labelWithTag:(NSInteger)tag
{
    return [_scrollView viewWithTag:tag];
}

#pragma mark - 网络请求

#pragma mark - 获取所选图片

-(void)getSelectedPics{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.uploadImageArray = [NSMutableArray arrayWithCapacity:1];
    
    NSLog(@"-------%lu",(unsigned long)self.assetsArray.count);
    
    for (int i = 0;i < self.assetsArray.count; i++) {
        
        JKAssets* jkAsset = self.assetsArray[i];
        
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:jkAsset.assetPropertyURL resultBlock:^(ALAsset *asset) {
            
            if (asset) {
                UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                [self.uploadImageArray addObject:image];
                
                if (self.uploadImageArray.count == self.assetsArray.count) {
                    [self uploadImages:self.uploadImageArray];
                }
            }
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    
    if (self.assetsArray.count == 0) {//没图
        if (self.assetsArray.count == 0) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [GMAPI showAutoHiddenMBProgressWithText:@"请选择体检报告" addToView:self.view];
        }
    }
}


#pragma mark - 上传图片
//上传
-(void)uploadImages:(NSArray *)aImage_arr{

    NSDictionary *dic_upload;

    NSString *family_uid = _familyUid;
    NSString *checkup_time = _checkUpTime;//体检时间
    
    if (_isMyself) {
        
        dic_upload = @{
                       @"authcode":[UserInfo getAuthkey],//用户标示
                       @"myself":@"1",
                       @"checkup_time":checkup_time
                       };
    }else
    {
        dic_upload = @{
                       @"authcode":[UserInfo getAuthkey],//用户标示
                       @"family_uid":family_uid,//评论星级
                       @"checkup_time":checkup_time
                       };
    }
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:REPORT_ADD parameters:dic_upload constructingBodyBlock:^(id<AFMultipartFormData> formData) {
        
        for (int i = 0; i < aImage_arr.count; i ++) {
            
            UIImage *aImage = aImage_arr[i];
            
            if (aImage) {
                
                NSData *data = [aImage dataWithCompressMaxSize:200 * 1000 compression:0.5];
                                
                NSLog(@"---> 大小 %ld",(unsigned long)data.length);
                
                NSString *imageName = [NSString stringWithFormat:@"icon%d.jpg",i];
                
                NSString *picName = [NSString stringWithFormat:@"images%d",i];
                
                [formData appendPartWithFileData:data name:picName fileName:imageName mimeType:@"image/jpg"];
            }
            
        }
        
    } completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSLog(@"success %@",result);
        
        if ([result[RESULT_CODE] intValue] == 0) {
            
            [LTools showMBProgressWithText:@"添加报告成功" addToView:self.view];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_REPORT_ADD_SUCCESS object:nil];
            [self performSelector:@selector(leftButtonTap:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
        }
        
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSLog(@"失败 : %@",result);
        
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

- (void)clickToSelectPeople
{
    PeopleManageController *people = [[PeopleManageController alloc]init];
    people.actionType = PEOPLEACTIONTYPE_SELECT;
    people.noAppointNum = 1;
    [self.navigationController pushViewController:people animated:YES];
    
    __weak typeof(self)weakSelf = self;
    people.updateParamsBlock = ^(NSDictionary *params){
        
        UserInfo *user = params[@"result"];
        BOOL myself = [params[@"myself"]boolValue];
        _isMyself = myself;
        if (_isMyself) {
            
            [weakSelf labelWithTag:100].text = [NSString stringWithFormat:@"%@",user.real_name];

        }else
        {
            [weakSelf labelWithTag:100].text = [NSString stringWithFormat:@"%@  %@",user.appellation,user.family_user_name];
            _familyUid = user.family_uid;
        }
    };

}

- (void)clickToSelectTime
{
    __weak typeof(self)weakSelf = self;
    [self.datePicker showDateBlock:^(ACTIONTYPE type, NSString *dateString) {
        
        if (type == ACTIONTYPE_SURE) {
            
            [weakSelf labelWithTag:101].text = dateString;
            _checkUpTime = dateString;
        }
        
        NSLog(@"dateBlock %@",dateString);
        
    }];
}

/**
 *  时间选择器
 *
 *  @return
 */
-(LDatePicker *)datePicker
{
    if (_datePicker) {
        return _datePicker;
    }
    _datePicker = [[LDatePicker alloc] init];
    
    return _datePicker;
}

//相册
- (void)clickToAlbum
{
    JKImagePickerController *imagePickerController = [[JKImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 0;
    imagePickerController.maximumNumberOfSelection = 9;
    imagePickerController.selectedAssetArray = self.assetsArray;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

-(void)rightButtonTap:(UIButton *)sender
{
    NSLog(@"提交");
    
    NSString *family_uid = _familyUid;
    NSString *checkup_time = _checkUpTime;//体检时间
    
    if (!family_uid && !_isMyself) {
        
        [LTools showMBProgressWithText:@"请选择体检人" addToView:self.view];
        return;
    }
    if (!checkup_time) {
        [LTools showMBProgressWithText:@"请选择体检时间" addToView:self.view];
        return;
    }
    
    [self getSelectedPics];
}

#pragma mark - 代理

#pragma mark - JKImagePickerControllerDelegate
- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAsset:(JKAssets *)asset isSource:(BOOL)source
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets isSource:(BOOL)source
{
    self.assetsArray = [NSMutableArray arrayWithArray:assets];
    [self.collectionView reloadData];

    [imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

static NSString *kPhotoCellIdentifier = @"kPhotoCellIdentifier";

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.assetsArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = DEFAULT_HEADIMAGE;
    if (indexPath.row == self.assetsArray.count) {
        
        cell.imageView.image = [UIImage imageNamed:@"compose_pic_add"];
        
    }else
    {
        cell.asset = [self.assetsArray objectAtIndex:[indexPath row]];
    }
    
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
    
    [self clickToAlbum];
    
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5.0;
        layout.minimumInteritemSpacing = 5.0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
//        @property (nonatomic) CGSize headerReferenceSize;
//        @property (nonatomic) CGSize footerReferenceSize;
        layout.headerReferenceSize = CGSizeMake(DEVICE_WIDTH, 10);
        layout.footerReferenceSize = CGSizeMake(DEVICE_WIDTH , 10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 120, DEVICE_WIDTH - 20, DEVICE_HEIGHT - 64 - 120) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor orangeColor];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_scrollView addSubview:_collectionView];
        
    }
    return _collectionView;
}

@end
