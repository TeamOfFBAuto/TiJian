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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //设置tableView样式
    self.conversationListTableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf"];
    self.conversationListTableView.tableFooterView = [UIView new];
    
    //设置要显示的会话类型
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_APPSERVICE),@(ConversationType_CUSTOMERSERVICE)]];
    
    //自定义空会话的背景View。当会话列表为空时，将显示该View
    //UIView *blankView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    //blankView.backgroundColor=[UIColor redColor];
    //self.emptyConversationView=blankView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isClick = YES;
    [self setNavigationItemTitleView];
    
    [self notifyUpdateUnreadMessageCount];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //showConnectingStatusOnNavigatorBar设置为YES时，需要重写setNavigationItemTitleView函数来显示已连接时的标题。
    self.showConnectingStatusOnNavigatorBar = YES;
    [super updateConnectionStatusOnNavigatorBar];
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
        
        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
            RCDChatViewController *_conversationVC = [[RCDChatViewController alloc]init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.userName = @"客服";
            _conversationVC.title = model.conversationTitle;
            _conversationVC.conversation = model;
            _conversationVC.unReadMessage = model.unreadMessageCount;
            _conversationVC.enableNewComingMessageIcon=YES;//开启消息提醒
            _conversationVC.enableUnreadMessageIcon=YES;
            if (model.conversationType == ConversationType_SYSTEM) {
                _conversationVC.userName = @"系统消息";
                _conversationVC.title = @"系统消息";
            }
            [self.navigationController pushViewController:_conversationVC animated:YES];
        }
    }
    
}

@end
