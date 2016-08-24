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
#import "GoHealthProductDetailController.h"//go健康产品详情、服务详情
#import "GoHealthBugController.h" //go健康购买
#import "ConfirmOrderViewController.h"//确认订单
#import "PayActionViewController.h"//支付页面
#import "GoHealthAppointViewController.h"//go健康预约
#import "OrderProductListController.h"//go健康 订单产品清单

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
    
    if (model) {
        chatService.msg_model = model;
    }
    
//    SourceType_ProductDetail = 1,
//    /**
//     *  来源自订单详情
//     */
//    SourceType_Order,
//    /**
//     *  来源自单品详情
//     */
//    SourceType_ProductDetail_goHealth,
//    /**
//     *  来源自订单详情
//     */
//    SourceType_Order_goHealth
    
    if (type == SourceType_ProductDetail_goHealth ||
        type == SourceType_Order_goHealth) {
        
        chatService.platType = PlatformType_goHealth;
    }else
    {
        chatService.platType = PlatformType_default;
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
    
    NSString *centerId = extendParams[@"centerId"];
    NSString *centerName = extendParams[@"centerName"];
    
    if ([[extendParams stringValueForKey:@"downType"] intValue] == 1) {//立即预约
        cc.theDownType = TheDownViewType_yuyue;
        [cc setDownViewOfYueyu:productId centerId:centerId centerName:centerName];
    }
    
    [viewController.navigationController pushViewController:cc animated:YES];
}

/**
 *  查看产品详情(海马、go健康)
 *
 *  @param productId
 *  @param platType          区分海马、go健康
 *  @param viewController
 *  @param extendParams
 *  @param updateParamsBlock
 */
