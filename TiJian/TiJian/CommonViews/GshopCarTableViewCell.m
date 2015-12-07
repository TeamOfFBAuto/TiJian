//
//  GshopCarTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/9.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GshopCarTableViewCell.h"
#import "ProductModel.h"
#import "GShopCarViewController.h"

@interface GshopCarTableViewCell ()

@property(nonatomic,retain)UIImageView *iconImageView;
@property(nonatomic,retain)UILabel *contentLabel;
@property(nonatomic,retain)UILabel *priceLabel;

@end

@implementation GshopCarTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)dealloc
{
    [_request removeOperation:_request_addShopCar];
    [_request removeOperation:_requset_subShopCar];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat height = [GshopCarTableViewCell heightForCell];
        
        self.chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.chooseBtn setImage:[UIImage imageNamed:@"xuanzhong_no.png"] forState:UIControlStateNormal];
        [self.chooseBtn setImage:[UIImage imageNamed:@"xuanzhong.png"] forState:UIControlStateSelected];
        
        CGFloat wAndH = 35;
        [self.chooseBtn setFrame:CGRectMake(5, height * 0.5 - wAndH * 0.5, wAndH, wAndH)];
        [self.chooseBtn addTarget:self action:@selector(chooseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.chooseBtn];
        
        UIImageView *logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.chooseBtn.frame)+5, 10, [GMAPI scaleWithHeight:height-20 width:0 theWHscale:252.0/158], height - 20)];
        [self.contentView addSubview:logoImv];
        self.iconImageView = logoImv;
        
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(logoImv.frame) + 15, logoImv.frame.origin.y, DEVICE_WIDTH - 15 - self.chooseBtn.frame.size.width - 5 - logoImv.frame.size.width - 5 - 5, logoImv.frame.size.height/3)];
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.numberOfLines = 2;
        [self.contentView addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentLabel.frame.origin.x, CGRectGetMaxY(contentLabel.frame), contentLabel.frame.size.width, logoImv.frame.size.height/3)];
        self.priceLabel.font = [UIFont systemFontOfSize:13];
        self.priceLabel.textColor = RGBCOLOR(237, 108, 22);
        [self.contentView addSubview:self.priceLabel];
        
        //加减
        UIImageView *numImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.priceLabel.frame.origin.x, CGRectGetMaxY(self.priceLabel.frame), self.priceLabel.frame.size.height * 3, logoImv.frame.size.height/3)];
        [numImv setImage:[UIImage imageNamed:@"shuliang.png"]];
        numImv.userInteractionEnabled = YES;
        [self.contentView addSubview:numImv];
        UIButton *jianBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [jianBtn setFrame:CGRectMake(0, 0, numImv.frame.size.height, numImv.frame.size.height)];
        [jianBtn setImage:[UIImage imageNamed:@"shuliang-.png"] forState:UIControlStateNormal];
        [jianBtn addTarget:self action:@selector(jianBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [numImv addSubview:jianBtn];
        
        self.numLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(jianBtn.frame), 0, numImv.frame.size.width/3, numImv.frame.size.height)];
        self.numLabel.font = [UIFont systemFontOfSize:12];
        self.numLabel.textColor = [UIColor blackColor];
        self.numLabel.textAlignment = NSTextAlignmentCenter;
        [numImv addSubview:self.numLabel];
        
        UIButton *jiaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [jiaBtn setFrame:CGRectMake(CGRectGetMaxX(self.numLabel.frame), 0, numImv.frame.size.width/3, numImv.frame.size.height)];
        [jiaBtn setImage:[UIImage imageNamed:@"shuliang+.png"] forState:UIControlStateNormal];
        [jiaBtn addTarget:self action:@selector(jiaBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [numImv addSubview:jiaBtn];
    }
    return self;
}

/**
 *  cell高度
 *
 *  @return
 */
+ (CGFloat)heightForCell
{
    CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/240];
    return height;
}

-(void)loadCustomViewWithIndex:(NSIndexPath *)index{
    
    
    self.theIndexPath = index;
    
    NSArray *arr = self.delegate.rTab.dataArray[index.section];
    ProductModel *model = arr[index.row];
    
    self.chooseBtn.selected = model.userChoose;
    
    [self.iconImageView l_setImageWithURL:[NSURL URLWithString:model.cover_pic] placeholderImage:nil];
    
    self.contentLabel.text = model.product_name;
    
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",model.current_price];
    self.numLabel.text = model.product_num;

}

//选中按钮点击
-(void)chooseBtnClicked{
    NSArray *arr = self.delegate.rTab.dataArray[self.theIndexPath.section];
    ProductModel *model = arr[self.theIndexPath.row];
    model.userChoose = !model.userChoose;
    self.chooseBtn.selected = model.userChoose;
    
    [self.delegate isAllChooseAndUpdateState];
    [self.delegate updateRtabTotolPrice];
}

//加号点击
-(void)jiaBtnClicked{
    [self prepareAddShopCar];
}

//减号点击
-(void)jianBtnClicked{
    NSArray *arr = self.delegate.rTab.dataArray[self.theIndexPath.section];
    ProductModel *model = arr[self.theIndexPath.row];
    int num = [model.product_num intValue];
    if (num == 1) {
        model.product_num = [NSString stringWithFormat:@"%d",num];
        self.numLabel.text = model.product_num;
        [self.delegate updateRtabTotolPrice];
    }else{
        
        [self prepareSubShopCar];
        
    }
    
}



//购物车加1
-(void)prepareAddShopCar{
    
    [MBProgressHUD showHUDAddedTo:self.delegate.view animated:YES];
    
    NSArray *arr = self.delegate.rTab.dataArray[self.theIndexPath.section];
    ProductModel *model = arr[self.theIndexPath.row];
    
    _request = [YJYRequstManager shareInstance];
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"cart_pro_id":model.cart_pro_id,
                          @"product_num":@"1"
                          };
    
    _request_addShopCar = [_request requestWithMethod:YJYRequstMethodPost api:ORDER_EDIT_CART_PRODUCT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        int num = [model.product_num intValue];
        num+=1;
        model.product_num = [NSString stringWithFormat:@"%d",num];
        self.numLabel.text = model.product_num;
        [MBProgressHUD hideAllHUDsForView:self.delegate.view animated:YES];
        [self.delegate updateRtabTotolPrice];
        
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.delegate.view animated:YES];
        [GMAPI showAutoHiddenMBProgressWithText:[result stringValueForKey:@"msg"] addToView:self.delegate.view];
        
    }];
    
    
    
}


//购物车-1
-(void)prepareSubShopCar{
    
    [MBProgressHUD showHUDAddedTo:self.delegate.view animated:YES];
    
    
    NSArray *arr = self.delegate.rTab.dataArray[self.theIndexPath.section];
    ProductModel *model = arr[self.theIndexPath.row];
    int num = [model.product_num intValue];
    num-=1;
    
    _request = [YJYRequstManager shareInstance];
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"cart_pro_id":model.cart_pro_id,
                          @"product_num":@"-1"
                          };
    
    _request_addShopCar = [_request requestWithMethod:YJYRequstMethodPost api:ORDER_EDIT_CART_PRODUCT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        
        [MBProgressHUD hideAllHUDsForView:self.delegate.view animated:YES];
        
        model.product_num = [NSString stringWithFormat:@"%d",num];
        self.numLabel.text = model.product_num;
        [self.delegate updateRtabTotolPrice];
        
        
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.delegate.view animated:YES];
        [GMAPI showAutoHiddenMBProgressWithText:[result stringValueForKey:@"msg"] addToView:self.delegate.view];
    }];
}




@end
