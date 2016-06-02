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

#define Q_Extension @"q_extension" //记录是否是拓展
#define Q_Extension_qid @"q_extension_qid" //拓展问题id

#define Q_ExtensionGroupId @"extension_2" //拓展问题第二部分groupId

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
    
    NSString *_questionId;//当前问题id
    int _groupId;//当前groupId
    NSMutableArray *_groupSortArray;//组合id排序
    NSString *_jsonString;//最终结果json串
    NSString *_extensionJsonString;//最终拓展问题结果json串

    BOOL _extensionQuestion;//是否是拓展问题
    NSMutableArray *_sortArray;//存储顺序字典情况@{@"q_extension":1,@"q_extension_qid":@"3"}
}

@property(nonatomic,retain)NSArray *extensionQuestionArray;//所有的拓展问题
@property(nonatomic,assign)Gender gender;//年龄
@property(nonatomic,assign)int age;//性别

@end

@implementation PersonalCustomViewController




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    _questionDictionary = [NSMutableDictionary dictionary];
    _groupSortArray = [NSMutableArray array];
    _groupId = 0;//初始化,第一个组合不能获取到组合id,默认为0
    [_groupSortArray addObject:NSStringFromInt(_groupId)];
    
    _sortArray = [NSMutableArray array];//存储排序情况
    
    //加拓展问题
    _extensionQuestion = NO;//默认正常问题
    
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

#pragma mark - 事件处理

/**
 *  排序加新问题
 *
 *  @param questionId 问题id
 *  @param extension  是否是拓展
 */
- (void)addSortArrayWithQuestionId:(NSInteger)questionId
                         extension:(BOOL)extension
{
    NSDictionary *dic = @{Q_Extension:[NSNumber numberWithBool:extension],
                          Q_Extension_qid:[NSNumber numberWithInteger:questionId]};
    [_sortArray addObject:dic];
}

/**
 *  移除最后一个
 */
- (void)removeSortArrayLastObject
{
    if (_sortArray.count) {
        [_sortArray removeLastObject];
    }
}

/**
 *  跳转至个性化定制结果页
 */
- (void)pushToCustomizationResult
{
    RecommendMedicalCheckController *recommend = [[RecommendMedicalCheckController alloc]init];
    recommend.jsonString = _jsonString;
    recommend.extensionString = _extensionJsonString;
    recommend.vouchers_id = self.vouchers_id;
    recommend.hidesBottomBarWhenPushed = YES;
    [self.lastViewController.navigationController popViewControllerAnimated:NO];
    [self.lastViewController.navigationController pushViewController:recommend animated:YES];
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
}

