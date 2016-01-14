//
//  NSDictionary+Additions.h
//  TiJian
//
//  Created by lichaowei on 16/1/7.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)

- (NSDictionary *)addObject:(NSDictionary *)object;

@end

@interface NSMutableDictionary (Additions)

-(void)safeSetValue:(id)value forKey:(NSString *)key;

-(void)safeSetString:(NSString*)string forKey:(NSString*)key;

-(void)safeSetBool:(BOOL)i forKey:(NSString *)key;

-(void)safeSetInt:(int)i forKey:(NSString *)key;

-(void)safeSetInteger:(NSInteger)i forKey:(NSString *)key;

-(void)safeSetCGFloat:(CGFloat)f forKey:(NSString *)key;

@end