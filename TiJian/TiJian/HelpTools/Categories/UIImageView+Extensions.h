//
//  UIImageView+Extensions.h
//  YiYiProject
//
//  Created by lichaowei on 15/5/6.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"

@interface UIImageView (Extensions)

/**
 *  imageView赋值image 适用于imageView不定大小情况 placeHolder比较小
 *
 *  @param url         图片地址
 *  @param placeholder 默认图标
 */
- (void)l_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)l_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  根据需要图片size等比例裁图
 *
 *  @param url
 *  @param imageSize   希望大小
 *  @param placeholder
 */
-(void)l_setImageWithURL:(NSURL *)url
                clipSize:(CGSize)imageSize
        placeholderImage:(UIImage *)placeholder;

@end