- (void)clickToSelectSex:(UIButton *)sender
{
    
    int tag = (int)sender.tag;
    _selectedGender = (tag == 100) ? Gender_Boy : Gender_Girl;//记录选择性别
    
    [self updateQuestionType:QUESTIONTYPE_SEX result:@{@"result":[NSNumber numberWithInt:_selectedGender]}];
    
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
    
    if ([_questionId intValue] == 2) { //年龄
        
        //跳性别
        UIView *currentView = _view_Age;
        UIView *toView = [self configItemWithQuestionId:1 forward:NO];
        [self swapView:currentView ToView:toView forward:NO];
        
    }else if ([_questionId intValue] == 3) //身高
    {
        //跳年龄
        UIView *currentView = _view_Height;
        UIView *toView = [self configItemWithQuestionId:2 forward:NO];
        [self swapView:currentView ToView:toView forward:NO];
        
    }else if ([_questionId intValue] == 4) //体重
    {
        //跳身高
        UIView *currentView = _view_Weight;
        UIView *toView = [self configItemWithQuestionId:3 forward:NO];
        [self swapView:currentView ToView:toView forward:NO];
        
    }else if ([_questionId intValue] >= 5 || [_questionId hasPrefix:Q_Extension]){
        
        UIView *currentView = _currentView;
        UIView *toView;
        
        //组合内上一个问题
        //判断是否是组合第一个问题
        
        //首先判断是否切换组合或者本组合内切换问题
        
        NSArray *questions = [_questionDictionary objectForKey:NSStringFromInt(_groupId)];
        int count = (int)questions.count;//当前组合问题个数
        NSString *questionId = @"";
        //当前第几个问题
        int index = [self questionIndexForGroupId:NSStringFromInt(_groupId)];
        
        if (index == 0) { //第一个问题,要切换组合
            
            DDLOG(@"切换组合");
            //先移除当前组合
            [_questionDictionary removeObjectForKey:NSStringFromInt(_groupId)];
            [_groupSortArray removeObject:NSStringFromInt(_groupId)];
            [self removeQuestionIndexForGroupId:_groupId];//移除组合问题下标记录
            
            int lastGroupId = [[_groupSortArray lastObject] intValue];
            _groupId = lastGroupId;
            
            //获取问题id
            
            //下个组合问题ids
            questions = [_questionDictionary objectForKey:NSStringFromInt(lastGroupId)];
            count = (int)questions.count;//当前组合问题个数

            index = count - 1;//最后一个开始
            questionId = [self swapQuestionIdAtIndex:index forGroupId:lastGroupId];
            //记录当前是组合中第几个问题
            [self updateQuestionIndex:index forGroupId:NSStringFromInt(lastGroupId)];
            
            //拓展问题
            if ([questionId hasPrefix:Q_Extension]) {
                
                NSMutableString *temp = [NSMutableString stringWithString:questionId];
                [temp replaceOccurrencesOfString:[NSString stringWithFormat:@"%@_",Q_Extension] withString:@"" options:0 range:NSMakeRange(0, questionId.length)];
                int q_id = [temp intValue];
                toView = [self configExtensionItemWithQuestionId:q_id forward:NO];
            }else
            {
                toView = [self configItemWithQuestionId:[questionId intValue] forward:NO];
            }
            
        }else
        {
            //获取问题id
            index --;//最后一个开始
            questionId = [self swapQuestionIdAtIndex:index forGroupId:_groupId];
            //记录当前是组合中第几个问题
            [self updateQuestionIndex:index forGroupId:NSStringFromInt(_groupId)];
            
            //拓展问题
            if ([questionId hasPrefix:Q_Extension]) {
                
                NSMutableString *temp = [NSMutableString stringWithString:questionId];
                [temp replaceOccurrencesOfString:[NSString stringWithFormat:@"%@_",Q_Extension] withString:@"" options:0 range:NSMakeRange(0, questionId.length)];
                int q_id = [temp intValue];
                toView = [self configExtensionItemWithQuestionId:q_id forward:NO];
            }else
            {
                toView = [self configItemWithQuestionId:[questionId intValue] forward:NO];
            }
        }
        
        //切换至上一个组合
        
        [self swapView:currentView ToView:toView forward:NO];

    }
    
    DDLOG(@"---->%@",_questionDictionary);
    
    //移除顺序记录
    [self removeSortArrayLastObject];

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
    
    if ([_questionId intValue] == 2) { //年龄
        
        //跳身高
        UIView *currentView = _view_Age;
        UIView *toView = [self configItemWithQuestionId:3 forward:YES];
        [self swapView:currentView ToView:toView forward:YES];
        
    }else if ([_questionId intValue] == 3) //身高
    {
        //跳身高
        UIView *currentView = _view_Height;
        UIView *toView = [self configItemWithQuestionId:4 forward:YES];
        [self swapView:currentView ToView:toView forward:YES];
        
    }else if ([_questionId intValue] == 4) //体重
    {
        
//        CGFloat weight = [[_questionDictionary objectForKey:Q_WEIGHT] floatValue];
//        CGFloat height = [[_questionDictionary objectForKey:Q_HEIGHT] floatValue];
//        
//        DDLOG(@"result %@",_questionDictionary);
//        DDLOG(@"BMI : %.2f",BMI(weight, height));
        
        //需要切换组合
        //第一个问题组合不能确定组合id,问题一样也不能保证组合id一样
        
        NSString *groupOne_answerString = [self groupOneAnswerstring];
        
        int nextGroupId = [self swapNextGroupWithGroupId:_groupId answerString:groupOne_answerString extension:YES];
        
        if (nextGroupId <= 0) { //表示结束了,不需要回答下个组合问题了
            
            [self actionForFinishQuestionWithGroupId:nextGroupId];
            return;
        }
        
        //获取问题id
        int index = 0;
        NSString *questionId = [self swapQuestionIdAtIndex:index forGroupId:nextGroupId];
        //记录当前是组合中第几个问题
        [self updateQuestionIndex:index forGroupId:NSStringFromInt(nextGroupId)];
        
        UIView *currentView = _view_Weight;
        
        UIView *toView = nil;

        //拓展问题
        if ([questionId hasPrefix:Q_Extension]) {
            
            NSMutableString *temp = [NSMutableString stringWithString:questionId];
            [temp replaceOccurrencesOfString:[NSString stringWithFormat:@"%@_",Q_Extension] withString:@"" options:0 range:NSMakeRange(0, questionId.length)];
            int q_id = [temp intValue];
            toView = [self configExtensionItemWithQuestionId:q_id forward:YES];
        }else
        {
            toView = [self configItemWithQuestionId:[questionId intValue] forward:YES];
        }
        
        [self swapView:currentView ToView:toView forward:YES];
        
    }else if ([_questionId intValue] >= 5 || [_questionId hasPrefix:Q_Extension])
    {
        //首先判断是否切换组合或者本组合内切换问题
        NSArray *questions = [_questionDictionary objectForKey:NSStringFromInt(_groupId)];
        int count = (int)questions.count;//当前组合问题个数
        
        if (count == 0) {
            
            DDLOG(@"该组合没有问题选项");
            return;
        }
        
        //当前第几个问题
        int index = [self questionIndexForGroupId:NSStringFromInt(_groupId)];
        UIView *currentView = _currentView;
        UIView *toView;
        NSString *questionId = @"";
        if (index == count - 1) { //已经是组合最后一个了
            
            DDLOG(@"切换组合------%@",_questionDictionary);

            //需要切换到下一个组合
            
            int lastGroupId = _groupId;//暂时记录上一个组合id
            
            NSString *answerString = [self answerStringForGroupId:lastGroupId];
            int nextGroupId = [self swapNextGroupWithGroupId:lastGroupId answerString:answerString extension:NO];
            
            if (nextGroupId <= 0) { //表示结束了,不需要回答下个组合问题了
                [self actionForFinishQuestionWithGroupId:nextGroupId];
                return;
            }
            
            //获取问题id
            int index = 0;
            questionId = [self swapQuestionIdAtIndex:index forGroupId:nextGroupId];
            
            if (!questionId) {
                [LTools showMBProgressWithText:@"抱歉您的情况已超出海马认知范围!" addToView:self.view];
                return;
            }
            
            //拓展问题
            if ([questionId hasPrefix:Q_Extension]) {
                
                NSMutableString *temp = [NSMutableString stringWithString:questionId];
                [temp replaceOccurrencesOfString:[NSString stringWithFormat:@"%@_",Q_Extension] withString:@"" options:0 range:NSMakeRange(0, questionId.length)];
                int q_id = [temp intValue];
                toView = [self configExtensionItemWithQuestionId:q_id forward:YES];
            }else
            {
                toView = [self configItemWithQuestionId:[questionId intValue] forward:YES];
            }
            //记录当前是组合中第几个问题
            [self updateQuestionIndex:index forGroupId:NSStringFromInt(nextGroupId)];
            
            
        }else
        {
            //当前组合 -- 切换问题
            
            //更新index
            index ++;
            [self updateQuestionIndex:index forGroupId:NSStringFromInt(_groupId)];
    
            questionId = [questions objectAtIndex:index];//获取问题id
            
            //拓展问题
            if ([questionId hasPrefix:Q_Extension]) {
                
                NSMutableString *temp = [NSMutableString stringWithString:questionId];
                [temp replaceOccurrencesOfString:[NSString stringWithFormat:@"%@_",Q_Extension] withString:@"" options:0 range:NSMakeRange(0, questionId.length)];
                int q_id = [temp intValue];
                toView = [self configExtensionItemWithQuestionId:q_id forward:YES];
            }else
            {
                toView = [self configItemWithQuestionId:[questionId intValue] forward:YES];
            }
        }

        [self swapView:currentView ToView:toView forward:YES];
        
    }else
    {
        
        
        
    }
    
    
}

