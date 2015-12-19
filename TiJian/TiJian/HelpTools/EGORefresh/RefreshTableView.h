//
//  RefreshTableView.h
//  TuanProject
//
//  Created by 李朝伟 on 13-9-6.
//  Copyright (c) 2013年 lanou. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "LRefreshTableHeaderView.h"
#import "RefreshHeaderView.h"

@class HelperConnection;

@class RefreshTableView;

@protocol RefreshDelegate <NSObject>

@optional

- (void)loadNewDataForTableView:(RefreshTableView *)tableView;
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView;

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView;
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView;

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView;
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView;

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView;

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView;
-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView;

//将要显示
- (void)refreshTableView:(RefreshTableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
//显示完了
- (void)refreshTableView:(RefreshTableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0);

@end


/**
 *  数据源监控block
 *
 *  @param keyPath
 *  @param change  值得变化
 */
typedef void(^OBSERVERBLOCK)(NSString *keyPath,NSDictionary *change);


@interface RefreshTableView : UITableView<L_EGORefreshTableDelegate,UITableViewDataSource,UITableViewDelegate>
{
    
    int _dataArrayCount;//数据源个数
}

@property (nonatomic,weak)id<RefreshDelegate>refreshDelegate;

@property (nonatomic,assign)BOOL isHaveLoaded;    //是否已经加载过数据
@property (nonatomic,assign)int pageNum;//页数
@property (nonatomic,retain)NSMutableArray *dataArray;//数据源

@property(nonatomic,assign)BOOL hiddenLoadMoreWhenNoData;//没有更多数据时是否隐藏底部view,default YES
@property(nonatomic,assign)BOOL neverShowLoadMore;//是否永远不显示加载更多


@property (nonatomic,copy)OBSERVERBLOCK dataArrayObeserverBlock;//监控数据源


#pragma mark - 初始化

//-(id)initWithFrame:(CGRect)frame showLoadMore:(BOOL)show;

- (id)initWithFrame:(CGRect)frame;

/**
 *  创建refreshTableView
 *
 *  @param frame
 *  @param superView headerView的父视图
 *
 *  @return
 */
-(id)initWithFrame:(CGRect)frame superView:(UIView *)superView;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)theStyle;

#pragma mark - 刷新数据

-(void)showRefreshHeader:(BOOL)animated;//代码出发刷新
-(void)refreshNewData;//刷新数据 无偏移

#pragma mark - 完成数据加载

- (void)finishReloadigData;//完成加载操作
- (void)reloadData:(NSArray *)data total:(int)totalPage;//更新数据
- (void)reloadData:(NSArray *)data isHaveMore:(BOOL)isHave;
- (void)reloadData:(NSArray *)data pageSize:(int)pageSize;//根据pageSize判断是否有更多

/**
 *  成功加载数据reload 
 *  1、没有数据时显示自定义view
 *  2、当数据大于0小于一页时不显示底部加载view
 *
 *  @param data       每次请求数据
 *  @param pageSize   每页个数
 *  @param noDataView 自定义没有数据时view
 */
- (void)reloadData:(NSArray *)data
          pageSize:(int)pageSize
        noDataView:(UIView *)noDataView;

#pragma mark - 数据加载失败
/**
 *  请求数据失败 显示自定义view
 *
 *  @param view
 */
- (void)loadFailWithView:(UIView *)view
                pageSize:(int)pageSize;

- (void)loadFail;//请求数据失败

#pragma mark - other
/**
 *  移除没有没有数据时自定义视图
 */
- (void)removeNodataView;


-(void)setDataArrayObeserverBlock:(OBSERVERBLOCK)dataArrayObeserverBlock;
-(void)removeObserver;


@end
