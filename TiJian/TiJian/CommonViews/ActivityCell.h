//
//  TiJian
//
//  Created by lichaowei on 16/1/5.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  活动消息cell
 */

#import "BasicTableViewCell.h"

@interface ActivityCell : BasicTableViewCell

/**
 *  计算cell高度
 *
 *  @param existImage 是否存在封面
 *  @param content    摘要
 *
 *  @return
 */
+ (CGFloat)heightForCellWithImage:(BOOL)existImage
                          content:(NSString *)content;

@end
