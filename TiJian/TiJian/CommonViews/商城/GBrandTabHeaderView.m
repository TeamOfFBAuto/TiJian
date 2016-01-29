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
        
        self.backgroundColor = [UIColor greenColor];
        
        //背景图
        self.brandBannerImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 230.0/750*DEVICE_WIDTH)];
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
        
        //四个按钮view
        self.fourBtnView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.classView.frame), DEVICE_WIDTH, 37)];
        self.fourBtnView.backgroundColor = [UIColor redColor];
        [self addSubview:self.fourBtnView];
        
        //分割线
        UIView *fenLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.fourBtnView.frame), DEVICE_WIDTH, 5)];
        fenLine.backgroundColor = RGBCOLOR(244, 245, 246);
        [self addSubview:fenLine];
        
        CGFloat height = self.brandBannerImv.frame.size.height + self.classView.frame.size.height + self.fourBtnView.frame.size.height + fenLine.frame.size.height;
        
        [self setHeight:height];
        
        
        
    }
    return self;
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
        
    }
    
    
    
}

@end
