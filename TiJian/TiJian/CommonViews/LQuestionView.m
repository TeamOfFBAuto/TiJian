//
//  LQuestionView.m
//  TiJian
//
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "LQuestionView.h"

@interface LQuestionView () //延展 需要在原始类中实现

@property(copy,nonatomic)RESULTBLOCK resultBlock;

@end

@implementation LQuestionView

-(instancetype)initWithFrame:(CGRect)frame
                answerImages:(NSArray *)answerImages
{
    self = [super initWithFrame:frame];
    if (self) {
        
        int count = (int)answerImages.count;
        
    }
    return self;
}

///**
// *  创建问题view
// *
// *  @param
// *  @param gender 性别
// *  @param selectAge 上次选择的年龄
// *  @return
// */
//-(instancetype)initQuestionViewWithGender:(Gender)gender
//                             questionType:(QUESTIONTYPE)type
//                            initNum:(int)initNum
//                        resultBlock:(RESULTBLOCK)aBlock
//{
//    
//}

/**
 *  性别选择视图
 */
- (void)prepareSexViewWithInit
{
    //选择性别
    UIView *_view_sex = [[UIView alloc]init];
    _view_sex.backgroundColor = [UIColor whiteColor];
    [self addSubview:_view_sex];
    [_view_sex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    UIImage *bgImage = [UIImage imageNamed:@"1_1_bg"];
    CGFloat width = bgImage.size.width;
    CGFloat height = bgImage.size.height;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, [LTools fitHeight:85], FitScreen(width), FitScreen(height))];
    imageView.image = bgImage;
    imageView.centerX = self.centerX;
    [_view_sex addSubview:imageView];
    
    //选项
    UIImage *boyImage = [UIImage imageNamed:@"1_2_boy"];
    UIImage *girlImage = [UIImage imageNamed:@"1_3_girl"];
    CGFloat imageWidth = boyImage.size.width;
    CGFloat imageHeight = boyImage.size.height;
    CGFloat aWidth = (DEVICE_WIDTH - imageWidth * 2)/ 3.f;//每个选项宽度
    for (int i = 0; i < 2; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            [btn setImage:boyImage forState:UIControlStateNormal];
        }else if (i == 1){
            [btn setImage:girlImage forState:UIControlStateNormal];
        }
        btn.tag = 100 + i;//100 为男 101 为女
        [_view_sex addSubview:btn];
        [btn addTarget:self action:@selector(clickToSelectSex:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(aWidth + (imageWidth + aWidth) * i, [LTools fitHeight:50] + imageView.bottom, imageWidth, imageHeight);
        
    }
}


/**
 *  创建年龄view
 *
 *  @param
 *  @param gender 性别
 *  @param selectAge 上次选择的年龄
 *  @return
 */
-(instancetype)initAgeViewWithFrame:(CGRect)frame
                      gender:(Gender)gender
                          initNum:(int)initNum
                        resultBlock:(RESULTBLOCK)aBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.resultBlock = aBlock;
        UIImage *bgImage = [UIImage imageNamed:@"2_1_bg"];
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [LTools fitWidth:bgImage.size.height])];
        bgView.image = bgImage;
        [self addSubview:bgView];
    }
    return self;
}

- (void)clickToSelectSex:(UIButton *)btn
{
    
}


@end
