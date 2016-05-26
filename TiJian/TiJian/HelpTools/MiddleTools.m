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
#import "WebviewController.h"//内置浏览器
#import "GproductDetailViewController.h"//单品详情

#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "MBProgressHUD.h"

@interface MiddleTools ()<UMSocialUIDelegate>
{
    NSString *_shareTitle;
    NSString *_shareContent;
    NSString *_shareUrl;
    MBProgressHUD *_loading;
}
@end

@implementation MiddleTools

+ (id)shareInstance
{
    static dispatch_once_t once_t;
    static MiddleTools *middle;
    dispatch_once(&once_t, ^{
        middle = [[MiddleTools alloc]init];
    });
    return middle;
}

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
    chatService.chatTitle = @"海马客服";
    
//    //1.0
//    chatService.targetId = SERVICE_ID;
//    chatService.conversationType = ConversationType_CUSTOMERSERVICE;//客服1.0
    
    //2.0
    chatService.targetId = SERVICE_ID_2;
    chatService.conversationType = ConversationType_APPSERVICE;//客服2.0
    
//    chatService.title = chatService.userName;
    
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

/**
 *  内置浏览器
 *
 *  @param viewController
 *  @param weburl         访问地址url
 *  @param title          标题
 *  @param moreInfo       是否显示右上角更多按钮
 *  @param hiddenBottom   隐藏底部tabbar
 */
+ (void)pushToWebFromViewController:(UIViewController *)viewController
                             weburl:(NSString *)weburl
                              title:(NSString *)title
                           moreInfo:(BOOL)moreInfo
                       hiddenBottom:(BOOL)hiddenBottom
{
    WebviewController *web = [[WebviewController alloc]init];
    web.webUrl = weburl;
    web.navigationTitle = title;
    web.moreInfo = moreInfo;
    web.hidesBottomBarWhenPushed = hiddenBottom;
    [viewController.navigationController pushViewController:web animated:YES];
}

/**
 *  内置浏览器
 *
 *  @param viewController
 *  @param weburl         访问地址url
 *  @param extensionParams  根据需要拓展参数
 *  @param moreInfo       右侧是否显示两个按钮
 *  @param hiddenBottom   隐藏底部tabbar
 *  @param updateParamsBlock   方便数据回调block
 *  @param
 */
+ (void)pushToWebFromViewController:(UIViewController *)viewController
                             weburl:(NSString *)weburl
                    extensionParams:(NSDictionary *)extensionParams
                           moreInfo:(BOOL)moreInfo
                       hiddenBottom:(BOOL)hiddenBottom
                updateParamsBlock:(UpdateParamsBlock)updateParamsBlock
{
    WebviewController *web = [[WebviewController alloc]init];
    web.webUrl = weburl;
    web.extensionParams = extensionParams;
    web.moreInfo = moreInfo;
    web.updateParamsBlock = updateParamsBlock;
    web.hidesBottomBarWhenPushed = hiddenBottom;
    [viewController.navigationController pushViewController:web animated:YES];
}

/**
 *  跳转至单品详情
 *
 *  @param productId      id
 *  @param viewController
 *  @param prams 增加拓张性
 */
+ (void)pushToProductDetailWithProductId:(NSString *)productId
                           viewController:(UIViewController *)viewController
                                   extendParams:(NSDictionary *)extendParams
{
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    cc.productId = productId;
    [viewController.navigationController pushViewController:cc animated:YES];
}

#pragma mark - 分享

/**
 *  分享
 *
 *  @param controller
 *  @param shareImageUrl  分享图片链接url
 *  @param shareTitle   标题
 *  @param shareContent 摘要
 *  @param linkUrl      链接
 */

-(void)shareFromViewController:(UIViewController *)controller
            withImageUrl:(NSString *)shareImageUrl
           shareTitle:(NSString *)shareTitle
         shareContent:(NSString *)shareContent
              linkUrl:(NSString *)linkUrl
{
    //分享
    UIImage *appImage = [UIImage imageNamed:@"icon180"];//默认appIcon图片

//    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:shareImageUrl];
//    [self shareFromViewController:controller withImage:appImage shareTitle:shareTitle shareContent:shareContent linkUrl:linkUrl];

    NSURL *url = [NSURL URLWithString:shareImageUrl];
    __weak typeof(self) weakself = self;
    [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
    [[SDWebImageManager sharedManager]downloadImageWithURL:url options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        DDLOG(@"%ld %ld",receivedSize,expectedSize);
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // code here
            [MBProgressHUD hideHUDForView:controller.view animated:YES];
            [weakself shareFromViewController:controller withImage:(image ? image : appImage) shareTitle:shareTitle shareContent:shareContent linkUrl:linkUrl];
        });
    }];
}
/**
 *  分享
 *
 *  @param controller
 *  @param shareImage   分享UIImage对象
 *  @param shareTitle   标题
 *  @param shareContent 摘要
 *  @param linkUrl      链接
 */
- (void)shareFromViewController:(UIViewController *)controller
              withImage:(UIImage *)shareImage
            shareTitle:(NSString *)shareTitle
          shareContent:(NSString *)shareContent
               linkUrl:(NSString *)linkUrl
{
    _shareTitle = shareTitle;
    _shareContent = shareContent;
    _shareUrl = linkUrl;
    if ([LTools isEmpty:linkUrl]) {
        _shareUrl = AppDownloadUrl;
    }
    
    NSArray *snsNames = @[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone,UMShareToSina];
    //调用快速分享接口
    [UMSocialSnsService presentSnsIconSheetView:controller
                                         appKey:UmengAppkey
                                      shareText:shareContent
                                     shareImage:shareImage
                                shareToSnsNames:snsNames
                                       delegate:self];
}

#pragma mark - 分享 UMSocialUIDelegate <NSObject>

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    NSString *url = _shareUrl;
    NSString *title = _shareTitle;
    NSString *share_content = _shareContent;
    
    socialData.title = title;
    
    if ([platformName isEqualToString:UMShareToQQ]) {
        
        socialData.extConfig.qqData.url = url; //设置你自己的url地址;
        socialData.extConfig.qqData.title = title;
        
    }else if ([platformName isEqualToString:UMShareToSina]){
        
        NSString *content = [NSString stringWithFormat:@"%@%@",share_content,url];
        socialData.shareText = content;
        
    }else if ([platformName isEqualToString:UMShareToQzone]){
        //qqzone
        socialData.extConfig.qzoneData.url = url;
        socialData.extConfig.qzoneData.title = title;
        
    }else if ([platformName isEqualToString:UMShareToWechatSession]){ //微信好友
        
        socialData.extConfig.wechatSessionData.url = url; //设置你自己的url地址;
        socialData.extConfig.wechatSessionData.title = title;
        
    }else if ([platformName isEqualToString:UMShareToWechatTimeline]){ //朋友圈
        
        socialData.extConfig.wechatTimelineData.url = url; //设置你自己的url地址;
        socialData.extConfig.wechatTimelineData.title = title;
    }
}

@end
