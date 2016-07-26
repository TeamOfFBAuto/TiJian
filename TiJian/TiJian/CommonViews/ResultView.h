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

@property(nonatomic,retain)UIView *bottomView;//支持自定义

@property(nonatomic,retain)UIImage *image;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *content;

@property(nonatomic,strong)UIActivityIndicatorView *activityIndicationVeiw;//重新加载品牌信息的菊花

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



/**
 *  筛选页面结果无数据view
 *
 *  @param image   显示图标(可不填)
 *  @param title   标题(可不填)
 *  @param content 正文(可不填)
 *
 *  @return
 */
-(instancetype)initWithNoBrandImage:(UIImage *)image
                       title:(NSString *)title
                     content:(NSString *)content
                              width:(CGFloat)theWidth;


/**
 *  获取地区医院结果无数据view
 *
 *  @param image    显示图标
 *  @param title    标题
 *  @param content  正文
 *  @param theWidth 宽
 *
 *  @return
 */
-(instancetype)initWithNoHospitalImage:(UIImage *)image
                              title:(NSString *)title
                            content:(NSString *)content
                              width:(CGFloat)theWidth;

@end
