//
//  DBManager.m
//  WJXC
//
//  Created by lichaowei on 15/7/17.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "DBManager.h"
#import "QuestionModel.h"
#import "IgnoreConditionModel.h"

@implementation DBManager

+ (id)shareInstance
{
    static dispatch_once_t once_t;
    static DBManager *manager = nil;
    dispatch_once(&once_t, ^{
        
        manager = [[DBManager alloc]init];
        
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        _dataBase = [[FMDatabase alloc]initWithPath:[self getPath]];
        
        if (![_dataBase open])
        {
            NSLog(@"OPEN FAIL");

        }
//        //创建 ShoppingCar表
//        
//        [_dataBase executeUpdate:@"CREATE TABLE IF NOT EXISTS ShoppingCar(uid text,product_name text,product_id int,product_num int,current_price text,add_time text,cover_pic text)"];
        
        [_dataBase close];
    }
    return self;
}

/**
 *  获取数据库路径
 *
 *  @return
 */
-(NSString *)getPath
{
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];//获取document路径
    NSString *filePath = [documents stringByAppendingPathComponent:@"hema.sqlite"]; //将要存放位置
    NSLog(@"数据库路径 = %@",filePath);
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"hema" ofType:@"sqlite"];//bundle中位置
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) {
        [fm copyItemAtPath:bundlePath toPath:filePath error:nil]; //拷贝数据文件到document下
    }
    return filePath;
}


//２.查询是否有未同步数据

-(BOOL)isExistUnsyncProduct
{
    if ([_dataBase open]) {
        
        FMResultSet *rs = [_dataBase executeQuery:@"SELECT count(*) FROM ShoppingCar where product_id != 0"];
        
        while ([rs next]){
            
            int num = [rs intForColumnIndex:0];
            
            NSLog(@"有未同步数据 existNum: %d",num);
            
            if (num > 0) {
                
                [rs close];
                
                [_dataBase close];
                
                return YES;
            }
        }
        
    }
    NSLog(@"没有未同步数据");
    
    return NO;
}



-(NSArray *)QueryData
{
    //获取数据
    NSMutableArray *recordArray = [[NSMutableArray  alloc]init];
    
    if ([_dataBase open]) {
        
        FMResultSet *rs = [_dataBase executeQuery:@"SELECT * FROM ShoppingCar"];
        
        while ([rs next]){
            
            //cart_pro_id int,uid text,product_name text,product_id int,product_num int,current_price text,add_time text
            
//            ProductModel *OneRecord = [[ProductModel alloc]init];
//            
//            OneRecord.uid = [rs stringForColumn:@"uid"];
//            
//            OneRecord.product_name = [rs stringForColumn:@"product_name"];
//            
//            OneRecord.product_id = [NSString stringWithFormat:@"%d",[rs intForColumn:@"product_id"]];
//            
//            OneRecord.product_num = [NSString stringWithFormat:@"%d",[rs intForColumn:@"product_num"]];
//            
//            OneRecord.current_price = [rs stringForColumn:@"current_price"];
//            
//            OneRecord.cover_pic = [rs stringForColumn:@"cover_pic"];
//            
//            [recordArray addObject: OneRecord];
            
        }
        
        [rs close];
        
        [_dataBase close];
        
    }
    return recordArray;
}


-(int)QueryAllDataNum
{
    //获取数据 单品总数
    
    int sum = 0;

    if ([_dataBase open]) {
        
        FMResultSet *rs = [_dataBase executeQuery:@"SELECT * FROM ShoppingCar"];
        
        while ([rs next]){
            
            int x = [rs intForColumn:@"product_num"];
            
            sum += x;
            
        }
        
        [rs close];
        
        [_dataBase close];
        
    }
    return sum;
}

//３.更新数据 数量

-(void)udpateProductId:(NSString *)productId
                   num:(int)num
{
    
    if ([_dataBase open]) {
        
        [_dataBase beginTransaction];
        
        [_dataBase executeUpdate:@"UPDATE ShoppingCar SET product_num = ? WHERE product_id = ?",[NSNumber numberWithInt:num],[NSNumber numberWithInt:[productId intValue]]];

        [_dataBase commit];
        
        [_dataBase close];
    }
}


