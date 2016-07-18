//
//  AddCommentDetailViewController.m
//  WJXC
//
//  Created by gaomeng on 15/8/4.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "AddCommentDetailViewController.h"
#import "JKImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoCell.h"
#import "AFNetworking.h"
#import "TQStarRatingView.h"
#import "AddCommentViewController.h"

@interface AddCommentDetailViewController ()<JKImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITextViewDelegate,StarRatingViewDelegate>
{
    UIScrollView *_mainScrollView;
    
    UITextView *_tv;
    
    UILabel *_holderLabel;
    
    UIButton *_jiaBtn;
    
    BOOL _isniming;//是否匿名
    int _theScore;//评分
    
    
}


@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray   *assetsArray;

@property(nonatomic,strong)NSMutableArray *uploadImageArray;



@end

@implementation AddCommentDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"评价晒单";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64)];
    [self.view addSubview:_mainScrollView];
    
    UIControl *cccc = [[UIControl alloc]initWithFrame:self.view.bounds];
    [cccc addTarget:self action:@selector(gshou) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:cccc];
    
    [self creatCustomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MyMethod

-(void)gshou{
    [_tv resignFirstResponder];
}

-(void)creatCustomView{
    
    UIView *upview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 80)];
    [upview addTaget:self action:@selector(gshou) tag:0];
    [_mainScrollView addSubview:upview];
    
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 80, 50)];
    [imv sd_setImageWithURL:[NSURL URLWithString:self.theModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
    [upview addSubview:imv];
    
    UILabel *tt = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+10, imv.frame.origin.y, DEVICE_WIDTH - 80 - 90, imv.frame.size.height) title:self.theModel.product_name font:15 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
    [upview addSubview:tt];
    
    [tt setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(imv.frame)+10, imv.frame.origin.y) width:DEVICE_WIDTH - 80 - 90];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 80, DEVICE_WIDTH, 5)];
    line.backgroundColor = RGBCOLOR(241, 242, 244);
    [upview addSubview:line];
    
    UILabel *pp = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(line.frame)+10, 50, 20) title:@"评价：" font:15 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
    [_mainScrollView addSubview:pp];
    
    
    TQStarRatingView *starRatingView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(pp.frame), pp.frame.origin.y,20*5,20) numberOfStar:5];
    starRatingView.delegate = self;
    [self.view addSubview:starRatingView];
    _theScore = 5;//默认是五星
    
    
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(pp.frame)+10, DEVICE_WIDTH-10, 0.5)];
    line1.backgroundColor = RGBCOLOR(220, 221, 223);
    [_mainScrollView addSubview:line1];
    
    
    
    _tv = [[UITextView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(line1.frame)+10, DEVICE_WIDTH - 20, 100)];
    _tv.delegate = self;
    _tv.font = [UIFont systemFontOfSize:15];
    [_mainScrollView addSubview:_tv];
    
    _holderLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _tv.frame.size.width, 40) title:@"字数控制在10-500字之间。写下购买体会，可以帮助其他小伙伴提供参考" font:13 align:NSTextAlignmentLeft textColor:RGBCOLOR(80,81,82)];
    _holderLabel.numberOfLines = 2;
    _holderLabel.userInteractionEnabled = YES;
    [_holderLabel addTaget:self action:@selector(ggggg) tag:0];
    [_tv addSubview:_holderLabel];
    
    _jiaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_jiaBtn setFrame:CGRectMake(10,CGRectGetMaxY(_tv.frame)+10, 65, 65)];
    [_jiaBtn setImage:[UIImage imageNamed:@"compose_pic_add.png"] forState:UIControlStateNormal];
    [_jiaBtn setBackgroundImage:[UIImage imageNamed:@"compose_pic_add_highlighted.png"] forState:UIControlStateHighlighted];
    [_jiaBtn addTarget:self action:@selector(composePicAdd) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:_jiaBtn];
    
    UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_jiaBtn.frame)+5, _jiaBtn.frame.size.width, 20) title:@"添加晒照图片" font:10 align:NSTextAlignmentCenter textColor:RGBCOLOR(80, 81, 82)];
    [_mainScrollView addSubview:tishiLabel];
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tishiLabel.frame)+10, DEVICE_WIDTH, 0.5)];
    line2.backgroundColor = RGBCOLOR(220, 221, 223);
    [_mainScrollView addSubview:line2];
    _mainScrollView.contentSize = CGSizeMake(DEVICE_WIDTH, CGRectGetMaxX(line2.frame));
    
    
    UIView *vvvv = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line2.frame), DEVICE_WIDTH, DEVICE_HEIGHT - 64- 45 - CGRectGetMaxY(line2.frame))];
    vvvv.backgroundColor = RGBCOLOR(241, 242, 244);
    [_mainScrollView addSubview:vvvv];
    
    
    UIView *nimingView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 45, DEVICE_WIDTH, 45)];
    nimingView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nimingView];
    
    UIButton *nimingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nimingBtn setFrame:CGRectMake(0, 0, 70, 45)];
    nimingBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [nimingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nimingBtn setTitle:@"匿名" forState:UIControlStateNormal];
    [nimingBtn setImage:[UIImage imageNamed:@"xuanzhong_no"] forState:UIControlStateNormal];
    [nimingBtn setImage:[UIImage imageNamed:@"xuanzhong"] forState:UIControlStateSelected];
    [nimingBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -20)];
    [nimingBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [nimingBtn addTarget:self action:@selector(nimingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [nimingView addSubview:nimingBtn];
    
    UIButton *tijiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tijiaoBtn setTitle:@"提交" forState:UIControlStateNormal];
    tijiaoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [tijiaoBtn setFrame:CGRectMake(DEVICE_WIDTH - 80, 8, 70, 30)];
    tijiaoBtn.backgroundColor = RGBCOLOR(240, 114, 0);
    tijiaoBtn.layer.cornerRadius = 4;
    tijiaoBtn.layer.masksToBounds = YES;
    [tijiaoBtn addTarget:self action:@selector(clickToCommit) forControlEvents:UIControlEventTouchUpInside];
    [nimingView addSubview:tijiaoBtn];
    
}

-(void)nimingClicked:(UIButton *)sender{
    sender.selected = !sender.selected;
    _isniming = sender.selected;
    NSLog(@"%d",_isniming);
    
}


-(void)ggggg{
    [_tv becomeFirstResponder];
}

-(void)clickToCommit{
    [self getChoosePics];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _holderLabel.hidden = YES;
    
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    NSLog(@"%@",textView.text);
    if (textView.text.length == 0) {
        _holderLabel.hidden = NO;
        [_tv resignFirstResponder];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        _holderLabel.hidden = NO;
    }
}




- (void)composePicAdd
{
    JKImagePickerController *imagePickerController = [[JKImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 0;
    imagePickerController.maximumNumberOfSelection = 3;
    imagePickerController.selectedAssetArray = self.assetsArray;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}



#pragma mark - JKImagePickerControllerDelegate
- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAsset:(JKAssets *)asset isSource:(BOOL)source
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets isSource:(BOOL)source
{
    self.assetsArray = [NSMutableArray arrayWithArray:assets];
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        [self.collectionView reloadData];
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
    return [self.assetsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
    cell.asset = [self.assetsArray objectAtIndex:[indexPath row]];
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(65, 65);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"，，，，，%ld",(long)[indexPath row]);
    
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5.0;
        layout.minimumInteritemSpacing = 5.0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_jiaBtn.frame)+10, _jiaBtn.frame.origin.y, DEVICE_WIDTH - 10 - _jiaBtn.frame.size.width -10 -10, 65) collectionViewLayout:layout];
//        _collectionView.backgroundColor = [UIColor orangeColor];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_mainScrollView addSubview:_collectionView];
        
    }
    return _collectionView;
}



