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
#import "IgnoreConditionModel.h"
#import "OptionModel.h"//选项model
#import "RecommendMedicalCheckController.h"

#define Q_AGE @"age" //年龄
#define Q_WEIGHT @"weight" //体重
#define Q_HEIGHT @"height" //身高
#define Q_SEX @"sex" //性别

#define kCurrentTag 1000
#define kNextTag 1001
#define kLastTag 1002

#define Q_RESULT @"questionResult" //最终答案结果am等

@interface PersonalCustomViewController ()<UIAlertViewDelegate>
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
    NSMutableArray *_groupSortArray;//组合id排序
    NSString *_jsonString;//最终结果json串
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
    _groupSortArray = [NSMutableArray array];
    _groupId = 0;//初始化,第一个组合不能获取到组合id,默认为0
    [_groupSortArray addObject:NSStringFromInt(_groupId)];
    
    //下个组合问题ids
    NSArray *questions = [[DBManager shareInstance]queryQuestionIdsByGroupId:1];
    if (questions.count > 0) {
        [_questionDictionary setObject:questions forKey:NSStringFromInt(0)];//记录组合对应的问题ids
    }

    //性别
    _view_sex = [self createSexViewWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [self.view addSubview:_view_sex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 网络请求



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
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"tuichu"] forState:UIControlStateNormal];
    [view_sex addSubview:closeBtn];
    closeBtn.frame = CGRectMake(0, 20, 44, 44);
    [closeBtn addTarget:self action:@selector(clickToClose) forControlEvents:UIControlEventTouchUpInside];
    
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
 *  跳转至个性化定制结果页
 */
- (void)pushToCustomizationResult
{
    RecommendMedicalCheckController *recommend = [[RecommendMedicalCheckController alloc]init];
    recommend.jsonString = _jsonString;
    recommend.lastViewController = self.navigationController.topViewController;
//    [recommend.lastViewController.navigationController popViewControllerAnimated:NO];
    
    [recommend.lastViewController.navigationController pushViewController:recommend animated:YES];
}

/**
 *  点击关闭个性化定制
 */
- (void)clickToClose
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定退出个性化定制？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
}

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
        
        UIView *currentView = _currentView;
        UIView *toView;
        //组合内上一个问题
        //判断是否是组合第一个问题
        
        //首先判断是否切换组合或者本组合内切换问题
        
        NSArray *questions = [_questionDictionary objectForKey:NSStringFromInt(_groupId)];
        int count = (int)questions.count;//当前组合问题个数
        int questionId = 0;
        //当前第几个问题
        int index = [self questionIndexForGroupId:_groupId];
        
        if (index == 0) { //第一个问题,要切换组合
            //先移除当前组合
            [_questionDictionary removeObjectForKey:NSStringFromInt(_groupId)];
            [_groupSortArray removeObject:NSStringFromInt(_groupId)];
            int lastGroupId = [[_groupSortArray lastObject] intValue];
            _groupId = lastGroupId;
            
            //获取问题id
            
            //下个组合问题ids
            questions = [_questionDictionary objectForKey:NSStringFromInt(lastGroupId)];
            count = (int)questions.count;//当前组合问题个数

            index = count - 1;//最后一个开始
            questionId = [self swapQuestionIdAtIndex:index forGroupId:lastGroupId];
            //记录当前是组合中第几个问题
            [self updateQuestionIndex:index forGroupId:lastGroupId];
            
            toView = [self configItemWithQuestionId:questionId forward:NO];
        }else
        {
            //获取问题id
            index --;//最后一个开始
            questionId = [self swapQuestionIdAtIndex:index forGroupId:_groupId];
            //记录当前是组合中第几个问题
            [self updateQuestionIndex:index forGroupId:_groupId];
            
            toView = [self configItemWithQuestionId:questionId forward:NO];
        }
        
        //切换至上一个组合
        
        [self swapView:currentView ToView:toView forward:NO];

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
        
        //第一个问题组合不能确定组合id,问题一样也不能保证组合id一样
        
        NSString *groupOne_answerString = [self groupOneAnswerstring];
        
        //test
