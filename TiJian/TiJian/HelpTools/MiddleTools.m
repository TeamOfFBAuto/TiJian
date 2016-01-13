//
//  MIddleTools.m
//  TiJian
//
//  Created by lichaowei on 15/12/7.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MiddleTools.h"
#import "RCDChatViewController.h"
#import "OrderModel.h"
#import "ProductModel.h"

@implementation MiddleTools

/**
 *  开启客服聊天
 *
 *  @param type           区分来源自单品详情、订单详情
 *  @param viewController tagerViewController
 *  @param model          单品model、或者订单model
 */
+ (void)pushToChatWithSourceType:(SourceType)type
              fromViewController:(UIViewController *)viewController
                           model:(id)model
{
    [self pushToChatWithSourceType:type fromViewController:viewController model:model hiddenBottom:NO];
}

/**
 *  开启客服聊天
 *
 *  @param type           区分来源自单品详情、订单详情
 *  @param viewController tagerViewController
 *  @param model          单品model、或者订单model
 *  @param hiddenBottom   是否隐藏底部
 */
+ (void)pushToChatWithSourceType:(SourceType)type
              fromViewController:(UIViewController *)viewController
                           model:(id)model
                    hiddenBottom:(BOOL)hiddenBottom
{
    RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
    chatService.userName = @"河马客服";
    
//    //1.0
//    chatService.targetId = SERVICE_ID;
//    chatService.conversationType = ConversationType_CUSTOMERSERVICE;//客服1.0
    
    //2.0
    chatService.targetId = SERVICE_ID_2;
    chatService.conversationType = ConversationType_APPSERVICE;//客服2.0
    
    chatService.title = chatService.userName;
    
//    if (type == SourceType_ProductDetail) {
//        [chatService setProductMessageWithProductModel:model];
//    }else if (SourceType_Order){
//        [chatService setOrderMessageWithOrderId:((OrderModel *)model).order_id orderNum:((OrderModel *)model).order_no];
//    }
    //
    if (model) {
        chatService.msg_model = model;
    }
    
    chatService.hidesBottomBarWhenPushed = hiddenBottom;
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        [((UINavigationController *)viewController)pushViewController:chatService animated:YES];
    }else
    {
        [viewController.navigationController pushViewController:chatService animated:YES];
    }
    
}



@end