#pragma mark - 获取所选图片
-(void)getChoosePics{
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    self.uploadImageArray = [NSMutableArray arrayWithCapacity:1];
    
    for (int i = 0;i<self.assetsArray.count;i++) {
        
        JKAssets* jkAsset = self.assetsArray[i];
        
        ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:jkAsset.assetPropertyURL resultBlock:^(ALAsset *asset) {
            
            if (asset) {
                
                UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                [self.uploadImageArray addObject:image];
                
                if (self.uploadImageArray.count == self.assetsArray.count) {
                    [self upLoadImage:self.uploadImageArray];
                }
            }
            
        } failureBlock:^(NSError *error) {
            
            
        }];
    }
    
    
    if (self.assetsArray.count == 0) {//没图
        
        if (self.assetsArray.count == 0 && _tv.text.length == 0) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [LTools showMBProgressWithText:@"请填写评论或添加图片" addToView:self.view];
        }else{
            
            [self upLoadImage:nil];
        }
    }
}

#pragma mark - 上传图片
//上传
-(void)upLoadImage:(NSArray *)aImage_arr{
    
    
    NSString *is_anony;
    if (_isniming) {
        is_anony = @"1";
    }else{
        is_anony = @"0";
    }
    
    NSDictionary *dic_upload;
    if (_tv.text.length == 0) {
        
        dic_upload = @{
                       @"product_id":self.theModel.product_id,//商品id
                       @"authcode":[UserInfo getAuthkey],//用户标示
                       @"order_no":self.dingdanhao,//订单号
                       @"star":[NSString stringWithFormat:@"%d",_theScore],//评论星级
                       @"is_anony":is_anony
                       };
    }else{
        
        
        if (_tv.text.length < 10) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [LTools showMBProgressWithText:@"评论内容长度不能少于10个字" addToView:self.view];

            return;
        }
        
        dic_upload = @{
                       @"product_id":self.theModel.product_id,//商品id
                       @"authcode":[UserInfo getAuthkey],//用户标示
                       @"order_no":self.dingdanhao,//订单号
                       @"star":[NSString stringWithFormat:@"%d",_theScore],//评论星级
                       @"content":_tv.text,
                       @"is_anony":is_anony
                       };
    }
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:ADD_PRODUCT_PINGLUN parameters:dic_upload constructingBodyBlock:^(id<AFMultipartFormData> formData) {
        
        for (int i = 0; i < aImage_arr.count; i ++) {
            
            UIImage *aImage = aImage_arr[i];
            
            NSData * data= UIImageJPEGRepresentation(aImage, 0.5);
            
            DDLOG(@"---> 大小 %ld",(unsigned long)data.length);
            
            NSString *imageName = [NSString stringWithFormat:@"icon%d.jpg",i];
            
            NSString *picName = [NSString stringWithFormat:@"images%d",i];
            
            [formData appendPartWithFileData:data name:picName fileName:imageName mimeType:@"image/jpg"];
            
        }
        
    } completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSLog(@"success %@",result);
        
        if ([result[RESULT_CODE] intValue] == 0) {
            
            [GMAPI showAutoHiddenMBProgressWithText:@"评价成功" addToView:self.view];
            
            [self performSelector:@selector(pingjiaSuccessToGoBack) withObject:[NSNumber numberWithBool:YES] afterDelay:1.f];
        }

        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
        NSLog(@"失败 : %@",result);
        
    }];
}

-(void)pingjiaSuccessToGoBack{
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_COMMENTSUCCESS object:nil];
    
    self.theModel.is_comment = @"1";//标记为已评价
    
    [self.delegate updateView_pingjiaSuccessWithIndex:self.theIndex_row];
    
    //上传成功 返回到上一个vc
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - StarRatingViewDelegate
-(void)starRatingView:(TQStarRatingView *)view score:(float)score
{
    _theScore = (int)score;
    
    NSLog(@"score:%d",_theScore);
}


@end
