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

typedef void(^RESULTBLOCK)(QUESTIONTYPE type,id object, NSDictionary *result);
@interface LQuestionView : UIView

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
                               mulSelect:(BOOL)mulSelect;

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


@end