- (void)forwardToExtension
{
    
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

/**
 *  更新拓展问题选项id串
 *
 *  @param optionidString
 */
- (void)updateExtensionQustionOptionidString:(NSString *)optionidString
                                  questionId:(NSInteger)questionid
{
    NSString *key = [NSString stringWithFormat:@"extension_questionOption_%d",(int)questionid];
    [_questionDictionary safeSetString:optionidString forKey:key];
}

/**
 *  获取拓展问题选项id串
 *
 *  @param questionid
 *
 *  @return
 */
- (NSString *)extensionQustionOptionStringWithQuestionId:(NSInteger)questionid
{
    NSString *key = [NSString stringWithFormat:@"extension_questionOption_%d",(int)questionid];
    return [_questionDictionary objectForKey:key];
}


/**
 *  拓展问题 字典组成数组
 *
 *  @return
 */
- (NSDictionary *)extensionQuestionResultDictionary
{
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    for (NSDictionary *dic in _sortArray) {
        
        BOOL extension = [dic[Q_Extension]boolValue];
        if (extension) {
            int extension_qid = [dic[Q_Extension_qid]intValue];
            NSString * optionString = [self extensionQustionOptionStringWithQuestionId:extension_qid];
            NSArray *optionArray = [optionString componentsSeparatedByString:@","];
            [temp setObject:optionArray forKey:NSStringFromInt(extension_qid)];
        }
    }
    return temp;
}

#pragma - mark 处理问题回答完毕--执行结束操作

- (void)actionForFinishQuestionWithGroupId:(int)groupId
{
    
    NSMutableDictionary *groupDic = [NSMutableDictionary dictionary];
    NSMutableArray *n1_ids_array = [NSMutableArray array];
    //组合id
    for (NSString *groupId in _groupSortArray) {
        
        //单独处理组合为0情况
        if ([groupId intValue] == 0) {
            NSNumber *age = [_questionDictionary objectForKey:Q_AGE];
            NSNumber *height = [_questionDictionary objectForKey:Q_HEIGHT];
            NSNumber *weight = [_questionDictionary objectForKey:Q_WEIGHT];
            NSNumber *sex = [_questionDictionary objectForKey:Q_SEX];
            
            [groupDic setObject:@{Q_SEX:sex,
                                  Q_HEIGHT:height,
                                  Q_WEIGHT:weight,
                                  Q_AGE:age} forKey:groupId];
            
            continue;
        }
        
        //问题
        NSArray *questions = [_questionDictionary objectForKey:groupId];
        
        NSMutableDictionary *quesitonDic = [NSMutableDictionary dictionary];
        
        for (NSString *questionId in questions) {
            
            //拓展的问题排除
            if ([questionId hasPrefix:Q_Extension]) {
                
                continue;
            }
            
            NSArray *options = [[DBManager shareInstance]queryOptionsIdsByQuestionId:[questionId intValue]];
            
            NSMutableArray *optionsArray = [NSMutableArray arrayWithCapacity:options.count];
            
            for (NSString *optionId in options) {
                
                int state = [self optionStateWithOptionId:[optionId intValue] withQuestionId:[questionId intValue] forGroupId:[groupId intValue]];
                
                if (state == 1) {
                    
                    [optionsArray addObject:optionId];
                }

                //忽略
                NSString *key = [NSString stringWithFormat:@"ignore_group_%@_question_%@_option_%@",groupId,questionId,optionId];
                NSNumber *n1_type_id = [_questionDictionary objectForKey:key];
                if (n1_type_id) {
                    
                    [n1_ids_array addObject:n1_type_id];
                }
            }
            
            //问题对应的所有选项
            
            [quesitonDic setObject:optionsArray forKey:questionId];
        }
        
        //组合对应所有问题

        [groupDic setObject:quesitonDic forKey:groupId];
    }
    
    NSString *n1_ids = [n1_ids_array componentsJoinedByString:@","];
    n1_ids = n1_ids ? : @"";
    
    groupId = groupId > 0 ? groupId : -groupId;
    
    //添加拓展参数
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result safeSetValue:groupDic forKey:@"group_ids"];
    [result safeSetValue:NSStringFromInt(groupId) forKey:@"final_groupId"];
    [result safeSetValue:n1_ids forKey:@"nq_ids"];
//    [result safeSetValue: forKey:@"e_result"];
    
    NSString *jsonString = [LTools JSONStringWithObject:result];
    NSString *extensionString = [LTools JSONStringWithObject:[self extensionQuestionResultDictionary]];
    _jsonString = jsonString;
    _extensionJsonString = extensionString;
    
    DDLOG(@"result %@",jsonString);
    DDLOG(@"extension %@",extensionString);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"个性化定制完成,是否确定提交结果" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"确定", nil];
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
            
            NSString *o_string = [NSString stringWithFormat:@"%d_%@_%@",groupId,q_id,optionId];
            
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
                DDLOG(@"需要忽略问题id:%@_optionId:%@",q_id,optionId);
            }
            
        }
        
    }
    DDLOG(@"组合对应的答案串 %@",answerString);
    
    return answerString;
}


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
 *  查找组合id对应所有的忽略的选项id(组合id_问题id_选项id,如:6_12_19)
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
                
                NSString *temp = [NSString stringWithFormat:@"%d_%d_%@",groupId,aModel.question_id,optionid];
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
                
                NSString *temp = [NSString stringWithFormat:@"%d_%d_%@",groupId,aModel.question_id,optionid];
                [ignore_array addObject:temp];
            }
        }
    }
    
    return ignore_array;

}