////４。插入数据 到购物车
//
//-(void)insertProduct:(ProductModel *)aModel
//{
//    //插入数据库
//    
//    if ([_dataBase open]) {
//        
//        [_dataBase beginTransaction];
//       
//        //cart_pro_id int,uid text,product_name text,product_id int,product_num int,current_price text,add_time text
//        
//        NSString *uid = aModel.uid ? : @"";
//        NSString *name = aModel.product_name ? : @"";
//        NSString *productId = aModel.product_id ? : @"0";
//        NSString *addTime = aModel.add_time ? : @"";
////        NSString *num = aModel.product_num ? : @"0";
//        NSString *price = aModel.current_price ? : @"0";
//        NSString *cover_pic = aModel.cover_pic ? : @"";
//        
//        
//        FMResultSet *rs = [_dataBase executeQuery:@"SELECT count(*) FROM ShoppingCar where product_id = ?",productId];
//        
//        int num = 0;
//        while ([rs next]){
//            
//            num = [rs intForColumnIndex:0];
//            
//            NSLog(@"productId %@ existNum: %d",productId,num);
//
//        }
//        
//        //存在的话 +1 否则 插入新数据
//        if (num > 0) {
//            
//            [_dataBase executeUpdate:@"update ShoppingCar set product_num = product_num + 1 where product_id = ?",[NSNumber numberWithInt:[productId intValue]]];
//        }else
//        {
//            [_dataBase executeUpdate:@"insert into ShoppingCar (uid,product_name,product_id,current_price,add_time,cover_pic,product_num) values (?,?,?,?,?,?,?)",uid,name,[NSNumber numberWithInt:[productId intValue]],price,addTime,cover_pic,[NSNumber numberWithInt:1]];
//        }
//        
//        [_dataBase commit];
//        [_dataBase close];
//    }
//    
//}

/**
 *  单品数量 +1 或者 -1
 *  @param num +1代表加 -1代表减
 */
- (void)increasProductId:(NSString *)productId
                   ByNum:(int)num
{
    //插入数据库
    
    if ([_dataBase open]) {
        
        [_dataBase beginTransaction];
        
        if (num > 0) {
           [_dataBase executeUpdate:@"update ShoppingCar set product_num = product_num + 1 where product_id = ?",[NSNumber numberWithInt:[productId intValue]]];
        }else
        {
            [_dataBase executeUpdate:@"update ShoppingCar set product_num = product_num - 1 where product_id = ? and product_num > 0",[NSNumber numberWithInt:[productId intValue]]];
        }
        
        [_dataBase commit];
        [_dataBase close];
    }
}

/**
 *  清空表 自增列归为0
 */
-(void)deleteAll
{
    //插入数据库
    
    if ([_dataBase open]) {
        
        [_dataBase beginTransaction];
        
        [_dataBase executeUpdate:@"DELETE FROM ShoppingCar"];
        
        [_dataBase executeUpdate:@"UPDATE sqlite_sequence set seq = 0 where name = 'ShoppingCar'"];
        
        [_dataBase commit];
        [_dataBase close];
    }
    
}

/**
 *  删除某一条数据
 */
-(void)deleteProductId:(NSString *)productId
{
    //插入数据库
    
    if ([_dataBase open]) {
        
        [_dataBase beginTransaction];
        
        [_dataBase executeUpdate:@"delete from ShoppingCar where product_id = ?",[NSNumber numberWithInt:[productId intValue]]];
        
        [_dataBase commit];
        [_dataBase close];
    }
    
}

#pragma - mark 个性化定制
/**
 *  根据组合id查找对应所有问题id
 *
 *  @param groupId 组合id
 */
- (NSArray *)queryQuestionIdsByGroupId:(int)groupId
{
    if ([_dataBase open]) {
        FMResultSet *rs = [_dataBase executeQuery:
                           @"select question_id from j_customization_group_questions where group_id = ? order by 'order'",[NSNumber numberWithInt:groupId]];
        
        NSMutableArray *temp = [NSMutableArray array];
        while (rs.next) {
            
            int x = [rs intForColumn:@"question_id"];
            [temp addObject:NSStringFromInt(x)];
        }
        [rs close];
        [_dataBase close];
        return temp;
    }
    return nil;
}

/**
 *  根据问题id查找对应所有选项
 *
 *  @param groupId 组合id
 */
