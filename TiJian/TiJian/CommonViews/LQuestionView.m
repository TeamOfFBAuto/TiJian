//
//  LQuestionView.m
//  TiJian
//
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "LQuestionView.h"
#import "GTouchMoveView.h"
#import "OptionModel.h"

@interface LQuestionView () //延展 需要在原始类中实现
{
    QUESTIONOPTIONTYPE _mulSelect;//是否是多选
    int _answerNum;//答案个数
    int _questionId;//问题id
    GTouchMoveView *_moveView;
    int _specialOptionId;//特殊选项id
}

@property(copy,nonatomic)RESULTBLOCK resultBlock;

@end

@implementation LQuestionView

/**
 *  初始化问题view 根据答案个数来区分页面样式
 *
 *  @param mulSelect  是否是多选
 *  @param answerImages 答案对应images
 *  @param initAnswerString      初始化答案二进制串
 *  @param quesitonId   问题id
 *  @param specialOptionId 特殊选项id
 *
 *  @return
 */
-(instancetype)initQuestionViewWithFrame:(CGRect)frame
                            answerImages:(NSArray *)answerImages
                              quesitonId:(NSString *)questionId
                           questionTitle:(NSString *)questionTitle
                        initAnswerString:(NSString *)initAnswerString
                             resultBlock:(RESULTBLOCK)aBlock
                               mulSelect:(QUESTIONOPTIONTYPE)mulSelect
                         specialOptionId:(int)specialOptionId
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    if (self) {
        
        self.resultBlock = aBlock;
        _mulSelect = mulSelect;//选项的类型
        _answerNum = (int)answerImages.count;//答案个数
        _questionId = [questionId intValue];//记录问题id
        _specialOptionId = specialOptionId;
        //head
        UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, HMFitIphoneX_navcBarHeight)];
        [self addSubview:navigationView];
        navigationView.backgroundColor = [UIColor colorWithHexString:@"7da1d1"];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 44)];
        if (iPhoneX) {
            [label setFrame:CGRectMake(0, 20+24, DEVICE_WIDTH, 44)];
        }
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
            
            
            OptionModel *option = [answerImages objectAtIndex:i];

            PropertyButton *btn = [PropertyButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundImage:option.optionImage forState:UIControlStateNormal];
            [self addSubview:btn];
            [btn addTarget:self action:@selector(clickToSelectAnswer:) forControlEvents:UIControlEventTouchUpInside];
            
            btn.tag = [questionId intValue] * 100 + i;
            btn.aModel = option;
            
            
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
            }else if (count == 8){
                
                //八个选项
                width = FitScreen(150);
                height =  FitScreen(78);
                
                CGFloat heightPadding = height * 3/4.f;
                if (iPhone5) { //单独适配 5s
                    
                    width -= 10;
                    height = 78 * width / 150;
                    heightPadding = height * 3/5.f;
                }
                
                if (iPhone4) { //适配4s
                    width -= 30;
                    height = 78 * width / 150;
                    heightPadding = height * 3/5.f;
                }
                
                left = (DEVICE_WIDTH - 20 - width * 2) / 2.f;//计算两个x之间的差

                int colum = i % 2;//第几列
                left = colum == 0 ? left : (left + 20 + width);
                top_view = top + 30 + i * heightPadding;
            }
            
            btn.frame = CGRectMake(left, top_view, width, height);
            
            //加选择按钮
            UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [selectedButton setImage:nil forState:UIControlStateNormal];
            [selectedButton setImage:[UIImage imageNamed:@"duihao"] forState:UIControlStateSelected];
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
            
            if (initAnswerString && [[initAnswerString substringWithRange:NSMakeRange(i, 1)] intValue] == 1) {
                
                btn.selectedState = YES;//更新选中状态
            }else
            {
                btn.selectedState = NO;
            }

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
        
        _questionId = 0;
        
        self.resultBlock = aBlock;
        UIImage *bgImage = [UIImage imageNamed:@"2_1_bg"];
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [LTools fitWidth:bgImage.size.height])];
        bgView.image = bgImage;
        [self addSubview:bgView];
        
        
        CGFloat moveWidth = DEVICE_WIDTH - 15 * 2;
        NSString *colorHexThring = gender == Gender_Boy ? @"4fb8ce" : @"f26a74";
        NSString *arrowImageName = gender == Gender_Boy ? @"3_m_2_6fcbe7" : @"2_w_5_f26a73";
        //年龄选择器
        GTouchMoveView *moveView = [[GTouchMoveView alloc]initWithFrame:CGRectMake(15, frame.size.height - 48 - 25, moveWidth, 48) color:[UIColor colorWithHexString:colorHexThring] title:@"年龄/岁" rangeLow:16 rangeHigh:80 imageName:arrowImageName];
        [self addSubview:moveView];
                
        if (iPhone4) {
            
            moveView.top += 20;
            bgView.height -= 50;
        }
        
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
        
        /**
         *  增大滑动区域
         */
        [self addTouchAreaWithFrame:frame];
        
    }
    return self;
}

