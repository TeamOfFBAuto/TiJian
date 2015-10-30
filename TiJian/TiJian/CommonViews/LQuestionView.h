//
//  LQuestionView.h
//  TiJian
//
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

/**
 *  个人定制，问题view
 */
#import <UIKit/UIKit.h>

#define QUESTION_OPTION_TYPE @"questionOptionType" //选项情况，单选、多选等
#define QUESTION_ANSERSTRING @"questionAnswerString" //答案二进制串
#define QUESTION_OPTION_IDS @"questionOptionIdS" //问题对应所有选项id
#define QUESTION_OPTION_STATE @"questionOptionState" //问题选项状态 1或者0

typedef void(^RESULTBLOCK)(QUESTIONTYPE type,id object, NSDictionary *result);
@interface LQuestionView : UIView

/**
 *  初始化问题view 根据答案个数来区分页面样式
 *
 *  @param mulSelect  选项类型
 *  @param answerImages 答案对应images
 *  @param initAnswerString      初始化答案二进制串
 *  @param quesitonId   问题id
 *
 *  @return
 */
-(instancetype)initQuestionViewWithFrame:(CGRect)frame
                            answerImages:(NSArray *)answerImages
                              quesitonId:(NSString *)questionId
                           questionTitle:(NSString *)questionTitle
                                 initAnswerString:(NSString *)initAnswerString
                             resultBlock:(RESULTBLOCK)aBlock
                               mulSelect:(QUESTIONOPTIONTYPE)mulSelect;

/**
 *  创建年龄view
 *  @param gender 性别
 *  @param selectAge 上次选择的年龄
 *  @return
 */
-(instancetype)initAgeViewWithFrame:(CGRect)frame
                             gender:(Gender)gender
                            initNum:(int)initNum
                        resultBlock:(RESULTBLOCK)aBlock;

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
                           resultBlock:(RESULTBLOCK)aBlock;

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
                           resultBlock:(RESULTBLOCK)aBlock;

/**
 *  设置滑动条初始值
 *
 *  @param initValue 初始值
 */
- (void)setInitValue:(NSString *)initValue;

/**
 *  获取选项选择状态1和0的串
 *
 */
- (NSString *)optionsSelectedState;

/**
 *  是否可以进行下一个
 *
 *  @return YES or NO
 */
- (BOOL)enableForward;

@end
