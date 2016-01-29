//
//  BaseModel.h
//  FBCircle
//
//  Created by lichaowei on 14-8-6.
//  Copyright (c) 2014年 soulnear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

-(id)initWithDictionary:(NSDictionary *)dic;

/**
 *  将字典数组转化为model数组
 *
 *  @param array 字典数组
 *
 *  @return
 */
+ (NSArray *)modelsFromArray:(NSArray *)array;

@end