#pragma - mark 控制组合切换和问题切换

/**
 *  切换组合
 *
 *  @param groupId
 *  @param answerString
 *  @param extension    是否拓展问题
 *
 *  @return
 */
- (int)swapNextGroupWithGroupId:(int)groupId
                   answerString:(NSString *)answerString
                     extension:(BOOL)extension
{
    
    //判断是否有下个组合,还是说已经问答完毕 ？
    
    
    int nextGroupId = [[DBManager shareInstance]queryNextGroupIdByGroupId:groupId answerString:answerString];
    DDLOG(@"nextGroupId %d",nextGroupId);
    
    if (nextGroupId > 0) {
        _groupId = nextGroupId;//记录当前groupId
        //每次切换组合时 加上新的组合id
        [_groupSortArray addObject:NSStringFromInt(nextGroupId)];
    }
    
    //下个组合问题ids
    NSArray *questions = [[DBManager shareInstance]queryQuestionIdsByGroupId:nextGroupId];
    
    //如果拓展问题
    if (extension) {
        
        //烟、酒
        NSMutableArray *temp = [NSMutableArray array];
        
        //第一个部分 放在前面
        
        if (self.gender == Gender_Boy) {
            
            //3
            [temp addObject:[NSString stringWithFormat:@"%@_3",Q_Extension]];
            
        }else if (self.gender == Gender_Girl){
            
            if (self.age <= 45) {
                
                //1
                [temp addObject:[NSString stringWithFormat:@"%@_1",Q_Extension]];
                //2
                [temp addObject:[NSString stringWithFormat:@"%@_2",Q_Extension]];

            }
        }
        [temp addObjectsFromArray:@[questions[0],questions[1]]];//烟酒
        
        //第二部分
        
        NSArray *extensionQids = [[DBManager shareInstance]queryAllExtensionQuestionIdsWithAge:self.age];
        
        for (NSString *q_id in extensionQids) {
            [temp addObject:[NSString stringWithFormat:@"%@_%@",Q_Extension,q_id]];
        }
        
        //烟酒剩余部分
        
        for (int i = 2; i < questions.count; i ++) {
            
            [temp addObject:questions[i]];
        }
        
        questions = [NSArray arrayWithArray:temp];
    }
    
