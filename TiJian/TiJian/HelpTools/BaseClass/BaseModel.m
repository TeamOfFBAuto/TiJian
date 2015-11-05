//
//  BaseModel.m
//  FBCircle
//
//  Created by lichaowei on 14-8-6.
//  Copyright (c) 2014年 soulnear. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel
-(id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:dic];
        }
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"forUndefinedKey %@",key);
}

+ (NSArray *)modelsFromArray:(NSArray *)array
{
    
    if (![array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *aDic in array) {
        
        if ([aDic isKindOfClass:[NSDictionary class]]) {
            
            id object = [[self alloc]initWithDictionary:aDic];
            [objects addObject:object];
        }
    }
    return objects;
}

@end
