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
