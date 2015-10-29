//
//  LQuestionView.m
//  TiJian
//
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "LQuestionView.h"
#import "GTouchMoveView.h"

@interface LQuestionView () //延展 需要在原始类中实现
{
    BOOL _mulSelect;//是否是多选
    int _answerNum;//答案个数
    int _questionId;//问题id
    GTouchMoveView *_moveView;
}

@property(copy,nonatomic)RESULTBLOCK resultBlock;

@end

@implementation LQuestionView

/**
 *  初始化问题view 根据答案个数来区分页面样式
 *
 *  @param mulSelect  是否是多选
 *  @param answerImages 答案对应images
 *  @param initNum      初始化答案 等于0时为没有初始化答案,答案从1开始
 *  @param quesitonId   问题id
 *
 *  @return
 */
-(instancetype)initQuestionViewWithFrame:(CGRect)frame
                            answerImages:(NSArray *)answerImages
                              quesitonId:(NSString *)questionId
                           questionTitle:(NSString *)questionTitle
                                 initNum:(int)initNum
                             resultBlock:(RESULTBLOCK)aBlock
                               mulSelect:(BOOL)mulSelect
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    if (self) {
        
        self.resultBlock = aBlock;
        _mulSelect = mulSelect;//是否是多选
        _answerNum = (int)answerImages.count;//答案个数
        _questionId = [questionId intValue];//记录问题id
        //head
        UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
        [self addSubview:navigationView];
        navigationView.backgroundColor = [UIColor colorWithHexString:@"7da1d1"];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 44)];
        label.font = [UIFont systemFontOfSize:17];
        label.text = questionTitle;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [navigationView addSubview:label];
        
        CGFloat top = navigationView.bottom;
        
        int count = (int)answerImages.count;
        
        NSLog(@"answers count %d",count);
        
        CGFloat width = 0.f;
        CGFloat height = 0.f;
        CGFloat left = 0.f;
        CGFloat top_view = 0.f;
        
        for (int i = 0; i < count; i ++) {
            
            PropertyButton *btn = [PropertyButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundImage:answerImages[i] forState:UIControlStateNormal];
            [self addSubview:btn];
            [btn addTarget:self action:@selector(clickToSelectAnswer:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = [questionId intValue] * 100 + i;
            
            if (count == 2) {
                
                if (iPhone4) { //单独适配4s,以高度为基准
                    
                    CGFloat maxHeight = DEVICE_HEIGHT - 64 - 40 - 5 * 2;
                    height = (maxHeight - 10) / 2.f;
                    width = height * 305 / 195;
                    left = (DEVICE_WIDTH - width) * 0.5;
                    top_view = top + 10 + (height + 10) * i;
                    
                }else
                {
                    width = FitScreen(305);
                    height = FitScreen(195);
                    left = (DEVICE_WIDTH - width) * 0.5;
                    top_view = top + 44 + (height + 30) * i;
                    
                    if (iPhone5) {
                        top_view -= 15;
                    }
                }
                
            }else if (count == 3){
                
                if (iPhone4 || iPhone5) {
                    
                    CGFloat maxHeight = DEVICE_HEIGHT - 64 - 40 - 5 * 2;
                    height = (maxHeight - 10 - 5) / 3.f;
                    width = height * 249 / 132;
                    left = (DEVICE_WIDTH - width) * 0.5;
                    top_view = top + 5 + (height + 5) * i;
                    
                }else
                {
                    width = FitScreen(249);
                    height = FitScreen(132);
                    left = (DEVICE_WIDTH - width) * 0.5;
                    top_view = top + 44 + (height + 30) * i;
                }
                
            }else if (count == 4){
                
                width = FitScreen(79);
                height = FitScreen(150);
                if (iPhone4 || iPhone5) { //单独适配 4s\5s
                    
                    width -= 5;
                    height = 150 * width / 79;
                }
                CGFloat dis = (DEVICE_WIDTH - width *4) / 6.f;
                left = dis * 1.5 + (width + dis) * i;
                
                CGFloat maxDis = height + 55 * 3;
                top_view = (DEVICE_HEIGHT - 64 - FitScreen(40) - maxDis) / 2.f;
                top_view += 55 * i + top;
                
            }else if (count == 5){
                
                width = FitScreen(150);
                height =  FitScreen(78);
                
                //单独适配 4s
                CGFloat dis = 0.f;//计算两个x之间的差
                left = 0.f;
                
                CGFloat maxDis = 0.f;
                if (iPhone4) {
                    
                    maxDis = DEVICE_HEIGHT - 64 - FitScreen(40) - 10;
                    height = (maxDis - FitScreen(15) * 4) / 5;//每个的适配高度
                    
                    width = 150 * height / 78;//每个适配宽度
                    dis = (DEVICE_WIDTH - 10 * 2 - width) / 4.f;//计算两个x之间的差
                    left = 10 + dis * i;
                    
                    top_view = (DEVICE_HEIGHT - 64 - FitScreen(40) - maxDis) / 2.f;
                    top_view = top_view + top + (FitScreen(15) + height) * i;
                    
                }else
                {
                    dis = (DEVICE_WIDTH - 10 * 2 - width) / 4.f;//计算两个x之间的差
                    left = 10 + dis * i;
                    maxDis = height * 5 + FitScreen(15) * 4;
                    top_view = (DEVICE_HEIGHT - 64 - FitScreen(40) - maxDis) / 2.f;
                    top_view = top_view + top + (FitScreen(15) + height) * i;
                }
            }
            
            btn.frame = CGRectMake(left, top_view, width, height);
            
            //加选择按钮
            UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [selectedButton setImage:[UIImage imageNamed:@"duihao"] forState:UIControlStateNormal];
            [btn addSubview:selectedButton];
            selectedButton.frame = CGRectMake(btn.width - 23 - 5, btn.height - 23 - 5, 23, 23);
            btn.selectedButton = selectedButton;
            
            if (count == 3) {
                
                if (i % 2 == 0) {
                    
                    selectedButton.left -= (23 + 5);
                }
            }
            
            //默认为未选择状态
            btn.selectedState = NO;

        }
    }
    return self;
}