//        groupOne_answerString = @"10100000100";//跳转至组合2
        
        int nextGroupId = [self swapNextGroupWithGroupId:_groupId answerString:groupOne_answerString];
        
        if (nextGroupId <= 0) { //表示结束了,不需要回答下个组合问题了
            
            [self actionForFinishQuestionWithGroupId:nextGroupId];
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
            
            NSLog(@"切换组合------%@",_questionDictionary);

            //需要切换到下一个组合
            
            int lastGroupId = _groupId;//暂时记录上一个组合id
            
            NSString *answerString = [self answerStringForGroupId:lastGroupId];
            int nextGroupId = [self swapNextGroupWithGroupId:lastGroupId answerString:answerString];
            
            if (nextGroupId <= 0) { //表示结束了,不需要回答下个组合问题了
                [self actionForFinishQuestionWithGroupId:nextGroupId];
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

/**
 *  记录每个问题的选项选择状态
 *
 *  @param state      选择状态
 *  @param optionId   选项id
 *  @param questionId 问题id
 *  @param groupId    组合id
 */
- (void)updateOptionState:(int)state
             withOptionId:(int)optionId
           withQuestionId:(int)questionId
               forGroupId:(int)groupId
{
    /**
     *  记录问题选项选择状态
     */
        NSString *key = [NSString stringWithFormat:@"answer_group_%d_question_%d_option_%d",groupId,(int)questionId,optionId];
        [_questionDictionary setObject:[NSNumber numberWithInt:state] forKey:key];
}

/**
 *  获取选项选择状态
 *
 *  @param optionId   选项id
 *  @param questionId 问题id
 *  @param groupId    组合id
 */
- (int)optionStateWithOptionId:(int)optionId
                withQuestionId:(int)questionId
                    forGroupId:(int)groupId
{
    NSString *key = [NSString stringWithFormat:@"answer_group_%d_question_%d_option_%d",groupId,(int)questionId,optionId];
    
    int state = [[_questionDictionary objectForKey:key] intValue];
    
    return  state;
}

/**
 *  记录每个问题的答案二进制串
 *
 *  @param answerString 答案串
 *  @param questionId   问题id
 *  @param groupId      对应组合id
 */
- (void)updateQuestionAnswertring:(NSString *)answerString
                           withQuestionId:(int)questionId
                               forGroupId:(int)groupId
{
    /**
     *  记录问题答案
     */
    if (answerString && answerString.length > 0) {
        NSString *key = [NSString stringWithFormat:@"answer_group_%d_question_%d",groupId,(int)questionId];
        [_questionDictionary setObject:answerString forKey:key];
    }
}

/**
 *  更新组合 对应的答案二进制串
 *
 *  @param groupId 组合id
 */
- (void)updateAnswerstringForId:(int)groupId
{
    //需要拼接组合的答案二进制串
    NSString *key = [NSString stringWithFormat:@"answerString_group_%d",groupId];
    NSMutableString *g_answerString = [NSMutableString string];
    NSString *string = [_questionDictionary objectForKey:key];
    if (string) {
        [g_answerString appendString:string];
    }
    
    LQuestionView *currentQuestionView = (LQuestionView *)_currentView;
    //拼接答案的时候需要考虑忽略条件
    NSString *answerString = [currentQuestionView optionsSelectedState];
    [g_answerString appendString:answerString];
    
    //记录组合 答案拼接串
    [_questionDictionary setObject:g_answerString forKey:key];
}

#pragma - mark 处理问题回答完毕--执行结束操作

- (void)actionForFinishQuestionWithGroupId:(int)groupId
{
    
//    NSString *g_name = [[DBManager shareInstance] queryGroupNameById:groupId];
//    NSString *text = [NSString stringWithFormat:@"组合结束 %@",g_name];
//    
//    NSLog(@"%@",g_name);
//    
//    if (g_name.length > 0) {
//        [_questionDictionary setObject:g_name forKeyedSubscript:Q_RESULT];//记录结果
//    }
//    
//    [LTools showMBProgressWithText:text addToView:self.view];
    
    //组合信息
    //最终结束组合id
    //n1_type+id
    
//    NSMutableDictionary *groupArray = [NSMutableArray arrayWithCapacity:_groupSortArray.count];
    
    NSMutableDictionary *groupDic = [NSMutableDictionary dictionary];
    NSMutableArray *n1_ids_array = [NSMutableArray array];
    //组合id
    for (NSString *groupId in _groupSortArray) {
        
        //单独处理组合为0情况
        if ([groupId intValue] == 0) {
            NSNumber *age = [_questionDictionary objectForKey:Q_SEX];
            NSNumber *height = [_questionDictionary objectForKey:Q_HEIGHT];
            NSNumber *weight = [_questionDictionary objectForKey:Q_WEIGHT];
            NSNumber *sex = [_questionDictionary objectForKey:Q_SEX];
            
//            NSDictionary *groupOne = @{groupId:@{Q_SEX:sex,
//                                                 Q_HEIGHT:height,
//                                                 Q_WEIGHT:weight,
//                                                 Q_AGE:age}};
//            [groupArray addObject:groupOne];
            
            [groupDic setObject:@{Q_SEX:sex,
                                  Q_HEIGHT:height,
                                  Q_WEIGHT:weight,
                                  Q_AGE:age} forKey:groupId];
            
            continue;
        }
        
        //问题
        NSArray *questions = [_questionDictionary objectForKey:groupId];
        
//        NSMutableArray *questionArray = [NSMutableArray array];
        
        NSMutableDictionary *quesitonDic = [NSMutableDictionary dictionary];
        
        for (NSString *questionId in questions) {
            
            NSArray *options = [[DBManager shareInstance]queryOptionsIdsByQuestionId:[questionId intValue]];
            
            NSMutableArray *optionsArray = [NSMutableArray arrayWithCapacity:options.count];
            
            for (NSString *optionId in options) {
                
                int state = [self optionStateWithOptionId:[optionId intValue] withQuestionId:[questionId intValue] forGroupId:[groupId intValue]];
                
                if (state == 1) {
                    
                    [optionsArray addObject:optionId];
                }
                
//                NSDictionary *option_dic = @{optionId : NSStringFromInt(state)};
//                [optionsArray addObject:option_dic];
                
                //忽略
                NSString *key = [NSString stringWithFormat:@"ignore_group_%@_question_%@_option_%@",groupId,questionId,optionId];
                NSNumber *n1_type_id = [_questionDictionary objectForKey:key];
                if (n1_type_id) {
                    
                    [n1_ids_array addObject:n1_type_id];
                }
            }
            
            //问题对应的所有选项
            
//            NSDictionary *question_dic = @{questionId : optionsArray};
//            [questionArray addObject:question_dic];
            
            [quesitonDic setObject:optionsArray forKey:questionId];
        }
        
        //组合对应所有问题
//        NSDictionary *group_dic = @{groupId:questionArray};
//        [groupArray addObject:group_dic];
        [groupDic setObject:quesitonDic forKey:groupId];
    }
    
    NSString *n1_ids = [n1_ids_array componentsJoinedByString:@","];
    n1_ids = n1_ids ? : @"";
    
    groupId = groupId > 0 ? groupId : -groupId;
    
    NSDictionary *result = @{@"group_ids":groupDic,
                             @"final_groupId":NSStringFromInt(groupId),
                             @"nq_ids":n1_ids};
    
    NSString *jsonString = [LTools JSONStringWithObject:result];
    _jsonString = jsonString;
    
    NSLog(@"result %@",jsonString);
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定提交结果" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"确定", nil];
    alert.tag = 10000;
    [alert show];
}

#pragma - mark 获取组合答案信息

- (NSString *)answerStringForGroupId:(int)groupId
{
    NSArray *questionArray = [_questionDictionary objectForKey:NSStringFromInt(groupId)];
    NSMutableString *answerString = [NSMutableString string];
    
    NSArray *ignores = [self ignoreOptionsIdWithGroupId:groupId];//获取所有忽略选项
    NSArray *ignores_n1 = [[DBManager shareInstance]queryIgnoreN1ModelForGroupId:groupId];//n+1需要忽略的条件
    
    for (NSString *q_id in questionArray) {
        
        //找到问题对应选项
        NSArray *options = [[DBManager shareInstance]queryOptionsIdsByQuestionId:[q_id intValue]];
        
        //循环找到选项对应状态
        for (NSString *optionId in options) {
            
            NSString *o_string = [NSString stringWithFormat:@"%@_%@",q_id,optionId];
            
            if (![ignores containsObject:o_string]) { //不忽略
                
                NSString *key = [NSString stringWithFormat:@"answer_group_%d_question_%d_option_%d",groupId,[q_id intValue],[optionId intValue]];
                int state = [[_questionDictionary objectForKey:key]intValue];
                
                IgnoreConditionModel *ignoreModel = [self n1TypeModelForGroupId:groupId questionId:[q_id intValue] optionId:[optionId intValue] answer:state type:1 affectNext:0 withIgnoreArray:ignores_n1];
                
                if (ignoreModel) { //需要忽略
                    
                    //把 n+1情况记录下来,需要传送给后台
                    NSString *key_ignore = [NSString stringWithFormat:@"ignore_group_%d_question_%d_option_%d",groupId,[q_id intValue],[optionId intValue]];
                    [_questionDictionary setObject:[NSNumber numberWithInt:ignoreModel.n1_id] forKey:key_ignore];
                    
                }else
                {
                    [answerString appendString:NSStringFromInt(state)];

                }
                
            }else
            {
                NSLog(@"需要忽略问题id:%@_optionId:%@",q_id,optionId);
            }
            
        }
        
    }
    NSLog(@"组合对应的答案串 %@",answerString);
    
    return answerString;
}

/**
 *  获取满足的n+1忽略条件的 n1_type_id,-1代表不忽略,大于等于0代表忽略
 *
 *  @param groupId    组合id
 *  @param questionId 问题id
 *  @param optionId   选项id
 *  @param answer     是否选中1或者0
 *  @param type       目前默认1
 *  @param affectNext 目前默认0
 *
 *  @return
 */
//- (int)n1TypeIdForGroupId:(int)groupId
//               questionId:(int)questionId
//                 optionId:(int)optionId
//                   answer:(int)answer
//                     type:(int)type
//               affectNext:(int)affectNext
//          withIgnoreArray:(NSArray *)ignoreArray
//{
//    
//    for (IgnoreConditionModel *aMode in ignoreArray) {
//        
//        if (aMode.group_id == groupId &&
//            aMode.question_id == questionId &&
//            aMode.option_id == optionId &&
//            aMode.answer == answer &&
//            aMode.type == type &&
//            aMode.affect_next == affectNext) {
//            
//            return aMode.n1_type_id;
//        }
//    }
//    
//    return -1;
//}

/**
 *  获取满足的n+1忽略条件的 model,aMode.n1_type_id为-1代表不忽略,大于等于0代表忽略
 *
 *  @param groupId    组合id
 *  @param questionId 问题id
 *  @param optionId   选项id
 *  @param answer     是否选中1或者0
 *  @param type       目前默认1
 *  @param affectNext 目前默认0
 *
 *  @return
 */
- (IgnoreConditionModel *)n1TypeModelForGroupId:(int)groupId
               questionId:(int)questionId
                 optionId:(int)optionId
                   answer:(int)answer
                     type:(int)type
               affectNext:(int)affectNext
          withIgnoreArray:(NSArray *)ignoreArray
{
    
    for (IgnoreConditionModel *aMode in ignoreArray) {
        
        if (aMode.group_id == groupId &&
            aMode.question_id == questionId &&
            aMode.option_id == optionId &&
            aMode.answer == answer &&
            aMode.type == type &&
            aMode.affect_next == affectNext) {
            
            return aMode;
        }
    }
    
    return nil;
}

/**
 *  查找组合id对应所有的忽略的选项id(问题id_选项id,如:2_1)
 *
 *  @return
 */
- (NSArray *)ignoreOptionsIdWithGroupId:(int)groupId
{
    //拼接组合答案串（需要忽略问题查找流程）
    //根据组合id 获取需要忽略的条件
    //根据忽略的条件（有多种情况，满足其一即可）找到对应的需要忽略的问题id和对应的选项
    
    NSMutableArray *ignore_array = [NSMutableArray array];
    NSArray *ignores = [[DBManager shareInstance]queryIgnoreInfoByGroupId:groupId];
    for (IgnoreConditionModel *aModel in ignores) {
        
        NSString *ignoreConditions = aModel.ignore_conditions;
        
        //该问题对应选择都忽略
        if ([ignoreConditions integerValue] == 1) {
            
            NSArray *ignoreOptions = [aModel.ignore_option_ids objectFromJSONString];
            for (NSString *optionid in ignoreOptions) {
                
                NSString *temp = [NSString stringWithFormat:@"%d_%@",aModel.question_id,optionid];
                [ignore_array addObject:temp];
            }
            
            continue;
        }
        
        NSArray *conditons = [aModel.ignore_conditions objectFromJSONString];
        
        BOOL fit_all = NO;//默认所有数组对应条件都不满足

        for (NSArray *array in conditons) { //1、遍历每个筛选条件(多个筛选条件array形式)
            
            BOOL fit_option = YES;// 本条件默认符合

            for (NSDictionary *q_dic in array) { //2、每个问题
                
                    NSString *q_id = [q_dic objectForKey:@"question_id"];
                    NSString *option_id = [q_dic objectForKey:@"option_id"];
                    NSString *anwser = [q_dic objectForKey:@"answer"];
                    
                    //实际选项状态
                    int state = [self optionStateWithOptionId:[option_id intValue] withQuestionId:[q_id intValue] forGroupId:groupId];
                    
                    if (state != [anwser intValue]) {
                        //本条件不符合
                        fit_option = NO;
                    }
                
            }
            
            if (fit_option) {
                fit_all = YES;//单个数组对应的条件都满足时,则整个条件都满足
            }
        }
        
        if (fit_all) { //需要忽略的optionId
            
            //满足条件 需要做忽略操作
            NSArray *ignoreOptions = [aModel.ignore_option_ids objectFromJSONString];
            for (NSString *optionid in ignoreOptions) {
                
                NSString *temp = [NSString stringWithFormat:@"%d_%@",aModel.question_id,optionid];
                [ignore_array addObject:temp];
            }
        }
    }
    
    return ignore_array;

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
    
    if (nextGroupId > 0) {
        _groupId = nextGroupId;//记录当前groupId
        //每次切换组合时 加上新的组合id
        [_groupSortArray addObject:NSStringFromInt(nextGroupId)];
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
    [self updateQuestionIndex:q_index forGroupId:groupId];
    
    NSArray *questions = [_questionDictionary objectForKey:NSStringFromInt(groupId)];
    int questionId = [[questions objectAtIndex:q_index] intValue];//获取问题id
    _questionId = questionId;
    return questionId;
}


/**
 *  更新当前组合回答问题的下标（判断是组合中第几个问题）
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
        
        //记录特殊选项
        int specialId = aModel.special_option_id;
        
        NSArray *options = [[DBManager shareInstance]queryOptionsIdsByQuestionId:(int)questionId];
        int optionsNum = (int)[options count];
        
        NSMutableArray *options_arr = [NSMutableArray array];
        //获取选项和选项对应图片
        for (int i = 0; i < optionsNum; i ++) {
            NSString *imageName = [NSString stringWithFormat:@"%d_%d",(int)questionId,i + 1];
            UIImage *image = [UIImage imageNamed:imageName];
            if (image) {

                int optionId = [options[i] intValue];
                OptionModel *option = [[OptionModel alloc]initWithQuestionId:(int)questionId optionId:optionId optionImage:image];
                if (optionId == specialId) {
                    
                    option.isSepecial = YES;//标记特殊性
                }
                [options_arr addObject:option];
            }
        }
        
        //需要拼接组合的答案二进制串
        
        NSString *key = [NSString stringWithFormat:@"answer_group_%d_question_%d",_groupId,(int)questionId];
        NSString *initAnswerString = [_questionDictionary objectForKey:key];

        LQuestionView *quetionView = [[LQuestionView alloc]initQuestionViewWithFrame:CGRectMake(forward ? DEVICE_WIDTH : 0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - FitScreen(40)) answerImages:options_arr quesitonId:NSStringFromInt(aModel.questionId) questionTitle:aModel.questionName initAnswerString:initAnswerString resultBlock:^(QUESTIONTYPE type, id object, NSDictionary *result) {
            
            NSString *answerString = result[QUESTION_ANSERSTRING];
            [weakSelf updateQuestionAnswertring:answerString withQuestionId:aModel.questionId forGroupId:_groupId];//针对问题记录
            
            NSArray *optionStates = [result objectForKey:QUESTION_OPTION_IDS];
            for (NSDictionary *aDic in optionStates) {
                
                int optionid = [[[aDic allKeys]lastObject] intValue];
                int state = [[[aDic allValues]lastObject]intValue];
                
                [weakSelf updateOptionState:state withOptionId:optionid withQuestionId:(int)questionId forGroupId:_groupId];//针对选项记录
            }
            
            //判断是否是单选,单选的情况下自动跳转
            if (type == QUESTIONOPTIONTYPE_SINGLE) {
                
                [weakSelf clickToForward:nil];
            }
            
        } mulSelect:aModel.select_option_type specialOptionId:specialId];
        
        [self.view addSubview:quetionView];
        
        view = quetionView;
    }
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (view == _view_sex) {
        [closeBtn setImage:[UIImage imageNamed:@"tuichu"] forState:UIControlStateNormal];
    }else
    {
        [closeBtn setImage:[UIImage imageNamed:@"tuichu_w"] forState:UIControlStateNormal];
    }
    [view addSubview:closeBtn];
    closeBtn.frame = CGRectMake(0, 20, 44, 44);
    [closeBtn addTarget:self action:@selector(clickToClose) forControlEvents:UIControlEventTouchUpInside];
    

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

#pragma - mark @protocol UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        
        if (buttonIndex == 1) {
            
            [self pushToCustomizationResult];
        }
        
        return;
    }
    
    if(buttonIndex == 1){
        
        [self leftButtonTap:nil];
    }
}


@end
