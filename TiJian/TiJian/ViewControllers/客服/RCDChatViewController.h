//
//  RCDChatViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface RCDChatViewController : RCConversationViewController

/**
 *  会话数据模型
 */
@property (strong,nonatomic) RCConversationModel *conversation;

/**
 *  发送订单信息
 *
 *  @param orderId  订单id
 *  @param orderNum 订单num
 */
-(void)setOrderMessageWithOrderId:(NSString *)orderId
                         orderNum:(NSString *)orderNum;

/**
 *  复制单品详情图文消息
 *
 *  @param aModel 单品model
 */
- (void)setProductMessageWithProductModel:(id)aModel;

@end
