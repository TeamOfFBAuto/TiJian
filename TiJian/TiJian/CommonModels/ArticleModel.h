//
//  ArticleModel.h
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  健康资讯文章model
 */

#import "BaseModel.h"

@interface ArticleModel : BaseModel
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *summary;
@property(nonatomic,retain)NSString *add_time;
@property(nonatomic,retain)NSString *cover_pic;
@property(nonatomic,retain)NSString *cover_pic_width;
@property(nonatomic,retain)NSString *cover_pic_height;
@property(nonatomic,retain)NSString *url;

@end
