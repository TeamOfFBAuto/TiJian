//
//  UIImage+Additions.h
//  TiJian
//
//  Created by lichaowei on 15/12/6.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

/**
 *  压缩图片
 *
 *  @param maxSize     最大允许值
 *  @param compression 压缩率 最大0.1
 *
 *  @return 压缩后图片
 */
- (UIImage *)compressToMaxSize:(NSInteger)maxSize
                   compression:(CGFloat)compression;

/**
 *  压缩图片返回NSData
 *
 *  @param maxSize     最大允许值
 *  @param compression 压缩率 最大0.1
 *
 *  @return 压缩后NSData
 */
- (NSData *)dataWithCompressMaxSize:(NSInteger)maxSize
                        compression:(CGFloat)compression;

@end