+ (void)pushToProductDetailWithProductId:(NSString *)productId
                                platType:(PlatformType)platType
                          viewController:(UIViewController *)viewController
                            extendParams:(NSDictionary *)extendParams
                       updateParamsBlock:(UpdateParamsBlock)updateParamsBlock
{
    if (platType == PlatformType_default) //海马
    {
        GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
        cc.productId = productId;
        [viewController.navigationController pushViewController:cc animated:YES];
    }
    else if (platType == PlatformType_goHealth) //go健康
    {
        GoHealthProductDetailController *detail = [[GoHealthProductDetailController alloc]init];
        detail.productId = productId;
        [viewController.navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark - 订单

/**
 *  订单再次购买
 *
 *  @param platformType   区分海马、go健康
 *  @param products       产品数组(ProductModel或者NSDictionary)
 *  @param viewController
 *  @param extendParams
 */
+ (void)pushToAgainBuyOrderType:(PlatformType)platformType
                       products:(NSArray *)products
             viewController:(UIViewController *)viewController
               extendParams:(NSDictionary *)extendParams
{
    if (platformType == PlatformType_goHealth) { //go健康
        
        id object = [products firstObject];
        if (object) {
            
            NSString *productId;
            if ([LTools isDictinary:object]) //字典
            {
                productId = object[@"product_id"];
                
            }else if ([object isKindOfClass:[ProductModel class]])
            {
                productId = ((ProductModel *)object).product_id;
            }
            GoHealthBugController *buy = [[GoHealthBugController alloc]init];
            buy.productId = productId;
            [viewController.navigationController pushViewController:buy animated:YES];
        }
    }else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:products.count];
        for (id object in products) {
            
            ProductModel *aModel;
            if ([object isKindOfClass:[ProductModel class]]) {
                aModel = object;
            }else if ([LTools isDictinary:object])
            {
                aModel = [[ProductModel alloc]initWithDictionary:object];
            }
            [temp addObject:aModel];
        }
        NSArray *productArr = temp;
        ConfirmOrderViewController *confirm = [[ConfirmOrderViewController alloc]init];
        confirm.dataArray = productArr;
        confirm.lastViewController = viewController;
        [viewController.navigationController pushViewController:confirm animated:YES];
    }
}

/**
 *  订单支付
 *
 *  @param orderId        订单id
 *  @param orderNum       订单num 201600010
 *  @param sumPrice       总实付价格
 *  @param payStyle       //1 支付宝 2 微信
 *  @param platformType  平台区分 海马、go健康
 *  @param viewController
 *  @param extendParams
 */
+ (void)pushToPayOrderId:(NSString *)orderId
                orderNum:(NSString *)orderNum
                sumPrice:(CGFloat)sumPrice
                payStyle:(int)payStyle
            platformType:(PlatformType)platformType
          viewController:(UIViewController *)viewController
            extendParams:(NSDictionary *)extendParams

{
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
    pay.sumPrice = sumPrice;
    pay.payStyle = payStyle;
    pay.platformType = platformType;
    pay.lastViewController = viewController;
    [viewController.navigationController pushViewController:pay animated:YES];
}

/**
 *  前去预约(海马、go健康)
 *
 *  @param platformType   区分海马、go健康
 *  @param orderid        订单id
 *  @param products       产品
 *  @param viewController
 *  @param extendParams
 */
+ (void)pushToAppointPlatformType:(PlatformType)platformType
                          orderId:(NSString *)orderid
                         products:(NSArray *)products
                   viewController:(UIViewController *)viewController
                     extendParams:(NSDictionary *)extendParams

{
    if (platformType == PlatformType_default)//海马
    {
        [self pushToAppointHaimaProducts:products orderId:orderid viewController:viewController extendParams:extendParams];
        
    }else if (platformType == PlatformType_goHealth)//go健康
    {
        [self pushToAppointGoHealthProducts:products orderId:orderid viewController:viewController extendParams:extendParams];
    }
}

/**
 *  预约海马
 *
 *  @param products       产品列表
 *  @param orderId        订单id
 *  @param viewController
 *  @param extendParams
 */
+ (void)pushToAppointHaimaProducts:(NSArray *)products
                           orderId:(NSString *)orderId
                    viewController:(UIViewController *)viewController
                      extendParams:(NSDictionary *)extendParams
{
    OrderProductListController *list = [[OrderProductListController alloc]init];
    list.orderId = orderId;
    list.platformType = PlatformType_default;
    [viewController.navigationController pushViewController:list animated:YES];
}

/**
 *  预约go健康
 *
 *  @param aModel
 */
+ (void)pushToAppointGoHealthProducts:(NSArray *)products
                              orderId:(NSString *)orderId
                       viewController:(UIViewController *)viewController
                         extendParams:(NSDictionary *)extendParams
{
    if (products.count == 1)//只有一个
    {
        NSDictionary *p_dic = [products firstObject];
        if ([LTools isDictinary:p_dic])
        {
            NSString *product_num = p_dic[@"product_num"];
            NSString *product_id = p_dic[@"product_id"];
            NSString *product_name = p_dic[@"product_name"];
            
            if ([product_num intValue] == 1) {
                GoHealthAppointViewController *goHealthAppoint = [[GoHealthAppointViewController alloc]init];
                goHealthAppoint.orderId = orderId;
                goHealthAppoint.productId = product_id;
                goHealthAppoint.productName = product_name;
                [viewController.navigationController pushViewController:goHealthAppoint animated:YES];
                return;
            }
        }
    }
    OrderProductListController *list = [[OrderProductListController alloc]init];
    list.orderId = orderId;
    list.platformType = PlatformType_goHealth;
    [viewController.navigationController pushViewController:list animated:YES];
}

#pragma mark - 挂号网相关

/**
 *  点击跳转至挂号网对接
 *
 *  @param familiyuid type为2时,转诊预约（VIP）需要此参数
 */
+ (void)pushToGuaHaoType:(int)type
               familyuid:(NSString *)familyuid
          viewController:(UIViewController *)viewController
            hiddenBottom:(BOOL)hiddenBottom
       updateParamsBlock:(UpdateParamsBlock)updateParamsBlock
            extendParams:(NSDictionary *)extendParams
{
    
    [LoginManager isLogin:viewController loginBlock:^(BOOL success) {
        if (success) {
            
            WebviewController *web = [[WebviewController alloc]init];
            web.guaHao = YES;
            web.type = type;
            web.familyuid = familyuid;
            web.hidesBottomBarWhenPushed = hiddenBottom;
            web.updateParamsBlock = updateParamsBlock;
            [viewController.navigationController pushViewController:web animated:YES];
        }
    }];
    
    
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
        
        DDLOG(@"%ld %ld",(long)receivedSize,expectedSize);
        
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

#pragma mark - 友盟统计

-(void)umengEvent:(NSString *)eventId attributes:(NSDictionary *)attributes number:(NSNumber *)number{
    NSString *numberKey = @"__ct__";
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [mutableDictionary setObject:[number stringValue] forKey:numberKey];
    [MobClick event:eventId attributes:mutableDictionary];
}


#pragma mark go健康

/**
 *  go健康对接签名
 *
 *  @param params 需要的参数
 *
 *  @return
 */
+ (NSString *)goHealthSignWithParams:(NSDictionary *)params
{
    //①对参数按照key=value的格式,并按照参数名ASCII字典序排序如下
    //按字典升序
    NSArray *allkeys = [params allKeys];
    NSArray *tempKeys = [allkeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    //key=value的格式拼接
    NSString *tempKey = [tempKeys firstObject];
    NSString *tempValue = params[tempKey];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@=%@",tempKey,tempValue];
    for (int i = 1 ; i < tempKeys.count; i ++) {
        tempKey = tempKeys[i];
        tempValue = params[tempKey];
        NSString *param = [NSString stringWithFormat:@"&%@=%@",tempKey,tempValue];
        [url appendString:param];
    }
    NSLog(@"url:%@",url);
    
    //②拼接API密钥(appSecret)
    NSString *stringSignTemp = [NSString stringWithFormat:@"%@&key=%@",url,GoHealthAppSecret];
    
    //③进行MD5运算,再将得到的字符串所有字符转换为大写,得到sign值signValue
    stringSignTemp = [LTools md5:stringSignTemp];
    NSString *sign = [stringSignTemp uppercaseString];//转大写
    
    return sign;
}

/**
 *  跳转至go健康服务详情
 *
 *  @param serviceId       服务id
 *  @param productId       套餐产品id
 *  @param orderNum        订单id
 *  @param controller
 *  @param extensionParams 拓展参数备用
 */
+ (void)pushToGoHealthServiceId:(NSString *)serviceId
                      productId:(NSString *)productId
                       orderNum:(NSString *)orderNum
             fromViewController:(UIViewController *)controller
                extensionParams:(NSDictionary *)extensionParams
{
    GoHealthProductDetailController *detail = [[GoHealthProductDetailController alloc]init];
    detail.detailType = DetailType_serviceDetail;
    detail.serviceId = serviceId;
    detail.productId = productId;
    detail.orderNum = orderNum;
    if (extensionParams && [LTools isDictinary:extensionParams]) {
        detail.report_html = extensionParams[@"report_html"];
    }
    [controller.navigationController pushViewController:detail animated:YES];
}


@end
