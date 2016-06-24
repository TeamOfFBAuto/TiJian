//
//  MessageModel.h
//  TiJian
//
//  Created by lichaowei on 16/1/7.
//  Copyright © 2016年 lcw. All rights reserved.
//
/**
 *  消息、通知model
 */
#import "BaseModel.h"

@interface MessageModel : BaseModel

@property(nonatomic,retain)NSString *msg_id;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *content;
@property(nonatomic,retain)NSString *summary;//摘要
@property(nonatomic,retain)NSString *type;
//1、客服消息2、体检提醒消息（提前一天通知） theme_id: 预约详情id
//3、活动消息
//4、体检报告进度
//5、体检报告报告解读完成消息   theme_id: 体检报告id
//6、订单的退款状态    theme_id: 订单id
//pic: 封面图(可能为空)
@property(nonatomic,retain)NSString *theme_id;
@property(nonatomic,retain)NSString *is_read;//1 未读 2 已读
@property(nonatomic,retain)NSString *send_time;
@property(nonatomic,retain)NSString *pic;
@property(nonatomic,retain)NSString *pic_width;
@property(nonatomic,retain)NSString *pic_height;
@property(nonatomic,retain)NSString *url;//活动的详情url

@property(nonatomic,retain)NSString *app_id;//1:表示海马医生  2:表示go健康

@end
