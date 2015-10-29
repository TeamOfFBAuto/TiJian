//
//  PersonalCustomViewController.m
//  TiJian
//
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PersonalCustomViewController.h"
#import "LQuestionView.h"
#import "QuestionModel.h"

#define Q_AGE @"age" //年龄
#define Q_WEIGHT @"weight" //体重
#define Q_HEIGHT @"height" //身高
#define Q_SEX @"sex" //性别

#define kCurrentTag 1000
#define kNextTag 1001
#define kLastTag 1002

@interface PersonalCustomViewController ()
{
    UIView *_view_sex;//性别选择
    LQuestionView *_view_Age;//年龄
    LQuestionView *_view_Height;//身高
    LQuestionView *_view_Weight;//体重
    UIView *_bottomView;//底部view
    UIScrollView *_scroll;//底部scroll
    
    UIView *_lastView;//上一个view
    UIView *_currentView;//当前view
    UIView *_newView;//下一个view
    
    Gender _selectedGender;//记录选择的性别
    NSMutableDictionary *_questionDictionary;//记录问题信息
    
    int _questionId;//当前问题id
    int _groupId;//当前groupId
    
    int _test;
}

@end

@implementation PersonalCustomViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    _questionDictionary = [NSMutableDictionary dictionary];
    
    
    _groupId = 1;//初始化,第一个组合id为1
    _test = 1;
    //性别
    _view_sex = [self createSexViewWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [self.view addSubview:_view_sex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 视图创建
/**
 *  创建性别选择页面
 *
 *  @param frame
 *
 *  @return
 */
- (UIView *)createSexViewWithFrame:(CGRect)frame
{
    //选择性别
    UIView *view_sex = [[UIView alloc]initWithFrame:frame];
    view_sex.backgroundColor = [UIColor whiteColor];
    
    UIImage *bgImage = [UIImage imageNamed:@"1_1_bg"];
    CGFloat width = bgImage.size.width;
    CGFloat height = bgImage.size.height;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, [LTools fitHeight:85], FitScreen(width), FitScreen(height))];
    imageView.image = bgImage;
    imageView.centerX = view_sex.centerX;
    [view_sex addSubview:imageView];
    
    //选项
    UIImage *boyImage = [UIImage imageNamed:@"1_2_boy"];
    UIImage *girlImage = [UIImage imageNamed:@"1_3_girl"];
    CGFloat imageWidth = boyImage.size.width;
    CGFloat imageHeight = boyImage.size.height;
    CGFloat aWidth = (DEVICE_WIDTH - imageWidth * 2)/ 3.f;//间距
    
    if (iPhone4){ //单独适配4s
        
        imageWidth = imageWidth * 0.8;
        imageHeight = imageHeight * 0.8;
        aWidth = (DEVICE_WIDTH - imageWidth * 2) / 3.f;
        
    }
    
    for (int i = 0; i < 2; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            [btn setImage:boyImage forState:UIControlStateNormal];
        }else if (i == 1){
            [btn setImage:girlImage forState:UIControlStateNormal];
        }
        btn.tag = 100 + i;//100 为男 101 为女
        [view_sex addSubview:btn];
        [btn addTarget:self action:@selector(clickToSelectSex:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(aWidth + (imageWidth + aWidth) * i, [LTools fitHeight:50] + imageView.bottom, imageWidth, imageHeight);
        
    }

    return view_sex;
}

- (void)prepareBottom
{
    if (_bottomView) {
        return;
    }
    _bottomView = [[UIView alloc]init];
    [self.view addSubview:_bottomView];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
        make.size.mas_equalTo(CGSizeMake(DEVICE_WIDTH, FitScreen(40)));
    }];
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 0, FitScreen(40), FitScreen(40));
    [backBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [_bottomView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(clickToLast:) forControlEvents:UIControlEventTouchUpInside];

    CGFloat left = DEVICE_WIDTH - FitScreen(40);
    //前进按钮
    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardBtn.frame = CGRectMake(left, 0, FitScreen(40), FitScreen(40));
    [forwardBtn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    [_bottomView addSubview:forwardBtn];
    [forwardBtn addTarget:self action:@selector(clickToForward:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma - mark 事件处理

/**
 *  更新问题选择结果
 *
 *  @param type   问题类型
 *  @param result 问题结果dicitonary
 */
- (void)updateQuestionType:(QUESTIONTYPE)type
                    result:(NSDictionary *)result
{
    NSString *key = @"";
    if (type == QUESTIONTYPE_SEX) {
        key = Q_SEX;
    }else if (type == QUESTIONTYPE_AGE){
        key = Q_AGE;
    }else if (type == QUESTIONTYPE_HEIHGT){
        key = Q_HEIGHT;
    }else if (type == QUESTIONTYPE_WEIGHT){
        key = Q_WEIGHT;
    }else if (type == QUESTIONTYPE_OTHER){
        
    }
    
    [_questionDictionary setObject:result[@"result"] forKey:key];
    
    NSLog(@"---%@",_questionDictionary);
    
}

- (void)clickToSelectSex:(UIButton *)sender
{
    
    int tag = (int)sender.tag - 100;
    _selectedGender = tag == 1 ? Gender_Girl : Gender_Boy;//记录选择性别
    
    [self updateQuestionType:QUESTIONTYPE_SEX result:@{@"result":[NSNumber numberWithInt:tag]}];
    
    UIView *currentView = _view_sex;
    UIView *toView = [self configItemWithQuestionId:2 forward:YES];//下一个问题id 2 年龄
    [self swapView:currentView ToView:toView forward:YES];
    [self prepareBottom];
}


/**
 *  返回上一步
 *
 *  @param sender
 */
- (void)clickToLast:(UIButton *)sender
{
//    __weak typeof(self)weakSelf = self;
    
    if (_questionId == 2) { //年龄
        
        //跳性别
        UIView *currentView = _view_Age;
        UIView *toView = [self configItemWithQuestionId:1 forward:NO];
        [self swapView:currentView ToView:toView forward:NO];
        
    }else if (_questionId == 3) //身高
    {
        //跳年龄
        UIView *currentView = _view_Height;
        UIView *toView = [self configItemWithQuestionId:2 forward:NO];
        [self swapView:currentView ToView:toView forward:NO];
        
    }else if (_questionId == 4) //体重
    {
        //跳身高
        UIView *currentView = _view_Weight;
        UIView *toView = [self configItemWithQuestionId:3 forward:NO];
        [self swapView:currentView ToView:toView forward:NO];
        
    }else if (_questionId >= 5){
        
        //    //test
        ////    NSArray *images = @[[UIImage imageNamed:@"5_1"],
        ////                        [UIImage imageNamed:@"5_2"]];
        //
        //    NSArray *images = @[[UIImage imageNamed:@"9_1"],
        //                        [UIImage imageNamed:@"9_2"],
        //                        [UIImage imageNamed:@"9_3"]];
        //
        ////    NSArray *images = @[[UIImage imageNamed:@"17_1"],
        ////                        [UIImage imageNamed:@"17_2"],
        ////                        [UIImage imageNamed:@"17_3"],
        ////                        [UIImage imageNamed:@"17_4"]];
        //
        ////    NSArray *images = @[[UIImage imageNamed:@"27_1"],
        ////                        [UIImage imageNamed:@"27_2"],
        ////                        [UIImage imageNamed:@"27_3"],
        ////                        [UIImage imageNamed:@"27_4"],
        ////                        [UIImage imageNamed:@"27_5"]];
        //
        //    LQuestionView *quetionView = [[LQuestionView alloc]initQuestionViewWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - FitScreen(40)) answerImages:images quesitonId:@"5" questionTitle:@"吸烟是否≥15支/日？" initNum:0 resultBlock:^(QUESTIONTYPE type, id object, NSDictionary *result) {
        //        
        //    } mulSelect:YES];
        //    [self.view addSubview:quetionView];
        //    
        //    [self prepareBottom];
        //    
        //    return;
    }

}

/**
 *  前进一步
 *
 *  @param sender
 */

- (void)clickToForward:(UIButton *)sender
{
//    __weak typeof(self)weakSelf = self;
    
    
    //首先判断是否可以前进
    LQuestionView *currentQuestionView = (LQuestionView *)_currentView;
    if (![currentQuestionView enableForward]) {
        
        [LTools showMBProgressWithText:@"您还没有回答问题" addToView:self.view];
        
        return;
    }
    
    if (_questionId == 2) { //年龄
        
        //跳身高
        UIView *currentView = _view_Age;
        UIView *toView = [self configItemWithQuestionId:3 forward:YES];
        [self swapView:currentView ToView:toView forward:YES];
        
    }else if (_questionId == 3) //身高
    {
        //跳身高
        UIView *currentView = _view_Height;
        UIView *toView = [self configItemWithQuestionId:4 forward:YES];
        [self swapView:currentView ToView:toView forward:YES];
        
    }else if (_questionId == 4) //体重
    {
        CGFloat weight = [[_questionDictionary objectForKey:Q_WEIGHT] floatValue];
        CGFloat height = [[_questionDictionary objectForKey:Q_HEIGHT] floatValue];
        
        NSLog(@"result %@",_questionDictionary);
        NSLog(@"BMI : %.2f",BMI(weight, height));
        
        //需要切换组合
        
        NSString *groupOne_answerString = [self groupOneAnswerstring];
        groupOne_answerString = @"10100000001";
        
        int nextGroupId = [self swapNextGroupWithGroupId:_groupId answerString:groupOne_answerString];
        
        if (nextGroupId <= 0) { //表示结束了,不需要回答下个组合问题了
            
            NSString *g_name = [[DBManager shareInstance]queryGroupNameById:nextGroupId];
            NSString *text = [NSString stringWithFormat:@"组合结束 %@",g_name];
            
            NSLog(@"%@",g_name);
            
            [LTools showMBProgressWithText:text addToView:self.view];
            
            
            return;
        }
        
        //获取问题id
        int index = 0;
        int questionId = [self swapQuestionIdAtIndex:index forGroupId:nextGroupId];
        //记录当前是组合中第几个问题
        [self updateQuestionIndex:index forGroupId:nextGroupId];

        
        UIView *currentView = _view_Weight;
        UIView *toView = [self configItemWithQuestionId:questionId forward:YES];
        
        [self swapView:currentView ToView:toView forward:YES];
        
    }else if (_questionId >= 5)
    {
        //首先判断是否切换组合或者本组合内切换问题
        
        NSArray *questions = [_questionDictionary objectForKey:NSStringFromInt(_groupId)];
        int count = (int)questions.count;//当前组合问题个数
        
        if (count == 0) {
            
            NSLog(@"该组合没有问题选项");
            
            return;
        }
        
        //当前第几个问题
        int index = [self questionIndexForGroupId:_groupId];
        
        
        UIView *currentView = _currentView;
        UIView *toView;
        int questionId = 0;
        if (index == count - 1) { //已经是组合最后一个了
            
            //切换下一个组合
            
            NSString *key = [NSString stringWithFormat:@"answeString_group_%d",_groupId];
            NSString *answerString = [_questionDictionary objectForKey:key];
            //需要切换组合
            int nextGroupId = [self swapNextGroupWithGroupId:_groupId answerString:answerString];
            
            if (nextGroupId <= 0) { //表示结束了,不需要回答下个组合问题了
                
                NSString *g_name = [[DBManager shareInstance]queryGroupNameById:nextGroupId];
                NSString *text = [NSString stringWithFormat:@"组合结束 %@",g_name];
                
                NSLog(@"%@",g_name);
                
                [LTools showMBProgressWithText:text addToView:self.view];
                
                
                return;
            }
            
            //获取问题id
            int index = 0;
            questionId = [self swapQuestionIdAtIndex:index forGroupId:nextGroupId];
            //记录当前是组合中第几个问题
            [self updateQuestionIndex:index forGroupId:nextGroupId];
            
            
        }else
        {
            //当前组合 -- 切换问题
            
            //需要拼接组合的答案二进制串
            NSString *key = [NSString stringWithFormat:@"answeString_group_%d",_groupId];
            
            NSMutableString *g_answerString = [NSMutableString string];
            NSString *string = [_questionDictionary objectForKey:key];
            if (string) {
                [g_answerString appendString:string];
            }
            NSString *answerString = [currentQuestionView optionsSelectedState];
            [g_answerString appendString:answerString];
            
            //记录组合 答案拼接串
            [_questionDictionary setObject:g_answerString forKey:key];
            
            //更新index
            index ++;
            [self updateQuestionIndex:index forGroupId:_groupId];
    
            questionId = [[questions objectAtIndex:index] intValue];//获取问题id
        }
        
        //问题view
        toView = [self configItemWithQuestionId:questionId forward:YES];

        [self swapView:currentView ToView:toView forward:YES];
        
    }else
    {
        
        
        
    }
}

#pragma - mark 控制组合切换和问题切换

/**
 *  切换组合
 */
- (int)swapNextGroupWithGroupId:(int)groupId
                   answerString:(NSString *)answerString
{
    
    //判断是否有下个组合,还是说已经问答完毕 ？
    
    
    int nextGroupId = [[DBManager shareInstance]queryNextGroupIdByGroupId:groupId answerString:answerString];
    NSLog(@"nextGroupId %d",nextGroupId);
    
    if (groupId > 0) {
        _groupId = nextGroupId;//记录当前groupId
    }
    
    //下个组合问题ids
    NSArray *questions = [[DBManager shareInstance]queryQuestionIdsByGroupId:nextGroupId];
    
    if (questions.count > 0) {
        [_questionDictionary setObject:questions forKey:NSStringFromInt(nextGroupId)];//记录组合对应的问题ids
    }else
    {
        NSLog(@"逗我呢 %d 对应问题id 为空",nextGroupId);
    }
    
    
    return nextGroupId;
}

/**
 *  获取下一个问题id
 *
 *  @param q_index 问题下标
 *  @param groupId 组合id
 *
 *  @return 问题id
 */
- (int)swapQuestionIdAtIndex:(int)q_index
                  forGroupId:(int)groupId
{
    //记录当前是组合中第几个问题
    int index = 0;
    [self updateQuestionIndex:q_index forGroupId:groupId];
    
    NSArray *questions = [_questionDictionary objectForKey:NSStringFromInt(groupId)];
    int questionId = [[questions objectAtIndex:index] intValue];//获取问题id
    _questionId = questionId;
    return questionId;
}


/**
 *  更新当前组合回答问题的小标（判断是组合中第几个问题）
 *
 *  @param index   下标
 *  @param groupId 组合id
 */
- (void)updateQuestionIndex:(int)q_index
                 forGroupId:(int)groupId
{
    NSString *key = [NSString stringWithFormat:@"q_index_%d",groupId];//定义key
    [_questionDictionary setObject:NSStringFromInt(q_index) forKey:key];
}

/**
 *  获取当前问题所在组合的下标
 *
 *  @param groupId 组合id
 *
 *  @return
 */
- (int)questionIndexForGroupId:(int)groupId
{
    NSString *key = [NSString stringWithFormat:@"q_index_%d",groupId];//定义key
    
    int index = [[_questionDictionary objectForKey:key]intValue];//当前第几个问题
    
    return index;
}

#pragma - mark 控制页面切换

/**
 *  根据问题id获取对应问题view
 *
 *  @param questionId 问题id
 *  @param forward 是否是前进
 *
 *  @return view
 */
- (UIView *)configItemWithQuestionId:(NSInteger)questionId
                             forward:(BOOL)forward
{
    
    _questionId = (int)questionId;//记录当前问题id
    
    NSLog(@"questionId: %d - %d",_groupId,_questionId);
    
    UIView *view = nil;
    __weak typeof(self)weakSelf = self;

    if (questionId == 1) {
        
        if (forward) {
            [self prepareBottom];
        }else
        {
            [_bottomView removeFromSuperview];
            _bottomView = nil;
        }
        //性别
        _view_sex = [self createSexViewWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
        [self.view addSubview:_view_sex];
        view = _view_sex;
        
    }else if (questionId == 2){
        //年龄
        
        //设置初始值
        int age = [[_questionDictionary objectForKey:Q_AGE]intValue];
        if (age > 0) {
            [_view_Age setInitValue:NSStringFromInt(age)];
        }
        
        Gender gender = [[_questionDictionary objectForKey:Q_SEX]intValue] == 1 ? Gender_Girl : Gender_Boy;
        _view_Age = [[LQuestionView alloc]initAgeViewWithFrame:CGRectMake(forward ? DEVICE_WIDTH :0,  0, DEVICE_WIDTH, DEVICE_HEIGHT - FitScreen(40)) gender:gender initNum:age resultBlock:^(QUESTIONTYPE type, id object, NSDictionary *result) {
            
            [weakSelf updateQuestionType:type result:result];
        }];
        _view_Age.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_view_Age];
        
        
        view = _view_Age;
        
    }else if (questionId == 3){
        //身高
        
        //设置初始值
        int height = [[_questionDictionary objectForKey:Q_HEIGHT]intValue];
        if (height > 0) {
            [_view_Age setInitValue:NSStringFromInt(height)];
        }
        _view_Height = [[LQuestionView alloc]initHeightViewWithFrame:CGRectMake(forward ? DEVICE_WIDTH : 0,0, DEVICE_WIDTH, DEVICE_HEIGHT - FitScreen(40)) gender:_selectedGender initNum:height resultBlock:^(QUESTIONTYPE type, id object, NSDictionary *result) {
            
            [weakSelf updateQuestionType:type result:result];
        }];
        _view_Height.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_view_Height];
        
        view = _view_Height;
        
    }else if (questionId == 4){
        //体重
        
        //设置初始值
        int weight = [[_questionDictionary objectForKey:Q_WEIGHT]intValue];
        if (weight > 0) {
            [_view_Age setInitValue:NSStringFromInt(weight)];
        }
        _view_Weight = [[LQuestionView alloc]initWeightViewWithFrame:CGRectMake(forward ? DEVICE_WIDTH : 0,0, DEVICE_WIDTH, DEVICE_HEIGHT - FitScreen(40)) gender:_selectedGender initNum:weight resultBlock:^(QUESTIONTYPE type, id object, NSDictionary *result) {
            [weakSelf updateQuestionType:type result:result];
        }];
        _view_Weight.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_view_Weight];
        
        view = _view_Weight;
        
    }else if (questionId >= 5){
        
        //性别、年龄、身高、体重其他的问题
        
        QuestionModel *aModel = [[DBManager shareInstance]queryQuestionById:(int)questionId];
        
        NSArray *options = [[DBManager shareInstance]queryOptionsIdsByQuestionId:(int)questionId];
        int optionsNum = (int)[options count];
        NSMutableArray *images_arr = [NSMutableArray arrayWithCapacity:optionsNum];
        
        //获取问题图片
        for (int i = 0; i < optionsNum; i ++) {
            NSString *imageName = [NSString stringWithFormat:@"%d_%d",(int)questionId,i + 1];
            UIImage *image = [UIImage imageNamed:imageName];
            if (image) {
                [images_arr addObject:image];
            }
        }
        
        LQuestionView *quetionView = [[LQuestionView alloc]initQuestionViewWithFrame:CGRectMake(forward ? DEVICE_WIDTH : 0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - FitScreen(40)) answerImages:images_arr quesitonId:NSStringFromInt(aModel.questionId) questionTitle:aModel.questionName initNum:0 resultBlock:^(QUESTIONTYPE type, id object, NSDictionary *result) {
            
        } mulSelect:YES];
        [self.view addSubview:quetionView];
        
        view = quetionView;
    }
    

    return view;
}

/**
 *  控制view的切换动画
 *
 *  @param currentView 当前显示view
 *  @param toView     下一个view
 *  @param forward    是否是前进
 */
- (void)swapView:(UIView *)currentView
          ToView:(UIView *)toView
         forward:(BOOL)forward
{
    __weak typeof(self)weakSelf = self;
    
    //记录当前view
    _currentView = toView;
    
    //前进
    if (forward) {
        [self.view bringSubviewToFront:toView];
        [UIView animateWithDuration:0.3 animations:^{
           
            toView.left = 0.f; //左移动
        } completion:^(BOOL finished) {
            if (finished) {
                [weakSelf removeView:currentView];
            }
        }];
    }else
    {
        [self.view insertSubview:currentView aboveSubview:toView];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            currentView.left = DEVICE_WIDTH; //右移动
        } completion:^(BOOL finished) {
            
            if (finished) {
                [weakSelf removeView:currentView];
            }
        }];
    }
}