/**
 *  控制滑块
 *
 *  @param pan
 */
- (void)pangeture:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self];
    CGFloat x = point.x;
    CGFloat percent = (x - 20) / (self.width - 20 * 2);
    if (percent < 0) {
        percent = 0.f;
    }
    if (percent > 1) {
        percent = 1;
    }
    [_moveView setLocationxpercernt:percent];
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
        _questionId = 0;
        
        NSString *bgImageName = gender == Gender_Boy ? @"3_m_1_bg" : @"3_w_1_bg";

        UIImage *bgImage = [UIImage imageNamed:bgImageName];
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [LTools fitWidth:bgImage.size.height])];
        bgView.image = bgImage;
        [self addSubview:bgView];
        
        
        CGFloat moveWidth = DEVICE_WIDTH - 15 * 2;
        NSString *colorHexThring = gender == Gender_Boy ? @"4fb8ce" : @"f26a74";
        NSString *arrowImageName = gender == Gender_Boy ? @"3_m_2_6fcbe7" : @"2_w_5_f26a73";
        //选择器
        GTouchMoveView *moveView = [[GTouchMoveView alloc]initWithFrame:CGRectMake(15, frame.size.height - 48 - 25, moveWidth, 48) color:[UIColor colorWithHexString:colorHexThring] title:@"身高/cm" rangeLow:120 rangeHigh:200 imageName:arrowImageName];
        [self addSubview:moveView];
        
        if (iPhone4) {
            
            moveView.top += 20;
            bgView.height -= 50;
        }
        
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
        
        /**
         *  增大滑动区域
         */
        [self addTouchAreaWithFrame:frame];
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
        _questionId = 0;

        NSString *bgImageName = @"4_1_bg";
        
        UIImage *bgImage = [UIImage imageNamed:bgImageName];
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [LTools fitWidth:bgImage.size.height])];
        bgView.image = bgImage;
        [self addSubview:bgView];
        
        
        CGFloat moveWidth = DEVICE_WIDTH - 15 * 2;
        NSString *colorHexThring = @"e7bf79";
        NSString *arrowImageName = @"4_2_e8bf78";
        //选择器
        GTouchMoveView *moveView = [[GTouchMoveView alloc]initWithFrame:CGRectMake(15, frame.size.height - 48 - 25, moveWidth, 48) color:[UIColor colorWithHexString:colorHexThring] title:@"体重/kg" rangeLow:40 rangeHigh:150 imageName:arrowImageName];
        [self addSubview:moveView];
        
        if (iPhone4) {
            
            moveView.top += 20;
            bgView.height -= 50;
        }
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
        
        /**
         *  增大滑动区域
         */
        [self addTouchAreaWithFrame:frame];
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

/**
 *  选择答案
 *
 *  @param sender
 */