- (NSArray *)queryOptionsIdsByQuestionId:(int)groupId
{
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select option_id from j_customization_question_options where question_id = %d order by option_order",groupId];
        FMResultSet *rs = [_dataBase executeQuery:sql];
        NSMutableArray *temp = [NSMutableArray array];
        while (rs.next) {
            
            int x = [rs intForColumn:@"option_id"];
            [temp addObject:NSStringFromInt(x)];
        }
        [rs close];
        [_dataBase close];
        return temp;
    }
    return nil;
}

/**
 *  查询下个组合id (正数为未结束、负数为结束、0为无对应的下个组合信息)
 *
 *  @param groupId      当前组合id
 *  @param answerString 当前组合下所有问题答案（1、0）的二进制串
 *
 *  @return 下个组合id
 */
- (int)queryNextGroupIdByGroupId:(int)groupId
                   answerString:(NSString *)answerString
{
    //  str 为要转换的字符串，endstr 为第一个不能转换的字符的指针，base 为字符串 str 所采用的进制。
//    NSLog(@"%lu",  strtoul([test UTF8String], NULL, 2));//二进制转长整形无符号

    if (!answerString) {
        return 0;
    }
    
    int answerIds = (int)strtoul([answerString UTF8String], NULL, 2);
    if ([_dataBase open]) {
        
        NSString *sql;
        if (groupId == 0) { //group_id 不作为条件
            
           sql = [NSString stringWithFormat:@"select next_group_id,is_end from j_customization_g_q_answer where answer_ids = %d",answerIds];
        }else
        {
            sql = [NSString stringWithFormat:@"select next_group_id,is_end from j_customization_g_q_answer where group_id = %d  and answer_ids = %d",groupId,answerIds];
        }
        
        NSLog(@"%s sql:%@",__FUNCTION__,sql);
        
        FMResultSet *rs = [_dataBase executeQuery:sql];
        int x = 0;
        while (rs.next) {
            
            x = [rs intForColumn:@"next_group_id"];
            
            int is_end = [rs intForColumn:@"is_end"];
            
            if (is_end) { //如果是结束 则为负
                x *= -1;
            }
            
            NSLog(@"nextGroupId %d",x);
        }
        [rs close];
        [_dataBase close];
        return x;
    }
    return 0;
}

/**
 *  查询问题信息
 *
 *  @param questionId    问题id
 *
 *  @return QuestionModel对象
 */
- (id)queryQuestionById:(int)questionId
{
    
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from j_customization_questions where question_id = %d",questionId];
        FMResultSet *rs = [_dataBase executeQuery:sql];
        QuestionModel *aModel = [[QuestionModel alloc]init];
        while (rs.next) {
            
            int q_id = [rs intForColumn:@"question_id"];
            NSString *q_name = [rs stringForColumn:@"question_name"];
            int type = [rs intForColumn:@"type"];
            int special_option_id = [rs intForColumn:@"special_option_id"];//特殊选项id
            int select_option_type = [rs intForColumn:@"select_option_type"];//问题的选项类型 1234
            aModel.questionId = q_id;
            aModel.questionName = q_name;
            aModel.type = type;
            aModel.special_option_id = special_option_id;
            aModel.select_option_type = select_option_type;
        }
        [rs close];
        [_dataBase close];
        return aModel;
    }
    return nil;
}


/**
 *  查询组合name
 *
 *  @param groupId    问题id
 *
 *  @return
 */
- (NSString *)queryGroupNameById:(int)groupId
{
    
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select group_name from j_customization_groups where group_id = %d",groupId];
        
        NSString *g_name = @"";
        FMResultSet *rs = [_dataBase executeQuery:sql];
        while (rs.next) {
            
            g_name = [rs stringForColumn:@"group_name"];
                    }
        [rs close];
        [_dataBase close];
        return g_name;
    }
    return @"";
}

/**
 *  查找组合答案拼接时需要忽略信息 model
 *
 *  @param groupId 组合id
 *
 *  @return
 */