/**
 *  创建年龄view
 *
 *  @param
 *  @param gender 性别
 *  @param initNum 上次选择的年龄
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
        
        
        CGFloat moveWidth = DEVICE_WIDTH - 15 * 2;
        NSString *colorHexThring = gender == Gender_Boy ? @"4fb8ce" : @"f26a74";
        NSString *arrowImageName = gender == Gender_Boy ? @"3_m_2_6fcbe7" : @"2_w_5_f26a73";
        //年龄选择器
        GTouchMoveView *moveView = [[GTouchMoveView alloc]initWithFrame:CGRectMake(15, frame.size.height - 48 - 25, moveWidth, 48) color:[UIColor colorWithHexString:colorHexThring] title:@"年龄/岁" rangeLow:0 rangeHigh:100 imageName:arrowImageName];
        [self addSubview:moveView];
        
        _moveView = moveView;
        
        if (initNum > 0) {
            [moveView setCustomValueWithStr:NSStringFromInt(initNum)];
        }
        
        if (aBlock) {
            aBlock(QUESTIONTYPE_AGE,self,@{@"result":moveView.theValue});
        }
        //监测值
        moveView.valueBlock = ^(NSString *value){
            
            if (aBlock) {
                aBlock(QUESTIONTYPE_AGE,self,@{@"result":value});
            }
        };
        
        //年龄段 四个图标
        
        CGFloat dis = (moveWidth - 26 * 2) / 3.f;
        for (int i = 0; i < 4; i ++) {
            
            NSString *imageName = [NSString stringWithFormat:@"2_%@_%d",gender == Gender_Boy ? @"m" : @"w",i + 1];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(moveView.left + dis * i + 12.5, moveView.top - 26, 26, 26)];
            imageView.image = [UIImage imageNamed:imageName];
            [self addSubview:imageView];
            
        }
    }
    return self;
}

/**
 *  创建身高view
 *
 *  @param
 *  @param gender 性别
 *  @param initNum 上次选择身高
 *  @return
 */
-(instancetype)initHeightViewWithFrame:(CGRect)frame
                             gender:(Gender)gender
                            initNum:(int)initNum
                        resultBlock:(RESULTBLOCK)aBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.resultBlock = aBlock;
        
        NSString *bgImageName = gender == Gender_Boy ? @"3_m_1_bg" : @"3_w_1_bg";

        UIImage *bgImage = [UIImage imageNamed:bgImageName];
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [LTools fitWidth:bgImage.size.height])];
        bgView.image = bgImage;
        [self addSubview:bgView];
        
        
        CGFloat moveWidth = DEVICE_WIDTH - 15 * 2;
        NSString *colorHexThring = gender == Gender_Boy ? @"4fb8ce" : @"f26a74";
        NSString *arrowImageName = gender == Gender_Boy ? @"3_m_2_6fcbe7" : @"2_w_5_f26a73";
        //选择器
        GTouchMoveView *moveView = [[GTouchMoveView alloc]initWithFrame:CGRectMake(15, frame.size.height - 48 - 25, moveWidth, 48) color:[UIColor colorWithHexString:colorHexThring] title:@"身高/cm" rangeLow:90 rangeHigh:251 imageName:arrowImageName];
        [self addSubview:moveView];
        
        _moveView = moveView;
        
        if (initNum > 0) {
            [moveView setCustomValueWithStr:NSStringFromInt(initNum)];
        }
        
        if (aBlock) {
            aBlock(QUESTIONTYPE_HEIHGT,self,@{@"result":moveView.theValue});
        }
        //监测值
        moveView.valueBlock = ^(NSString *value){
            if (aBlock) {
                aBlock(QUESTIONTYPE_HEIHGT,self,@{@"result":value});
            }
        };
        
    }
    return self;
}

