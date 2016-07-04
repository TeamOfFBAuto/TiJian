//
//  UIImageView+Extensions.m
//  YiYiProject
//
//  Created by lichaowei on 15/5/6.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "UIImageView+Extensions.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (Extensions)


- (void)addTaget:(id)target action:(SEL)selector tag:(int)tag
{
    self.userInteractionEnabled = YES;
    UIButton *personalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [personalButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    personalButton.frame = self.bounds;
    personalButton.tag = tag;
    [self addSubview:personalButton];
}

- (void)addRoundCorner
{
    [self addCornerRadius:self.width/2.f];
}

/**
 *  加默认文字
 *
 *  @param placeHolder 默认文字
 */
- (void)addPlaceHolder:(NSString *)placeHolder
           holderTextColor:(UIColor *)holderTextColor
{
    UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
    label.text = placeHolder;
    [self.superview addSubview:label];
    label.font = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = holderTextColor;
    [self.superview bringSubviewToFront:self];
    
}

/**
 *  加默认文字
 *
 *  @param placeHolder 默认文字
 */
- (void)setImageWithURL:(NSURL *)imageURL
        placeHolderText:(NSString *)placeHolderText
        backgroundColor:(UIColor *)backColor
        holderTextColor:(UIColor *)holderTextColor
{
    __block UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
    [self addSubview:label];
    label.font = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = holderTextColor;
    self.backgroundColor = backColor;
    
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = self.bounds;
    [self addSubview:indicator];
    indicator.center = CGPointMake(self.width/2.f, self.height/2.f);
    [indicator startAnimating];
    
    [self sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (error) {
            //加载失败显示placeHolderText
            label.text = placeHolderText;
        }else
        {
            //加载成功移除label
            label.hidden = YES;
            [label removeFromSuperview];
            label = nil;
        }

        [indicator stopAnimating];

    }];
    
}

/**
 *  根据需要图片size等比例裁图
 *
 *  @param url
 *  @param imageSize   希望大小
 *  @param placeholder
 */
-(void)l_setImageWithURL:(NSURL *)url
                clipSize:(CGSize)imageSize
        placeholderImage:(UIImage *)placeholder
{
    @WeakObj(self);
    
    NSString *imageUrlString = url.absoluteString;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    NSString *clipImageUrlString = [NSString stringWithFormat:@"%@?clip=%.f×%.f",imageUrlString,imageSize.width,imageSize.height];
    clipImageUrlString = [clipImageUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//防止特殊符号 URL为nil
    NSURL *clipImageUrl = [NSURL URLWithString:clipImageUrlString];//NSURL
    
    [self l_setImageWithURL:clipImageUrl placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (image)
        {
            CGFloat o_radio = image.size.width / image.size.height;
            CGFloat n_radio = imageSize.width / imageSize.height;
            
            NSLog(@"o:%@ n:%@",NSStringFromFloat(o_radio),NSStringFromFloat(n_radio));
            
            CGFloat x = o_radio - n_radio;
            if (x >= -0.1 && x <= 0.1) { //此比例下不需要重新切图
                
                DDLOG(@"图片比例满足条件");
                
            }else
            {
                image = [image imageCompressForTargetSize:imageSize];//裁切
                [manager saveImageToCache:image forURL:clipImageUrl];
                DDLOG(@"切图");
            }
            
            Weakself.image = image;
        }
    }];
    
}

/**
 *  imageView赋值image 适用于imageView不定大小情况
 *
 *  @param url         图片地址
 *  @param placeholder 默认图标
 */
-(void)l_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self l_setImageWithURL:url placeholderImage:placeholder completed:nil];
}

- (void)l_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    
    self.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    //没有默认图时加菊花
    __block UIActivityIndicatorView *indicator;
    if (!placeholder) {
        
        indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = self.bounds;
        [self addSubview:indicator];
        indicator.center = CGPointMake(self.width/2.f, self.height/2.f);
        [indicator startAnimating];
    }else
    {
        if ([placeholder isKindOfClass:[UIImage class]]) {
            
            CGSize imageSize = placeholder.size;
            //默认图比imageView大
            if (imageSize.width > CGRectGetWidth(self.frame) ||
                imageSize.height > CGRectGetHeight(self.frame)) {
                
                self.contentMode = UIViewContentModeScaleAspectFit;//等比例填充

            }else
            {
                self.contentMode = UIViewContentModeCenter;//中间显示
            }
        }
    }
    
    self.clipsToBounds = YES;

    __weak typeof(self)weakSelf = self;
    [self sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        //block callBack
        if (completedBlock) {
            completedBlock(image,error,cacheType,imageURL);
        }
        
        //update by lcw
        if (image) {
            
            self.contentMode = UIViewContentModeScaleToFill;//等比例拉伸填充
            self.clipsToBounds = YES;
        }else
        {
            if (!placeholder) {
                UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
                label.text = @"抱歉,图片加载失败~";
                label.font = [UIFont systemFontOfSize:10];
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
                [weakSelf addSubview:label];
            }
        }
        
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        indicator = nil;
        
    }];
}


@end