    if (questions.count > 0) {
        [_questionDictionary setObject:questions forKey:NSStringFromInt(nextGroupId)];//记录组合对应的问题ids
    }else
    {
        DDLOG(@"逗我呢 %d 对应问题id 为空",nextGroupId);
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
- (NSString *)swapQuestionIdAtIndex:(int)q_index
                  forGroupId:(int)groupId
{
    //记录当前是组合中第几个问题
    [self updateQuestionIndex:q_index forGroupId:NSStringFromInt(groupId)];
    
    NSArray *questions = [_questionDictionary objectForKey:NSStringFromInt(groupId)];
    NSString *questionId = [questions objectAtIndex:q_index];//获取问题id
    if (questionId) {
        _questionId = questionId;
    }
    return questionId;
}


/**
 *  更新当前组合回答问题的下标（判断是组合中第几个问题）
 *
 *  @param index   下标
 *  @param groupId 组合id
 */
- (void)updateQuestionIndex:(int)q_index
                 forGroupId:(NSString *)groupId
{
    NSString *key = [NSString stringWithFormat:@"q_index_%@",groupId];//定义key
    [_questionDictionary setObject:NSStringFromInt(q_index) forKey:key];
}

/**
 *  移除组合回答问题下表
 */
- (void)removeQuestionIndexForGroupId:(int)groupId
{
    NSString *key = [NSString stringWithFormat:@"q_index_%d",groupId];//定义key
    [_questionDictionary removeObjectForKey:key];
}

/**
 *  获取当前问题所在组合的下标
 *
 *  @param groupId 组合id
 *
 *  @return
 */
- (int)questionIndexForGroupId:(NSString *)groupId
{
    NSString *key = [NSString stringWithFormat:@"q_index_%@",groupId];//定义key
    
    int index = [[_questionDictionary objectForKey:key]intValue];//当前第几个问题
    
    return index;
}

#pragma - mark 控制页面切换


/**
 *  根据问题id获取对应拓展问题view
 *
 *  @param questionId 问题id
 *  @param forward 是否是前进
 *
 *  @return view
 */
- (UIView *)configExtensionItemWithQuestionId:(NSInteger)questionId
                             forward:(BOOL)forward
{
    if (forward) {
        //记录问题顺序
        [self addSortArrayWithQuestionId:questionId extension:YES];
    }
    
    _questionId = [NSString stringWithFormat:@"%@_%ld",Q_Extension,(long)questionId];
    
    DDLOG(@"extension questionId: %@",_questionId);
    
    UIView *view = nil;
    __weak typeof(self)weakSelf = self;
    
    //拓展的问题
    
    QuestionModel *aModel = [[DBManager shareInstance]queryExtensionQuestionById:(int)questionId];
    
    //问题 经常自我感觉不适 是多选,其他单选
    if (aModel.questionId == 6) {
        aModel.select_option_type = QUESTIONOPTIONTYPE_MULTI;
    }else
    {
        aModel.select_option_type = QUESTIONOPTIONTYPE_SINGLE;
    }
    
    NSArray *options = [[DBManager shareInstance]queryExtensionOptionsIdsByQuestionId:(int)questionId];
    
    int optionsNum = (int)[options count];
    
    NSMutableArray *options_arr = [NSMutableArray array];
    //获取选项和选项对应图片
    for (int i = 0; i < optionsNum; i ++) {
        NSString *imageName = [NSString stringWithFormat:@"extension_%d_%d.png",(int)questionId + 30,i + 1];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            
            int optionId = [options[i] intValue];
            OptionModel *option = [[OptionModel alloc]initWithQuestionId:(int)questionId optionId:optionId optionImage:image];
            [options_arr addObject:option];
        }
    }
    
    //需要拼接组合的答案二进制串
    
    NSString *key = [NSString stringWithFormat:@"extension_question_%d",(int)questionId];
    NSString *initAnswerString = [_questionDictionary objectForKey:key];
    
    LQuestionView *quetionView = [[LQuestionView alloc]initQuestionViewWithFrame:CGRectMake(forward ? DEVICE_WIDTH : 0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - FitScreen(40)) answerImages:options_arr quesitonId:NSStringFromInt(aModel.questionId) questionTitle:aModel.questionName initAnswerString:initAnswerString resultBlock:^(QUESTIONTYPE type, id object, NSDictionary *result) {
        
        DDLOG(@"result %@",result);
        
        NSString *answerString = result[QUESTION_ANSERSTRING];
        //记录答案
        [_questionDictionary safeSetString:answerString forKey:key];
        
        //记录选项id
        NSArray *optionIds = [result objectForKey:QUESTION_OPTION_IDS];
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *option in optionIds) {
            int optionid = [[[option allKeys]lastObject] intValue];
            int state = [[[option allValues]lastObject]intValue];
            if (state == 1) { //选择了
                [temp addObject:NSStringFromInt(optionid)];
            }
        }
        
        [weakSelf updateExtensionQustionOptionidString:[temp componentsJoinedByString:@","] questionId:questionId];
        
        //判断是否是单选,单选的情况下自动跳转
        if (type == QUESTIONOPTIONTYPE_SINGLE) {
            
            [weakSelf clickToForward:nil];
        }
        
    } mulSelect:aModel.select_option_type specialOptionId:0];
    
