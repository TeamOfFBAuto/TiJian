//
//  LogView.h
//  TiJian
//
//  Created by lichaowei on 16/1/9.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogView : UIView

+ (id)logInstance;
/**
 *  添加记录
 *
 *  @param logString
 */
- (void)addLog:(NSString *)logString;

@end
