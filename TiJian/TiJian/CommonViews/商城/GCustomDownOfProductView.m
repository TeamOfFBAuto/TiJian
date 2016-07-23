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
    if (!self) {
        self = [super initWithFrame:frame];
    }
    self.backgroundColor = RGBCOLOR(38, 51, 62);
    if (theType == TheDownViewType_gouwuche) {
        UIButton *_shoucang_btn;
        
        UIButton *_addShopCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addShopCarBtn.tag = 104;
        CGFloat theW = [GMAPI scaleWithHeight:50 width:0 theWHscale:180.0/100];
        [_addShopCarBtn setFrame:CGRectMake(self.frame.size.width-theW, 0, theW, 50)];
        _addShopCarBtn.backgroundColor = RGBCOLOR(224, 103, 20);
        [_addShopCarBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
        
        [_addShopCarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addShopCarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_addShopCarBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addShopCarBtn];
        
        CGFloat tw = (self.frame.size.width-theW)/4;
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
                //                if ([self.theProductModel.is_favor intValue] == 1) {//已收藏
                //                    oneBtn.selected = YES;
                //                }else{
                //                    oneBtn.selected = NO;
                //                }
                
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
                UILabel * _shopCarNumLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                _shopCarNumLabel.textColor = RGBCOLOR(242, 120, 47);
                _shopCarNumLabel.backgroundColor = [UIColor whiteColor];
                _shopCarNumLabel.layer.cornerRadius = 5;
                _shopCarNumLabel.layer.borderColor = [[UIColor whiteColor]CGColor];
                _shopCarNumLabel.layer.borderWidth = 0.5f;
                _shopCarNumLabel.layer.masksToBounds = YES;
                _shopCarNumLabel.font = [UIFont systemFontOfSize:8];
                _shopCarNumLabel.textAlignment = NSTextAlignmentCenter;
                _shopCarNumLabel.text = [NSString stringWithFormat:@"0"];
                [oneBtn addSubview:_shopCarNumLabel];
                //                _gouwucheOneBtn = oneBtn;
                
            }
            
            
        }
        
        
        
    }else if (theType == TheDownViewType_yuyue){
        
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
