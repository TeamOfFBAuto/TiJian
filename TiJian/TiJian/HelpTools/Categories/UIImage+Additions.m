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
    //指定宽度裁切尺寸
    UIImage *image = [self imageCompressForTargetWidth:600];
    
    CGFloat maxCompression = 0.01f;//最大压缩0.01
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    DDLOG(@"imagedata1 %lu",(unsigned long)imageData.length);

    while ([imageData length] > maxSize && compression > maxCompression) {
        compression -= 0.05;
        imageData = UIImageJPEGRepresentation(image, compression);
        DDLOG(@"imagedata2 %lu",(unsigned long)imageData.length);

    }

    return imageData;
}

/**
 *  按照给定大小等比例压缩图片
 *
 *  @param sourceImage 目标image
 *  @param size 指定显示大小
 *
 *  @return 新的image
 */

-(UIImage *)imageCompressForTargetSize:(CGSize)size
{
    
    UIImage *newImage = nil;
    
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    
    CGFloat scaleFactor = 0.0;
    
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;//目标越大
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        
        else{
            scaleFactor = heightFactor;
        }
        
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [self drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}


/**
 *  指定宽度按比例缩放
 *
 *  @param defineWidth 指定宽度
 *
 *  @return
 */
-(UIImage *)imageCompressForTargetWidth:(CGFloat)defineWidth{
    
    UIImage *sourceImage = self;
    
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    
    //尺寸偏小直接return
    if (imageSize.width < defineWidth) {
        return self;
    }
    
    CGFloat width = imageSize.width;
    
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = defineWidth;
    
    CGFloat targetHeight = height / (width / targetWidth);
    
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    
    CGFloat scaleFactor = 0.0;
    
    CGFloat scaledWidth = targetWidth;
    
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
        
    }
    
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
    
}



//指定宽度按比例缩放

-(UIImage *)imageCompressForWidth:(UIImage *)sourceImage
                       targetWidth:(CGFloat)defineWidth{
    
    
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = defineWidth;
    
    CGFloat targetHeight = height / (width / targetWidth);
    
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    
    CGFloat scaleFactor = 0.0;
    
    CGFloat scaledWidth = targetWidth;
    
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
        
    }
    
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end