- (void)removeView:(UIView *)view
{
    [view removeFromSuperview];
    view = nil;
}

#pragma - mark 问题组合(1)结果处理


/**
 *  获取组合id为 1 时的答案二级制串
 *
 *  @return 二进制串
 */
- (NSString *)groupOneAnswerstring
{
    //获取组合id为1时的答案二级制串
    NSMutableString *temp = [NSMutableString string];
    int sex = [[_questionDictionary objectForKey:Q_SEX]intValue];
    if (sex == Gender_Girl) {
        [temp appendFormat:@"01"];
    }else
    {
        [temp appendFormat:@"10"];
    }
    int age = [[_questionDictionary objectForKey:Q_AGE]intValue];
    [temp appendString:[self ageString:age]];
    
    int height = [[_questionDictionary objectForKey:Q_HEIGHT]intValue];
    int weight = [[_questionDictionary objectForKey:Q_WEIGHT]intValue];
    [temp appendString:[self BMIString:BMI(weight, height)]];
    
    return temp;
}

/**
 *  获取年龄二进制串
 *
 *  @param age 年龄
 *
 *  @return
 */
- (NSString *)ageString:(int)age
{
    NSMutableString *temp = [[NSMutableString alloc]initWithString:@"000000"];//几个范围几个0
    int index = 0;
    
    //6个时间范围
    if (age <= 30) {
        index = 0;
    }else if (age > 30 && age <= 40){
        index = 1;
    }else if (age > 40 && age <= 50){
        index = 2;
    }else if (age > 50 && age <= 60){
        index = 3;
    }else if (age > 60 && age <= 70){
        index = 4;
    }else if (age > 70){
        index = 5;
    }
    [temp replaceCharactersInRange:NSMakeRange(index, 1) withString:@"1"];
    return temp;
}


- (NSString *)BMIString:(int)BMI
{
    NSMutableString *temp = [[NSMutableString alloc]initWithString:@"000"];//几个范围几个0
    int index = 0;
    
    //3个BMI范围
    
    if (BMI < 19.5) {
        index = 0;
        
    }else if (BMI > 19.5 && BMI <= 24) //实际情况 小于等于24都属于一个范围
    {
        index = 0;
        
    }else if (BMI > 24 && BMI <= 27.9)
    {
        index = 1;
        
    }else if (BMI >= 28)
    {
        index = 2;
    }
    [temp replaceCharactersInRange:NSMakeRange(index, 1) withString:@"1"];
    return temp;
}


@end