- (NSArray *)queryIgnoreInfoByGroupId:(int)groupId
{
    
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from j_customization_ignore where group_id = %d",groupId];
        
        NSMutableArray *temp = [NSMutableArray array];
        FMResultSet *rs = [_dataBase executeQuery:sql];
        while (rs.next) {
            int groupId = [rs intForColumn:@"group_id"];
            int question_id = [rs intForColumn:@"question_id"];
            NSString *ignore_option_ids = [rs stringForColumn:@"ignore_option_ids"];
            NSString *ignore_conditions = [rs stringForColumn:@"ignore_conditions"];
            IgnoreConditionModel *aModel = [[IgnoreConditionModel alloc]init];
            aModel.group_id = groupId;
            aModel.question_id = question_id;
            aModel.ignore_conditions = ignore_conditions;
            aModel.ignore_option_ids = ignore_option_ids;
            [temp addObject:aModel];
        }
        
        [rs close];
        [_dataBase close];
        return temp;
    }
    return nil;
}

//- (int)ignoreTypeIdForGroupId:(int)groupId
//                   questionId:(int)questionId
//                     optionId:(int)optionId
//                       answer:(int)answer
//                         type:(int)type
//                   affectNext:(int)affectNext

/**
 *  查询组合id对应的 n+1忽略条件
 *
 *  @param groupId
 *
 *  @return
 */
- (NSArray *)queryIgnoreN1ModelForGroupId:(int)groupId
{
    
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from j_customization_n1 where group_id = %d",groupId];
        FMResultSet *rs = [_dataBase executeQuery:sql];
        
        NSLog(@"%s %@",__FUNCTION__,sql);
        
        NSMutableArray *temp = [NSMutableArray array];
        
        while(rs.next) {
            
            int n1_id = [rs intForColumn:@"n1_id"];
            int question_id = [rs intForColumn:@"question_id"];
            int option_id = [rs intForColumn:@"option_id"];
            int answer = [rs intForColumn:@"answer"];
            int type = [rs intForColumn:@"type"];
            int affectNext = [rs intForColumn:@"affect_next"];
            int n1_type_id = [rs intForColumn:@"n1_type_id"];
            
            IgnoreConditionModel *aModel = [[IgnoreConditionModel alloc]initWithGroupId:groupId questionId:question_id optionId:option_id answer:answer type:type affectNext:affectNext n1_type_id:n1_type_id];
            aModel.n1_id = n1_id;
            [temp addObject:aModel];
            NSLog(@"__next groupId:%d questionId:%d optionId:%d",groupId,question_id,option_id);
            
        }
        [rs close];
        [_dataBase close];
        
        return  temp;
    }
    
    return nil;
}


#pragma mark - 拓展问题

/**
 *  查询所有拓展问题信息
 *
 *  @return 所有拓展QuestionModel对象
 */
- (NSArray *)queryAllExtensionQuestions
{
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from j_extention_questions where extention_question_id != 0"];
        FMResultSet *rs = [_dataBase executeQuery:sql];
        
        NSMutableArray *temp = [NSMutableArray array];
        while (rs.next) {
            QuestionModel *aModel = [[QuestionModel alloc]init];

            int q_id = [rs intForColumn:@"extention_question_id"];
            NSString *q_name = [rs stringForColumn:@"question_name"];
            int gender = [rs intForColumn:@"gender"];
            int start_age = [rs intForColumn:@"start_age"];//特殊选项id
            int end_age = [rs intForColumn:@"end_age"];//问题的选项类型 1234
            int is_end = [rs intForColumn:@"is_end"];//是否结束
            
            aModel.questionId = q_id;
            aModel.questionName = q_name;
            aModel.gender = gender;
            aModel.start_age = start_age;
            aModel.end_age = end_age;
            aModel.is_end = is_end;
            
            [temp addObject:aModel];
        }
        [rs close];
        [_dataBase close];
        return temp;
    }
    return nil;
}

/**
 *  查询所有拓展符合年龄条件id > 3的问题
 *
 *  @return 所有拓展QuestionModel对象
 */