- (void)clickToSelectAnswer:(PropertyButton *)sender
{
    sender.selectedState = !sender.selectedState;
    //根据tag 取问题id
    
    if (_mulSelect == QUESTIONOPTIONTYPE_SINGLE) { //单选
        
        for (int i = 0 ; i < _answerNum; i ++) {
            
            int tag = _questionId * 100 + i;
            if (tag != sender.tag) {
                
                PropertyButton *btn = (PropertyButton *)[self viewWithTag:tag];
                btn.selectedState = NO;
            }
        }
    }else if (_mulSelect == QUESTIONOPTIONTYPE_MULTI){ //多选
        
        NSLog(@"多选");
        
    }else if (_mulSelect == QUESTIONOPTIONTYPE_MULTI_NOSPECIAL){ //除了特殊选项其他可多选，选特殊选项则其他都不能选
        
        //首先判断是否选择的是 特殊选项
        OptionModel *sender_model = sender.aModel;
        //选择是特殊选项
        if (sender_model.optionId == _specialOptionId) {
            
            if (sender.selectedState) {
                
                for (int i = 0; i < _answerNum; i ++) {
                    
                    int tag = _questionId * 100 + i;
                    PropertyButton *btn = (PropertyButton *)[self viewWithTag:tag];
                    if (btn != sender) {
                        
                        btn.selectedState = NO;
                    }
                }
            }
        }else //不是特殊选项的话,特殊选项置为NO
        {
            for (int i = 0; i < _answerNum; i ++) {
                
                int tag = _questionId * 100 + i;
                PropertyButton *btn = (PropertyButton *)[self viewWithTag:tag];
                OptionModel *o_model = btn.aModel;

                if (o_model.optionId == _specialOptionId) {
                    
                    btn.selectedState = NO;
                }
            }
        }
        
    }else if (_mulSelect == QUESTIONOPTIONTYPE_SINGLE_NOSPECIAL){ //正常的选项单选,但是可以分别和特殊选项组合
        
        //首先判断是否选择的是 特殊选项
        OptionModel *sender_model = sender.aModel;
        
        //点击特殊选项时,其他的不用改变状态
        if (sender_model.optionId == _specialOptionId) {
            

        }else //点击不是特殊选项的话 特殊选项不变,其他选项变,且其他选项不能同时被选择
        {
            for (int i = 0; i < _answerNum; i ++) {
                
                int tag = _questionId * 100 + i;
                PropertyButton *btn = (PropertyButton *)[self viewWithTag:tag];
                OptionModel *o_model = btn.aModel;
                
                if (o_model.optionId != _specialOptionId) {
                    
                    if (sender.selectedState) {
                        
                        if (btn != sender) {
                            
                            btn.selectedState = NO;
                        }else
                        {
                            btn.selectedState = YES;
                        }
                    }
                }
            }
        }
        
    }else if (_mulSelect == QUESTIONOPTIONTYPE_OTHER){ //其他
        
        
    }
    
    //获取所有选项和对应选择状态
    NSMutableArray *state_arr = [NSMutableArray arrayWithCapacity:_answerNum];//记录所有的选项和状态
    for (int i = 0 ; i < _answerNum; i ++) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        int tag = _questionId * 100 + i;
        PropertyButton *btn = (PropertyButton *)[self viewWithTag:tag];
        OptionModel *option = btn.aModel;
        [dic setObject:[NSNumber numberWithBool:btn.selectedState] forKey:NSStringFromInt(option.optionId)];
        [state_arr addObject:dic];
    }
    
    //回调结果
    if (self.resultBlock) {
        self.resultBlock((int)_mulSelect,self,@{QUESTION_OPTION_TYPE:[NSNumber numberWithInt:_mulSelect],
                                                   QUESTION_ANSERSTRING:[self optionsSelectedState],
                                                   QUESTION_OPTION_IDS:state_arr
                                                   });
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
    if (_questionId == 0) { //性别、年龄、身高、体重 是可以直接跳转的
        
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

#pragma mark - 增大滑动区域

- (void)addTouchAreaWithFrame:(CGRect)frame
{
    //目的增大滑动区域
    //滑动区域
    UIView *panView = [[UIView alloc]initWithFrame:CGRectMake(_moveView.left, frame.size.height - 150, _moveView.width, 150)];
    [self addSubview:panView];
    panView.backgroundColor = [UIColor clearColor];
    
    //拖拽手势控制滑块
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pangeture:)];
    [panView addGestureRecognizer:pan];
}

@end
