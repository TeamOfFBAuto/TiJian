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

@protocol RefreshDelegate <NSObject>

@optional

- (void)loadNewDataForTableView:(UITableView *)tableView;
- (void)loadMoreDataForTableView:(UITableView *)tableView;

//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView;
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView;

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView;

//meng新加
-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView;
-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView;

//将要显示
- (void)refreshTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
//显示完了
- (void)refreshTableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0);

@end

@interface RefreshTableView : UITableView<L_EGORefreshTableDelegate,UITableViewDataSource,UITableViewDelegate>
{
    BOOL _neverShowLoadMore;//是否永远不显示加载更多
    
    int _dataArrayCount;//数据源个数
}


@property (nonatomic,retain)RefreshHeaderView * refreshHeaderView;

@property (nonatomic,weak)id<RefreshDelegate>refreshDelegate;
@property (nonatomic,assign)BOOL                        isReloadData;      //是否是下拉刷新数据
@property (nonatomic,assign)BOOL                        reloading;         //是否正在loading
@property (nonatomic,assign)BOOL                        isLoadMoreData;    //是否是载入更多
@property (nonatomic,assign)BOOL                        isHaveMoreData;    //是否还有更多数据,决定是否有更多view

@property (nonatomic,assign)int pageNum;//页数
@property (nonatomic,retain)NSMutableArray *dataArray;//数据源

@property(nonatomic,retain)UIActivityIndicatorView *loadingIndicator;
@property(nonatomic,retain)UILabel *normalLabel;
@property(nonatomic,retain)UILabel *loadingLabel;
@property(nonatomic,assign)BOOL hiddenLoadMore;//隐藏加载更多,默认隐藏


-(void)createHeaderView;
-(void)removeHeaderView;

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos;
-(void)showRefreshHeader:(BOOL)animated;//代码出发刷新
- (void)finishReloadigData;

-(void)showRefreshNoOffset;//无偏移刷新数据

- (void)reloadData:(NSArray *)data total:(int)totalPage;//更新数据
- (void)reloadData:(NSArray *)data isHaveMore:(BOOL)isHave;
- (void)reloadData:(NSArray *)data pageSize:(int)pageSize;//根据pageSize判断是否有更多

- (void)loadFail;//请求数据失败

-(id)initWithFrame:(CGRect)frame showLoadMore:(BOOL)show;

-(id)initWithFrame:(CGRect)frame superView:(UIView *)superView;

//买衣日志扩展
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)theStyle;
- (void)reloadData1:(NSArray *)data1 pageSize:(int)pageSize;

//万聚鲜城活动详情扩展
- (void)reloadDataSuccess:(NSArray *)data isHaveMore:(BOOL)isHave;

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

/**
 *  请求数据失败 显示自定义view
 *
 *  @param view
 */
- (void)loadFailWithView:(UIView *)view
                pageSize:(int)pageSize;

@end