    [self.view addSubview:quetionView];
    
    view = quetionView;


    
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
    
    if (forward) {
        //记录问题顺序
        [self addSortArrayWithQuestionId:questionId extension:NO];
    }
    
    _questionId = NSStringFromInt((int)questionId);//记录当前问题id
    
    DDLOG(@"questionId: %d - %@",_groupId,_questionId);
    
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
        }else
        {
            age = 30;//初始值30岁
        }
        
        Gender gender = [[_questionDictionary objectForKey:Q_SEX]intValue];
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
            [_view_Height setInitValue:NSStringFromInt(height)];
        }else
        {
//            个性化定制
//            男：30岁、175、70kg
//            女：30岁、160、45kg
            //初始值
            if (self.gender == Gender_Boy) {
                height = 175.f;
            }else
            {
                height = 160.f;
            }
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
            [_view_Weight setInitValue:NSStringFromInt(weight)];
        }else
        {
            //            个性化定制
            //            男：30岁、175、70kg
            //            女：30岁、160、45kg
            //初始值
            if (self.gender == Gender_Boy) {
                weight = 70;
            }else
            {
                weight = 45;
            }
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
            NSString *imageName = [NSString stringWithFormat:@"%d_%d.png",(int)questionId,i + 1];
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

    DDLOG(@"%@",temp);
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

#pragma mark - 拓展问题处理
/**
 *  获取所有的拓展问题 getter
 *
 *  @return
 */
- (NSArray *)extensionQuestionArray
{
    _extensionQuestionArray = [[DBManager shareInstance]queryAllExtensionQuestionsWithAge:self.age];
    return _extensionQuestionArray;
}

/**
 *  当前性别
 *
 *  @return
 */
-(Gender)gender
{
    NSNumber *sex = [_questionDictionary objectForKey:Q_SEX];
    return [sex intValue];
}

/**
 *  当前年龄
 *
 *  @return
 */
-(int)age
{
    NSNumber *age = [_questionDictionary objectForKey:Q_AGE];
    return [age intValue];
}

@end
