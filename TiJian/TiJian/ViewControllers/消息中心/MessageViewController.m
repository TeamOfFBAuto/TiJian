//
//  MessageViewController.m
//  TiJian
//
//  Created by lichaowei on 16/1/5.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "MessageViewController.h"
#import "RCDChatViewController.h"

@interface MessageViewController ()

@property (nonatomic,assign) BOOL isClick;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    
    [self setConversationPortraitSize:CGSizeMake(35, 30)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //设置tableView样式
    self.conversationListTableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf"];
    self.conversationListTableView.tableFooterView = [UIView new];
    self.conversationListTableView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    //设置要显示的会话类型
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_APPSERVICE)]];
//    @(ConversationType_CUSTOMERSERVICE) //客服1.0
    
    //自定义空会话的背景View。当会话列表为空时，将显示该View
    UIView *blankView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, DEVICE_HEIGHT - 64 - 50)];
    blankView.backgroundColor=DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    ResultView *view = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"] title:@"暂时没有会话" content:nil];
    [blankView addSubview:view];
    view.centerY = blankView.height / 3.f + 5;
    view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    self.emptyConversationView = blankView;
    self.isShowNetworkIndicatorView = NO;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isClick = YES;
//    [self setNavigationItemTitleView];
    
    [self notifyUpdateUnreadMessageCount];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //showConnectingStatusOnNavigatorBar设置为YES时，需要重写setNavigationItemTitleView函数来显示已连接时的标题。
    self.showConnectingStatusOnNavigatorBar = YES;
//    [super updateConnectionStatusOnNavigatorBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  点击进入会话界面
 *
 *  @param conversationModelType 会话类型
 *  @param model                 会话数据
 *  @param indexPath             indexPath description
 */
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    
    if (_isClick) {
        _isClick = NO;
        
        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL ||
            conversationModelType == RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
            
            RCDChatViewController *_conversationVC = [[RCDChatViewController alloc]init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.chatTitle = @"海马客服";
            _conversationVC.title = model.conversationTitle;
            _conversationVC.conversation = model;
            _conversationVC.unReadMessage = model.unreadMessageCount;
            _conversationVC.enableNewComingMessageIcon=YES;//开启消息提醒
            _conversationVC.enableUnreadMessageIcon=YES;
            if (model.conversationType == ConversationType_SYSTEM) {
                _conversationVC.chatTitle = @"系统消息";
                _conversationVC.title = @"系统消息";
            }
            [self.navigationController pushViewController:_conversationVC animated:YES];
        }
    }
    
}

/**
 *  重写方法，可以实现开发者自己添加数据model后，返回对应的显示的cell
 *
 *  @param tableView 表格
 *  @param indexPath 索引
 *
 *  @return RCConversationBaseTableCell
 */
- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView
                                  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
//    13\11
    static NSString *identify = @"RCConversationBaseCell";
    RCConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[RCConversationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.conversationTitle.font = [UIFont systemFontOfSize:13];
    cell.messageContentLabel.font = [UIFont systemFontOfSize:11];
//    cell.textLabel
    return cell;
}

#pragma mark override
/**
 *  重写方法，可以实现开发者自己添加数据model后，返回对应的显示的cell的高度
 *
 *  @param tableView 表格
 *  @param indexPath 索引
 *
 *  @return 高度
 */
- (CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160.f;
}

@end