/**
 *  创建体重view
 *
 *  @param
 *  @param gender 性别
 *  @param initNum 上次选择体重
 *  @return
 */
-(instancetype)initWeightViewWithFrame:(CGRect)frame
                                gender:(Gender)gender
                               initNum:(int)initNum
                           resultBlock:(RESULTBLOCK)aBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.resultBlock = aBlock;
        
        NSString *bgImageName = @"4_1_bg";
        
        UIImage *bgImage = [UIImage imageNamed:bgImageName];
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [LTools fitWidth:bgImage.size.height])];
        bgView.image = bgImage;
        [self addSubview:bgView];
        
        
        CGFloat moveWidth = DEVICE_WIDTH - 15 * 2;
        NSString *colorHexThring = @"e7bf79";
        NSString *arrowImageName = @"4_2_e8bf78";
        //选择器
        GTouchMoveView *moveView = [[GTouchMoveView alloc]initWithFrame:CGRectMake(15, frame.size.height - 48 - 25, moveWidth, 48) color:[UIColor colorWithHexString:colorHexThring] title:@"体重/kg" rangeLow:45 rangeHigh:300 imageName:arrowImageName];
        [self addSubview:moveView];
        
        _moveView = moveView;
        
        if (initNum > 0) {
            [moveView setCustomValueWithStr:NSStringFromInt(initNum)];
        }
        
        if (aBlock) {
            aBlock(QUESTIONTYPE_WEIGHT,self,@{@"result":moveView.theValue});
        }
        //监测值
        moveView.valueBlock = ^(NSString *value){
            
            if (aBlock) {
                aBlock(QUESTIONTYPE_WEIGHT,self,@{@"result":value});
            }
        };
        
    }
    return self;
}

/**
 *  设置滑动条初始值
 *
 *  @param initValue 初始值
 */
- (void)setInitValue:(NSString *)initValue
{
    initValue = NSStringFromInt([initValue intValue]);
    [_moveView setCustomValueWithStr:initValue];
}

- (void)clickToSelectSex:(UIButton *)btn
{
    
}

/**
 *  选择答案
 *
 *  @param sender
 */
- (void)clickToSelectAnswer:(PropertyButton *)sender
{
    sender.selectedState = !sender.selectedState;
    //根据tag 取问题id
    
    //多选
    if (_mulSelect) {
        return; //多选情况下不进行一下代码
    }
    
    for (int i = 0 ; i < _answerNum; i ++) {
        
        int tag = _questionId * 100 + i;
        if (tag != sender.tag) {
            
            PropertyButton *btn = (PropertyButton *)[self viewWithTag:tag];
            btn.selectedState = NO;
        }
    }
    
    int value = (int)sender.tag - _questionId * 100 + 1;//代表答案第几个,从1开始
    
    //单选时 自动跳转下个页面
    
    if (self.resultBlock) {
        self.resultBlock(QUESTIONTYPE_OTHER,self,@{@"result":[NSNumber numberWithInt:value]});
    }
    
}

/**
 *  获取选项选择状态1和0的串
 *
 */
- (NSString *)optionsSelectedState
{
    NSMutableString *answerString = [NSMutableString string];
    for (int i = 0 ; i < _answerNum; i ++) {
        
        int tag = _questionId * 100 + i;
        PropertyButton *btn = (PropertyButton *)[self viewWithTag:tag];
        [answerString appendFormat:@"%d",btn.selectedState ? 1 : 0];
    }
    NSLog(@"answerString %@",answerString);
    return answerString;
}

/**
 *  是否可以进行下一个
 *
 *  @return YES or NO
 */
- (BOOL)enableForward
{
    if (_questionId <= 4) { //性别、年龄、身高、体重 是可以直接跳转的
        return YES;
    }
    
    for (int i = 0 ; i < _answerNum; i ++) {
        int tag = _questionId * 100 + i;
        PropertyButton *btn = (PropertyButton *)[self viewWithTag:tag];
        if (btn.selectedState) {
            
            return YES;//只要有被选中得就可以跳转
        }
    }
    
    return NO;//没有被选择代表还没有选
}

@end
