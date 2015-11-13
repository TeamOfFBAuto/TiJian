//
//  ProductCommentModel.h
//  TiJian
//
//  Created by gaomeng on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "BaseModel.h"

@interface ProductCommentModel : BaseModel

@property(nonatomic,strong)NSString *comment_id;
@property(nonatomic,strong)NSString *product_id;
@property(nonatomic,strong)NSString *uid;
@property(nonatomic,strong)NSString *order_no;
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSString *add_time;
@property(nonatomic,strong)NSString *is_anony;
@property(nonatomic,strong)NSString *star;
@property(nonatomic,strong)NSString *username;
@property(nonatomic,strong)NSString *avatar;
@property(nonatomic,strong)NSArray *comment_pic;
@property(nonatomic,strong)NSArray *comment_reply;




@end
