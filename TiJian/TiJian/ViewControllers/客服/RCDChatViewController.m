//
//  RCDChatViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import "RCDChatViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDChatViewController.h"

#import "GproductDetailViewController.h"
#import "SimpleMessageCell.h"
#import "SimpleMessage.h"
#import "OrderInfoViewController.h"

#import "ProductModel.h"

@interface RCDChatViewController ()
{
    NSString *_orderId;
    NSString *_orderNum;
    ProductModel *_p_model;
}

@end

@implementation RCDChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = IOS7_OR_LATER ? -10 : 5;
    
    UIButton *button_back=[[UIButton alloc]initWithFrame:CGRectMake(10,8,40,44)];
    [button_back addTarget:self action:@selector(leftBarButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button_back setImage:BACK_DEFAULT_IMAGE forState:UIControlStateNormal];
    [button_back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIBarButtonItem *back_item=[[UIBarButtonItem alloc]initWithCustomView:button_back];
    self.navigationItem.leftBarButtonItems=@[spaceButton1,back_item];
    
 
    UILabel *_myTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,44)];
    _myTitleLabel.textAlignment = NSTextAlignmentCenter;
    _myTitleLabel.text = self.userName;
    _myTitleLabel.textColor = DEFAULT_TEXTCOLOR;
    _myTitleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = _myTitleLabel;
    
    //会话页面注册 UI
    [self registerClass:SimpleMessageCell.class forCellWithReuseIdentifier:@"SimpleMessageCell"];
    
}


/**
 *  发送订单信息
 *
 *  @param orderId  订单id
 *  @param orderNum 订单num
 */
-(void)setOrderMessageWithOrderId:(NSString *)orderId
                                orderNum:(NSString *)orderNum
{
    _orderId = orderId;
    _orderNum = orderNum;
    //发送订单图文消息
    if (_orderId) {
        
        [self sendOrderDetailMessageWithOrderId:_orderId orderNum:_orderNum];
    }
}

- (void)sendOrderDetailMessageWithOrderId:(NSString *)orderId orderNum:(NSString *)orderNum
{
    NSString *imageUrl = @"http://123.57.51.27:86/order.jpg";
    NSString *digest = @"";
    
    NSString *orderInfo = [NSString stringWithFormat:@"orderId=%@",orderId];
    NSString *title = [NSString stringWithFormat:@"订单编号:%@",orderNum];
    RCRichContentMessage *msg = [RCRichContentMessage messageWithTitle:title digest:digest imageURL:imageUrl extra:orderInfo];
    
    [[RCIM sharedRCIM]sendMessage:ConversationType_CUSTOMERSERVICE targetId:SERVICE_ID content:msg pushContent:@"客服消息" pushData:nil success:^(long messageId) {
        DDLOG(@"messageid %ld",messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        DDLOG(@"nErrorCode %ld",(long)nErrorCode);
    }];
}

/**
 *  复制单品详情图文消息
 *
 *  @param aModel 单品model
 */
- (void)setProductMessageWithProductModel:(ProductModel *)aModel
{
    _p_model = aModel;
    
    //发送单品图文消息
    if (_p_model) {
        [self sendProductDetailMessageWithId:_p_model.product_id productName:_p_model.setmeal_name coverImageUrl:_p_model.cover_pic currentPrice:[_p_model.setmeal_original_price floatValue] originalPrice:[_p_model.setmeal_price floatValue]];
    }
}

//发送产品图文链接

-(void)sendProductDetailMessageWithId:(NSString *)productId
                          productName:(NSString *)productName
                        coverImageUrl:(NSString *)coverImageUrl
                         currentPrice:(CGFloat)currentPrice
                        originalPrice:(CGFloat)originalPrice
{
    NSString *imageUrl = coverImageUrl;
    NSString *digest = [NSString stringWithFormat:@"\n现价:%.2f元\n原价:%.2f元",currentPrice,originalPrice];
    
    NSString *extra = [NSString stringWithFormat:@"productId=%@",productId];
    
    NSString *title = [NSString stringWithFormat:@"我在看:[%@]",productName];
    
    RCRichContentMessage *msg = [RCRichContentMessage messageWithTitle:title digest:digest imageURL:imageUrl extra:extra];
    [[RCIM sharedRCIM]sendMessage:ConversationType_CUSTOMERSERVICE targetId:SERVICE_ID content:msg pushContent:@"客服消息" pushData:nil success:^(long messageId) {
        DDLOG(@"messageid %ld",messageId);
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        DDLOG(@"nErrorCode %ld",(long)nErrorCode);
        
    }];    
}

#pragma - mark 自定义消息重写方法

-(RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCMessageModel *model = self.conversationDataRepository[indexPath.row];
    NSString * cellIndentifier=@"SimpleMessageCell";
    RCMessageBaseCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIndentifier           forIndexPath:indexPath];
    
    [cell setDataModel:model];
    return cell;
}
-(CGSize)rcConversationCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //返回自定义cell的实际高度
    return CGSizeMake(300, 60 + 5 + 50);
}