- (NSArray *)queryAllExtensionQuestionsWithAge:(int)age
{
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from j_extention_questions where extention_question_id > 3"];
        FMResultSet *rs = [_dataBase executeQuery:sql];
        
        NSMutableArray *temp = [NSMutableArray array];
        while (rs.next) {
            QuestionModel *aModel = [[QuestionModel alloc]init];
            
            int q_id = [rs intForColumn:@"extention_question_id"];
            NSString *q_name = [rs stringForColumn:@"question_name"];
            int gender = [rs intForColumn:@"gender"];
            int start_age = [rs intForColumn:@"start_age"];//特殊选项id
            int end_age = [rs intForColumn:@"end_age"];//问题的选项类型 1234
            int is_end = [rs intForColumn:@"is_end"];//是否结束
            
            //年龄满足
            
            if ((age > start_age && age <= end_age) ||
                (start_age == 0 && end_age == 0)) {
                
                aModel.questionId = q_id;
                aModel.questionName = q_name;
                aModel.gender = gender;
                aModel.start_age = start_age;
                aModel.end_age = end_age;
                aModel.is_end = is_end;
                
                [temp addObject:aModel];

            }
            
        }
        [rs close];
        [_dataBase close];
        return temp;
    }
    return nil;
}

/**
 *  查询拓展问题信息
 *
 *  @param questionId    问题id
 *
 *  @return QuestionModel对象
 */
- (id)queryExtensionQuestionById:(int)questionId
{
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from j_extention_questions where extention_question_id = %d",questionId];
        FMResultSet *rs = [_dataBase executeQuery:sql];
        QuestionModel *aModel = [[QuestionModel alloc]init];
        while (rs.next) {
            
            int q_id = [rs intForColumn:@"extention_question_id"];
            NSString *q_name = [rs stringForColumn:@"question_name"];
            int gender = [rs intForColumn:@"gender"];
            int start_age = [rs intForColumn:@"start_age"];//特殊选项id
            int end_age = [rs intForColumn:@"end_age"];//问题的选项类型 1234
            int is_end = [rs intForColumn:@"is_end"];//是否结束

            aModel.questionId = q_id;
            aModel.questionName = q_name;
            aModel.gender = gender;
            aModel.start_age = start_age;
            aModel.end_age = end_age;
            aModel.is_end = is_end;
        }
        [rs close];
        [_dataBase close];
        return aModel;
    }
    return nil;
}

/**
 *  根据问题id查找对应所有选项id
 *
 */
- (NSArray *)queryExtensionOptionsIdsByQuestionId:(int)qustionId
{
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select question_option_id from j_extention_question_option where question_id = %d order by question_option_id",qustionId];
        FMResultSet *rs = [_dataBase executeQuery:sql];
        NSMutableArray *temp = [NSMutableArray array];
        while (rs.next) {
            
            int x = [rs intForColumn:@"question_option_id"];
            [temp addObject:NSStringFromInt(x)];
        }
        [rs close];
        [_dataBase close];
        return temp;
    }
    return nil;
}

/**
 *  根据组合id查找对应所有问题id
 *
 *  @param groupId 组合id
 */
- (NSArray *)queryExtensionQuestionIdsByGroupId:(int)groupId
{
    if ([_dataBase open]) {
        FMResultSet *rs = [_dataBase executeQuery:
                           @"select question_id from j_customization_group_questions where group_id = ? order by 'order'",[NSNumber numberWithInt:groupId]];
        
        NSMutableArray *temp = [NSMutableArray array];
        while (rs.next) {
            
            int x = [rs intForColumn:@"question_id"];
            [temp addObject:NSStringFromInt(x)];
        }
        [rs close];
        [_dataBase close];
        return temp;
    }
    return nil;
}


/**
 *  查询所有拓展符合年龄条件id > 3的问题
 *
 *  @return 所有拓展QuestionModel对象
 */
- (NSArray *)queryAllExtensionQuestionIdsWithAge:(int)age
{
    if ([_dataBase open]) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from j_extention_questions where extention_question_id > 3"];
        FMResultSet *rs = [_dataBase executeQuery:sql];
        
        NSMutableArray *temp = [NSMutableArray array];
        while (rs.next) {
            
            int q_id = [rs intForColumn:@"extention_question_id"];
            int start_age = [rs intForColumn:@"start_age"];//特殊选项id
            int end_age = [rs intForColumn:@"end_age"];//问题的选项类型 1234
            
            //满足年龄条件
            if ((age > start_age && age <= end_age) ||
                (start_age == 0 && end_age == 0)) {
                
                [temp addObject:NSStringFromInt(q_id)];
            }
            
        }
        [rs close];
        [_dataBase close];
        return temp;
    }
    return nil;
}


@end
