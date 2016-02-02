//
//  GBrandTabHeaderView.m
//  TiJian
//
//  Created by gaomeng on 16/1/29.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GBrandTabHeaderView.h"

@implementation GBrandTabHeaderView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        //背景图
        self.brandBannerImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 230.0/750*DEVICE_WIDTH)];
        [self.brandBannerImv addTaget:self action:@selector(brandBannerImvClicked) tag:0];
        [self addSubview:self.brandBannerImv];
        
        //logo
        self.logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(15, self.brandBannerImv.frame.size.height - 15 - 185.0/750*DEVICE_WIDTH*63/185, 185.0/750*DEVICE_WIDTH, 185.0/750*DEVICE_WIDTH*63/185)];
        [self.brandBannerImv addSubview:self.logoImv];
        
        self.brandName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.logoImv.frame)+5, self.logoImv.frame.origin.y, DEVICE_WIDTH - 15 - 5 - self.logoImv.frame.size.width - 15, self.logoImv.frame.size.height*0.5)];
        self.brandName.font = [UIFont systemFontOfSize:14];
        self.brandName.textColor = [UIColor whiteColor];
        [self.brandBannerImv addSubview:self.brandName];
        
        self.liulanNum = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.logoImv.frame)+5, CGRectGetMaxY(self.brandName.frame), self.brandName.frame.size.width, self.brandName.frame.size.height)];
        self.liulanNum.font = [UIFont systemFontOfSize:13];
        self.liulanNum.textColor = [UIColor whiteColor];
        [self.brandBannerImv addSubview:self.liulanNum];
        
        
        //分类view
        self.classView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.brandBannerImv.frame), DEVICE_WIDTH, 0)];
        self.classView.backgroundColor = [UIColor purpleColor];
        [self addSubview:self.classView];
        
        
        CGFloat height = self.brandBannerImv.frame.size.height + self.classView.frame.size.height;
        
        [self setHeight:height];
        
        
        
    }
    return self;
}


-(UIView *)getFourBtnView{
    //四个按钮view
    self.fourBtnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 42)];
    self.fourBtnView.backgroundColor = [UIColor whiteColor];
    CGFloat width = DEVICE_WIDTH/4-0.5;
    NSArray *titleArray = @[@"推荐",@"热销",@"新品",@"价格"];
    
    self.fourBtnArray = [NSMutableArray arrayWithCapacity:1];
    
    for (int i = 0; i<4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake((width+0.5)*i, 0.5, width, 37)];
        
        //竖线
        UIView *fenLine = [[UIView alloc]initWithFrame:CGRectMake(width*i-0.5, 8, 0.5, 23)];
        fenLine.backgroundColor = RGBCOLOR(226, 228, 229);
        [self.fourBtnView addSubview:fenLine];
        
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:RGBCOLOR(80, 81, 82) forState:UIControlStateNormal];
        [btn setTitleColor:RGBCOLOR(116, 162, 208) forState:UIControlStateSelected];
        
        
        if (i == 0) {
            btn.selected = YES;
        }else if (i == 3){
            [btn setImage:[UIImage imageNamed:@"pricejiantou_down.png"] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -width+15)];
        }
        btn.backgroundColor = [UIColor whiteColor];
        btn.tag = 10+i;
        [btn addTarget:self action:@selector(forBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.fourBtnView addSubview:btn];
        [self.fourBtnArray addObject:btn];
    }
    
    //分割线
    UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5)];
    upLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.fourBtnView addSubview:upLine];
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, 37, DEVICE_WIDTH, 5)];
    downLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.fourBtnView addSubview:downLine];
    
    return self.fourBtnView;
}






-(void)reloadViewWithBrandDic:(NSDictionary *)theBranddic classDic:(NSDictionary *)theClassDic{
    
    
    //品牌详情
    if (theBranddic) {
        NSDictionary *dataDic = [theBranddic dictionaryValueForKey:@"data"];
        
        NSString *bannerUrl = [dataDic stringValueForKey:@"banner"];
        [self.brandBannerImv l_setImageWithURL:[NSURL URLWithString:bannerUrl] placeholderImage:nil];
        
        NSString *logoUrl = [dataDic stringValueForKey:@"logo"];
        [self.logoImv l_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:nil];
        
        NSString *brandName = [dataDic stringValueForKey:@"brand_name"];
        self.brandName.text = brandName;
        
        NSString *liulanNum = [dataDic stringValueForKey:@"view_num"];
        self.liulanNum.text = [NSString stringWithFormat:@"%@人浏览",liulanNum];
    }
    
    //分类详情
    if (theClassDic) {
        NSArray *dataArray = [theClassDic arrayValueForKey:@"data"];
        //共几行
        int hang = (int)dataArray.count/4;
        if (hang < dataArray.count/4.0) {
            hang+=1;
        };
        //每行几列
        int lie = 4;
        //宽
        CGFloat kk = DEVICE_WIDTH/4;
        //高
        CGFloat hh = kk;
        
        if (dataArray.count>0) {
            [self.classView setHeight:hang * hh];
        }
        
        for (int i = 0; i<dataArray.count; i++) {
            
            NSDictionary *dic = dataArray[i];
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(i%lie*kk, i/lie*hh, kk, hh)];
            [imv l_setImageWithURL:[NSURL URLWithString:[dic stringValueForKey:@"brand_cover_pic"]] placeholderImage:nil];
            imv.tag = 100 + i;
            
            [imv addTapGestureTaget:self action:@selector(classImvClicked:) imageViewTag:imv.tag];
            [self.classView addSubview:imv];
        }
        
        CGFloat self_height = self.brandBannerImv.frame.size.height + self.classView.frame.size.height;
        [self setHeight:self_height];
        
    }
    
}


-(void)classImvClicked:(UIGestureRecognizer*)sender{
    self.classImvClickedBlock(sender.view.tag);
}

-(void)forBtnClicked:(UIButton *)sender{
    sender.selected = YES;
    NSInteger theTag = sender.tag;
    
    for (UIButton *btn in self.fourBtnArray) {
        if (btn.tag != theTag) {
            btn.selected = NO;
        }
    }
    
    if (sender.selected && theTag == 13){
        _priceState = !_priceState;
        if (_priceState) {//升序
            [sender setImage:[UIImage imageNamed:@"pricejiantou_up.png"] forState:UIControlStateNormal];
        }else{//降序
            [sender setImage:[UIImage imageNamed:@"pricejiantou_down.png"] forState:UIControlStateNormal];
        }
        
    }
    self.fourBtnClickedBlock(theTag,_priceState);
    
}

-(void)setFourBtnClickedBlock:(fourBtnClickedBlock)fourBtnClickedBlock{
    _fourBtnClickedBlock = fourBtnClickedBlock;
}

-(void)setClassImvClickedBlock:(classImvClickedBlock)classImvClickedBlock{
    _classImvClickedBlock = classImvClickedBlock;
}

-(void)setBannerImvClickedBlock:(bannerImvClickedBlock)bannerImvClickedBlock{
    _bannerImvClickedBlock = bannerImvClickedBlock;
}

-(void)brandBannerImvClicked{
    self.bannerImvClickedBlock();
}

@end