-(void) leftBarButtonItemPressed:(id)sender
{
    //需要调用super的实现
    [super leftBarButtonItemPressed:sender];
    
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
-(void) rightBarButtonItemClicked:(id) sender
{
    //客服设置
    if(self.conversationType == ConversationType_CUSTOMERSERVICE){
        RCSettingViewController *settingVC = [[RCSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        //清除聊天记录之后reload data
        __weak RCDChatViewController *weakSelf = self;
        settingVC.clearHistoryCompletion = ^(BOOL isSuccess)
        {
            if (isSuccess) {
                [weakSelf.conversationDataRepository removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.conversationMessageCollectionView reloadData];
                });
            }
        };
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
}


/**
 *  更新左上角未读消息数
 */
-(void)notifyUpdateUnReadMessageCount
{
    __weak typeof(&*self) __weakself = self;
    int count = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (count > 0) {
            [__weakself.navigationItem.leftBarButtonItem setTitle:[NSString stringWithFormat:@"返回(%d)",count]];
        }else
        {
            [__weakself.navigationItem.leftBarButtonItem setTitle:@"返回"];
        }
    });
}

/**
 *  点击消息内容中的链接，此事件不会再触发didTapMessageCell
 *
 *  @param url   Url String
 *  @param model 数据
 */
- (void)didTapUrlInMessageCell:(NSString *)url model:(RCMessageModel *)model
{
    RCRichContentMessage *msg = (RCRichContentMessage *)model.content;
    
    NSLog(@"model %@",msg.extra);
    
    NSString *extra = msg.extra;
    
    //单品
    if ([extra containsString:@"productId="]) {
        
        NSString *productId = @"";
        NSArray *arr = [msg.extra componentsSeparatedByString:@"productId="];
        if (arr.count > 1) {
            
            productId = arr.lastObject;
        }else
        {
            return;
        }
        
        if (productId.length) {
            
            GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
            cc.productId = productId;
            cc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:cc animated:YES];
        }else
        {
            NSLog(@"单品id有误");
        }
    }
    //订单
    else if ([extra containsString:@"orderId="]){
        
        NSString *orderId = @"";
        NSArray *arr = [msg.extra componentsSeparatedByString:@"orderId="];
        if (arr.count > 1) {
            
            orderId = arr.lastObject;
        }else
        {
            return;
        }
        
        if (orderId.length) {
            
            OrderInfoViewController *cc = [[OrderInfoViewController alloc]init];
            cc.order_id = orderId;
            cc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:cc animated:YES];
        }else
        {
            NSLog(@"订单id有误");
        }
    }
}

/**
 *  点击消息内容中的电话号码，此事件不会再触发didTapMessageCell
 *
 *  @param phoneNumber Phone number
 *  @param model       数据
 */
- (void)didTapPhoneNumberInMessageCell:(NSString *)phoneNumber model:(RCMessageModel *)model
{
    NSLog(@"phoneNumber %@",phoneNumber);
}


/**
 *  消息发送状态通知
 *
 *  @param notification 通知对象
 */
- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification
{
    NSLog(@"messageCellUpdateSendingStatusEvent %@",notification);
}

@end
