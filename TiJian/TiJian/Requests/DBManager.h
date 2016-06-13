//
//  DBManager.h
//  WJXC
//
//  Created by lichaowei on 15/7/17.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"

@interface DBManager : NSObject
{
    FMDatabase *_dataBase;
}

@property(nonatomic,retain)FMDatabase *goHealthDataBase;//go健康

+ (id)shareInstance;

/**
 *  查询问题信息
 *
 *  @param questionId    问题id
 *
 *  @return QuestionModel对象
 */
- (id)queryQuestionById:(int)questionId;

/**
 *  根据组合id查找对应所有问题id
 *
 *  @param groupId 组合id
 */
- (NSArray *)queryQuestionIdsByGroupId:(int)groupId;

/**
 *  根据问题id查找对应所有选项
 *
 *  @param groupId 组合id
 */
- (NSArray *)queryOptionsIdsByQuestionId:(int)groupId;

/**
 *  查询下个组合id (正数为未结束、负数为结束、0为无对应的下个组合信息)
 *
 *  @param groupId      当前组合id
 *  @param answerString 当前组合下所有问题答案（1、0）的二进制串
 *
 *  @return 下个组合id
 */
- (int)queryNextGroupIdByGroupId:(int)groupId
                    answerString:(NSString *)answerString;

/**
 *  查询组合name
 *
 *  @param groupId    问题id
 *
 *  @return
 */
- (NSString *)queryGroupNameById:(int)groupId;

/**
 *  查找组合答案拼接时需要忽略信息 model
 *
 *  @param groupId 组合id
 *
 *  @return
 */
- (NSArray *)queryIgnoreInfoByGroupId:(int)groupId;

/**
 *  查询组合id对应的 n+1忽略条件
 *
 *  @param groupId
 *
 *  @return
 */
- (NSArray *)queryIgnoreN1ModelForGroupId:(int)groupId;

#pragma mark - 拓展问题

/**
 *  查询所有拓展问题信息
 *
 *  @return 所有拓展QuestionModel对象
 */
- (NSArray *)queryAllExtensionQuestions;

/**
 *  查询拓展问题信息
 *
 *  @param questionId    问题id
 *
 *  @return QuestionModel对象
 */
- (id)queryExtensionQuestionById:(int)questionId;


/**
 *  根据拓展问题id查找对应所有选项
 *
 *  @param groupId 组合id
 */
- (NSArray *)queryExtensionOptionsIdsByQuestionId:(int)groupId;


/**
 *  查询所有拓展符合年龄条件id > 3的问题
 *
 *  @return 所有拓展QuestionModel对象
 */
- (NSArray *)queryAllExtensionQuestionsWithAge:(int)age;


/**
 *  查询所有拓展符合年龄条件id > 3的问题id
 *
 *  @return 所有拓展QuestionModel对象
 */
- (NSArray *)queryAllExtensionQuestionIdsWithAge:(int)age;

@end
