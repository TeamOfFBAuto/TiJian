//
//  GcommentTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//


//评论自定义cell

#import <UIKit/UIKit.h>
#import "ProductCommentModel.h"

@interface GcommentTableViewCell : UITableViewCell

-(CGFloat)loadCustomViewWithModel:(ProductCommentModel*)model;

@end
