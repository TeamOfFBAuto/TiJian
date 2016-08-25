//
//  GCustomDownOfProductView.m
//  TiJian
//
//  Created by gaomeng on 16/7/20.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GCustomDownOfProductView.h"

@implementation GCustomDownOfProductView


-(id)initWithFrame:(CGRect)frame customType:(TheDownViewType)theType{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBCOLOR(38, 51, 62);
        
        if (theType == TheDownViewType_gouwuche || theType == TheDownViewType_vourcher) {
            self.addShopCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.addShopCarBtn.tag = 104;
            CGFloat theW = [GMAPI scaleWithHeight:50 width:0 theWHscale:180.0/100];
            [self.addShopCarBtn setFrame:CGRectMake(self.frame.size.width-theW, 0, theW, 50)];
            self.addShopCarBtn.backgroundColor = RGBCOLOR(224, 103, 20);
            
            [self.addShopCarBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
            if (theType == TheDownViewType_vourcher) {
                [self.addShopCarBtn setTitle:@"立即购买" forState:UIControlStateNormal];
            }
            [self.addShopCarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.addShopCarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            [self.addShopCarBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.addShopCarBtn];
            
            CGFloat tw = (self.frame.size.width-theW)/4;
            NSArray *titleArray = @[@"客服",@"收藏",@"预约",@"购物车"];
            NSArray *imageNameArray = @[@"kefu_pd.png",@"shoucang_pd.png",@"yuyue_pd.png",@"gouwuche_pd.png"];
            for (int i = 0; i<4; i++) {
                UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [oneBtn setFrame:CGRectMake(i*tw, 0, tw, 50)];
                [oneBtn setTitle:titleArray[i] forState:UIControlStateNormal];
                [oneBtn setImage:[UIImage imageNamed:imageNameArray[i]] forState:UIControlStateNormal];
                if (i == 1) {
                    self.shoucang_btn = oneBtn;
                    [oneBtn setImage:[UIImage imageNamed:@"shoucang_pd.png"] forState:UIControlStateNormal];
                    [oneBtn setImage:[UIImage imageNamed:@"yishoucang.png"] forState:UIControlStateSelected];
                    
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
                [self addSubview:oneBtn];
                
                if (i == 3) {
                    self.shopCarNumLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                    self.shopCarNumLabel.textColor = RGBCOLOR(242, 120, 47);
                    self.shopCarNumLabel.backgroundColor = [UIColor whiteColor];
                    self.shopCarNumLabel.layer.cornerRadius = 5;
                    self.shopCarNumLabel.layer.borderColor = [[UIColor whiteColor]CGColor];
                    self.shopCarNumLabel.layer.borderWidth = 0.5f;
                    self.shopCarNumLabel.layer.masksToBounds = YES;
                    self.shopCarNumLabel.font = [UIFont systemFontOfSize:8];
                    self.shopCarNumLabel.textAlignment = NSTextAlignmentCenter;
                    self.shopCarNumLabel.text = [NSString stringWithFormat:@"0"];
                    [oneBtn addSubview:self.shopCarNumLabel];
                    self.gouwucheOneBtn = oneBtn;
                    
                }
                
                
            }
            
            
            
        }else if (theType == TheDownViewType_yuyue){
            self.addShopCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.addShopCarBtn.tag = 104;
            CGFloat theW = [GMAPI scaleWithHeight:50 width:0 theWHscale:180.0/100];
            [self.addShopCarBtn setFrame:CGRectMake(self.frame.size.width-theW, 0, theW, 50)];
            self.addShopCarBtn.backgroundColor = RGBCOLOR(224, 103, 20);
            
            [self.addShopCarBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
            if (theType == TheDownViewType_yuyue) {
                [self.addShopCarBtn setTitle:@"立即预约" forState:UIControlStateNormal];
            }
            [self.addShopCarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.addShopCarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            [self.addShopCarBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.addShopCarBtn];
            
            CGFloat tw = (self.frame.size.width-theW)/3;
            NSArray *titleArray = @[@"联系客服",@"电话咨询",@"收藏"];
            NSArray *imageNameArray = @[@"kefu_pd1.png",@"dianhua_pd1.png",@"shoucang_pd.png"];
            for (int i = 0; i<3; i++) {
                UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [oneBtn setFrame:CGRectMake(i*tw, 0, tw, 50)];
                [oneBtn setTitle:titleArray[i] forState:UIControlStateNormal];
                [oneBtn setImage:[UIImage imageNamed:imageNameArray[i]] forState:UIControlStateNormal];
                if (i == 2) {
                    self.shoucang_btn = oneBtn;
                    [oneBtn setImage:[UIImage imageNamed:@"shoucang_pd.png"] forState:UIControlStateNormal];
                    [oneBtn setImage:[UIImage imageNamed:@"yishoucang.png"] forState:UIControlStateSelected];
                    
                }
                if (i<2) {
                    if (DEVICE_WIDTH<375) {//4s 5s
                        [oneBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 19, 25, 14)];
                    }else{
                        [oneBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 34, 25, 0)];
                    }
                }else{
                    [oneBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 18, 25, 0)];
                    
                }
                
                [oneBtn setTitleEdgeInsets:UIEdgeInsetsMake(25, -20, 0, 0)];
                oneBtn.titleLabel.font = [UIFont systemFontOfSize:10];
                oneBtn.tag = 100+i;
                [oneBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:oneBtn];
                
            }
            
            
            
            
            
        }
    }
    
    
    return self;
}


-(void)setDownViewClickedBlock:(downViewClickedBlock)downViewClickedBlock{
    _downViewClickedBlock = downViewClickedBlock;
}





-(void)downBtnClicked:(UIButton *)sender{
    if (self.downViewClickedBlock) {
        self.downViewClickedBlock(sender.tag);
    }
}


@end
