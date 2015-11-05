//
//  NSArray+Additons.m
//  TiJian
//
//  Created by lichaowei on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "NSArray+Additons.h"
//#import <objc/runtime.h>

@implementation NSArray (Additons)

- (NSArray *)objectsForClass:(Class)classInfo
{
    if (![self isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:self.count];
    
    for (NSDictionary *aDic in self) {
        
        if ([aDic isKindOfClass:[NSDictionary class]]) {
            
            id object = [[classInfo alloc]init];
            [object setValuesForKeysWithDictionary:aDic];
            [objects addObject:object];
        }
    }
    
    return objects;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"haha forUndefinedKey %@",key);
}

@end
