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

+ (id)shareInstance;

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
 *  查询下个组合id
 *
 *  @param groupId      当前组合id
 *  @param answerString 当前组合下所有问题答案（1、0）的二进制串
 *
 *  @return
 */
- (int)queryNextGroupIdByGroupId:(int)groupId
                    answerString:(NSString *)answerString;

////２.查询数据
//
//-(NSArray *)QueryData;
//
////单品总个数
//
//-(int)QueryAllDataNum;
//
////２.查询是否有未同步数据
//
//-(BOOL)isExistUnsyncProduct;
//
////３.更新数据 数量
//
//-(void)udpateProductId:(NSString *)productId
//                   num:(int)num;
///**
// *  单品数量 +1 或者 -1
// *  @param num +1代表加 -1代表减
// */
//- (void)increasProductId:(NSString *)productId
//                   ByNum:(int)num;
//
///**
// *  清空表 自增列归为0
// */
//-(void)deleteAll;
//
///**
// *  删除某一条数据
// */
//-(void)deleteProductId:(NSString *)productId;

@end
