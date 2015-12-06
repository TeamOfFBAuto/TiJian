//
//  ResultView.h
//  TiJian
//
//  Created by lichaowei on 15/12/4.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  展示结果(无数据、网络有问题等)
 */

#import <UIKit/UIKit.h>

@interface ResultView : UIView

@property(nonatomic,retain)UIImageView *imageView;
@property(nonatomic,retain)UILabel *titleLabel;
@property(nonatomic,retain)UILabel *contentLabel;

@property(nonatomic,retain)UIView *bottomView;//支持自定义

/**
 *  页面结果view
 *
 *  @param image   显示图标(可不填)
 *  @param title   标题(可不填)
 *  @param content 正文(可不填)
 *
 *  @return
 */
-(instancetype)initWithImage:(UIImage *)image
                       title:(NSString *)title
                     content:(NSString *)content;

@end
