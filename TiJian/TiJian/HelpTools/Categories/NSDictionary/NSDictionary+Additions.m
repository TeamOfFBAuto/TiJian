//
//  NSDictionary+Additions.m
//  TiJian
//
//  Created by lichaowei on 16/1/7.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

#pragma mark - NSDictionary方便小工具

- (NSDictionary *)addObject:(NSDictionary *)object
{
    if (![object isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self];
    [dic addEntriesFromDictionary:object];
    return [NSDictionary dictionaryWithDictionary:dic];
}


@end

@implementation NSMutableDictionary (Additions)

-(void)safeSetValue:(id)value forKey:(NSString *)key
{
    if (key == nil) {
        return;
    }
    if (value != nil) {
        [self setValue:value forKey:key];//事实上value为nil时，会自动调用removeObjectForKey
    }
}

-(void)safeSetString:(NSString*)string forKey:(NSString*)key;
{
    [self safeSetValue:string forKey:key];
}

-(void)safeSetBool:(BOOL)i forKey:(NSString *)key
{
    self[key] = @(i);
}
-(void)safeSetInt:(int)i forKey:(NSString *)key
{
    self[key] = @(i);
}
-(void)safeSetInteger:(NSInteger)i forKey:(NSString *)key
{
    self[key] = @(i);
}

-(void)safeSetCGFloat:(CGFloat)f forKey:(NSString *)key
{
    self[key] = @(f);
}

@end