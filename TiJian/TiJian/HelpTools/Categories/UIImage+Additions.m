//
//  UIImage+Additions.m
//  TiJian
//
//  Created by lichaowei on 15/12/6.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

/**
 *  压缩图片
 *
 *  @param maxSize     最大允许值
 *  @param compression 压缩率 最大0.1
 *
 *  @return 压缩后图片
 */
- (UIImage *)compressToMaxSize:(NSInteger)maxSize
                   compression:(CGFloat)compression
{
    NSData *imageData = [self dataWithCompressMaxSize:maxSize compression:compression];
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    
    return compressedImage;
}

/**
 *  压缩图片返回NSData
 *
 *  @param maxSize     最大允许值
 *  @param compression 压缩率 最大0.1
 *
 *  @return 压缩后NSData
 */
- (NSData *)dataWithCompressMaxSize:(NSInteger)maxSize
                        compression:(CGFloat)compression
{
    CGFloat maxCompression = 0.1f;//最大压缩0.1
    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    
    NSLog(@"imagedata1 %lu",(unsigned long)imageData.length);
    
    while ([imageData length] > maxSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(self, compression);
    }
    
    return imageData;
}

@end
