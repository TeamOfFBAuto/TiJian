//
//  RecommendMedicalCheckController.h
//  TiJian
//
//  Created by lichaowei on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//
/**
 *  推荐套餐
 */
#import "MyViewController.h"

@interface RecommendMedicalCheckController : MyViewController

@property(nonatomic,assign)RecommendType recommendType;

//疾病相关
@property(nonatomic,retain)NSString *diseaseId;//疾病id

//个性化相关
@property(nonatomic,retain)NSString *jsonString;
@property(nonatomic,retain)NSString *extensionString;//拓展问题
@property(nonatomic,retain)NSString *vouchers_id;//代金券

@end
