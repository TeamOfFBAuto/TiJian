//
//  PhotoCell.m
//  JKImagePicker
//
//  Created by Jecky on 15/1/16.
//  Copyright (c) 2015年 Jecky. All rights reserved.
//

#import "PhotoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoCell()


@end

@implementation PhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Create a image view
        self.backgroundColor = [UIColor clearColor];
        [self imageView];

    }
    
    return self;
}

- (void)setImageUrl:(NSString *)url
{
    [self.imageView l_setImageWithURL:[NSURL URLWithString:url] placeholderImage:DEFAULT_HEADIMAGE];
}

- (void)setAsset:(JKAssets *)asset{
    if (asset) {
        _asset = asset;
        
        ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:_asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
            if (asset) {
                
                self.imageView.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];

            }
            
        } failureBlock:^(NSError *error) {
            
            NSLog(@"error %@",error);
        }];
    }

}
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.clipsToBounds = YES;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;//等比例拉伸填充
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

@end
