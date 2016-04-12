//
//  RefreshTableView.m
//  TuanProject
//s
//  Created by 李朝伟 on 13-9-6.
//  Copyright (c) 2013年 lanou. All rights reserved.
//

#import "RefreshTableView.h"

#define TABLEFOOTER_HEIGHT 50.f

@interface RefreshTableView ()

@property(nonatomic,retain)UIView *resultView;
@property(nonatomic,retain)UIActivityIndicatorView *loadingIndicator;
@property(nonatomic,retain)UILabel *normalLabel;
@property(nonatomic,retain)UILabel *loadingLabel;

@property (nonatomic,retain)RefreshHeaderView * refreshHeaderView;//顶部刷新view
@property (nonatomic,retain)RefreshFooterView *refreshFooterView;//底部加载更多view

-(void)createHeaderView;
-(void)removeHeaderView;
-(void)beginToReloadData:(EGORefreshPos)aRefreshPos;

@end

@implementation RefreshTableView

- (void)dealloc
{
    self.dataArray = nil;
    self.loadingIndicator = nil;
    self.normalLabel = nil;
    self.loadingLabel = nil;
    self.delegate = nil;
    _refreshHeaderView.delegate = nil;
    _refreshHeaderView = nil;
    NSLog(@"%s dealloc",__FUNCTION__);
}

#pragma mark - 初始化

- (id)initWithFrame:(CGRect)frame
{
    RefreshTableView *table = [self initWithFrame:frame style:UITableViewStylePlain];
    return table;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)theStyle
{
    self = [super initWithFrame:frame style:theStyle];
    if (self) {
        // Initialization code
        
        self.hiddenLoadMoreWhenNoData = YES;//当没有更多数据时,默认隐藏底部view
        self.neverShowLoadMore = NO;//默认显示加载更多
        self.pageNum = 1;
        self.dataArray = [NSMutableArray array];
        [self createHeaderView];
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
         superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.pageNum = 1;
        self.dataArray = [NSMutableArray array];
        self.delegate = self;
        [self createHeaderViewWithSuperView:superView];
        
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

#pragma mark - 刷新数据

//代码触发刷新
-(void)showRefreshHeader:(BOOL)animated
{
    self.isHaveLoaded = YES;//记录已经加载过数据
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.0];
        self.contentInset = UIEdgeInsetsMake(55.0f, 0.0f, 0.0f, 0.0f);
        [self scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
        [UIView commitAnimations];
    }
    else
    {
        self.contentInset = UIEdgeInsetsMake(55.0f, 0.0f, 0.0f, 0.0f);
        [self scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
    }
    
    [_refreshHeaderView setState:L_EGOOPullRefreshLoading];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self];
}

/**
 *  刷新数据 无偏移
 */
-(void)refreshNewData
{
    _isHaveLoaded = YES;
    
    _isReloadData = YES;
    
    _reloading = YES;
    
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadNewDataForTableView:)]) {
        
        self.pageNum = 1;
        [_refreshDelegate loadNewDataForTableView:self];
    }
}


#pragma mark - 完成数据加载

- (void)reloadData:(NSArray *)data isHaveMore:(BOOL)isHave
{
    self.isHaveMoreData = isHave;
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:data];

    [self finishReloadingData];
}

- (void)reloadDataWithNoFinishReloading:(NSArray *)data isHaveMore:(BOOL)isHave
{
    self.isHaveMoreData = isHave;
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:data];
    
}





/**
 *  reload 数据
 *
 *  @param data      每次请求数据
 *  @param totalPage 总页数
 */
- (void)reloadData:(NSArray *)data total:(int)totalPage
{
    BOOL isHaveMore = (self.pageNum < totalPage && data.count > 0) ? YES : NO;//当前页数 与 总页数比较

    [self reloadData:data isHaveMore:isHaveMore];
}

//成功加载
- (void)reloadData:(NSArray *)data pageSize:(int)pageSize
{
    BOOL isHaveMore = (data.count < pageSize || data.count == 0) ? NO : YES;//每页实际请求条数 与 每页条数
    [self reloadData:data isHaveMore:isHaveMore];
}

/**
 *  成功加载数据reload
 *
 *  @param data       每次请求数据
 *  @param pageSize   每页个数
 *  @param noDataView 自定义没有数据时view
 */
- (void)reloadData:(NSArray *)data
          pageSize:(int)pageSize
        noDataView:(UIView *)noDataView
{
    BOOL isHaveMore = (data.count < pageSize || data.count == 0) ? NO : YES;//每页实际请求条数 与 每页条数
    self.isHaveMoreData = isHaveMore;
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:data];
    [self finishReloadDataWithView:noDataView pageSize:pageSize];
}

/**
 *  成功加载数据reload
 *
 *  @param data       每次请求数据
 *  @param pageSize   每页个数
 *  @param noDataView 自定义没有数据时view
 */
- (void)reloadData:(NSArray *)data
          pageSize:(int)pageSize
        CustomNoDataView:(UIView *)noDataView
{
    BOOL isHaveMore = (data.count < pageSize || data.count == 0) ? NO : YES;//每页实际请求条数 与 每页条数
    self.isHaveMoreData = isHaveMore;
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:data];
    [self finishReloadDataWithCustomView:noDataView pageSize:pageSize];
}


//完成数据加载
- (void)finishReloadDataWithCustomView:(UIView *)noDataView
                        pageSize:(int)pageSize
{
    
    /**
     *  此处仅处理没有数据时的默认视图情况,顶部和底部加载view不在此处理
     */
    //没有数据时
    if (self.dataArray.count == 0) {
        
        if (self.tableFooterView != self.resultView) {
            [self.tableFooterView removeFromSuperview];
            self.resultView = noDataView;
            self.tableFooterView = self.resultView;
        }
    }
    //有数据
    else
    {
        if (self.tableFooterView == self.resultView) {
            
            [self.resultView removeFromSuperview];
            self.tableFooterView = nil;
        }
    }
    
    [self finishReloadingData];
    
}



//完成数据加载

- (void)finishReloadDataWithView:(UIView *)noDataView
                        pageSize:(int)pageSize
{
    
    NSLog(@"%s1",__FUNCTION__);
    
    /**
     *  此处仅处理没有数据时的默认视图情况,顶部和底部加载view不在此处理
     */
    //没有数据时
    if (self.dataArray.count == 0) {
        
        if (self.tableFooterView != self.resultView) {
            [self.tableFooterView removeFromSuperview];
            [self.resultView addSubview:noDataView];
            self.tableFooterView = self.resultView;
            noDataView.center = CGPointMake(_resultView.width/2.f, _resultView.height / 3.f);
        }
    }
    //有数据
    else
    {
        if (self.tableFooterView == self.resultView) {
            
            [self.resultView removeFromSuperview];
            self.tableFooterView = nil;
        }
    }
    
    [self finishReloadingData];

}

/**
 *  完成加载数据
 */
- (void)finishReloadingData
{
    [self reloadData];
    
    if (_isHaveMoreData) {
        
        if (self.tableFooterView != self.refreshFooterView || !self.tableFooterView) {
            self.tableFooterView = self.refreshFooterView;
        }
    }
    
    if (_isReloadData) { //刷新
        
        [self performSelector:@selector(finishLoadingNew) withObject:nil afterDelay:0];
        
    }else if (_isLoadMoreData){ //加载更多
        
        [self finishLoadingMore];
    }
}

//完成数据刷新加载或者第一次加载

- (void)finishLoadingNew
{
    DDLOG(@"%s",__FUNCTION__);
    
    _reloading = NO;
    if (_refreshHeaderView && _isReloadData) {
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        self.isReloadData = NO;
    }
    //设置数据个数
    [self setValue:[NSNumber numberWithInteger:_dataArray.count] forKey:@"_dataArrayCount"];
    
}

/**
 *  完成加载更多
 */
- (void)finishLoadingMore
{
    DDLOG(@"%s",__FUNCTION__);
    
    _reloading = NO;
    
    //是否正在加载更多
    if (!_isLoadMoreData) {
        
        return;
    }
    
    _isLoadMoreData = NO;
    //如果有更多数据,重新设置footerview  frame
    if (self.isHaveMoreData)
    {
        [self.refreshFooterView stopLoadingMoreStyle:RefreshLoadingMoreStyleDefault];//上拉加载更多
        
    }else {
        //没有更多数据,
        if (self.tableFooterView == self.refreshFooterView) {
            [self.refreshFooterView stopLoadingMoreStyle:RefreshLoadingMoreStyleNoMoreAndHidden];
            [self.refreshFooterView removeFromSuperview];
            _refreshFooterView = nil;
            self.tableFooterView = nil;
        }
    }
    //设置数据个数
    [self setValue:[NSNumber numberWithInteger:_dataArray.count] forKey:@"_dataArrayCount"];
    
}

#pragma mark - 数据加载失败


/**
 *  请求数据失败 显示自定义view
 *
 *  @param view
 */
- (void)loadFailWithView:(UIView *)view
                pageSize:(int)pageSize
{
    if (self.isLoadMoreData) {
        self.pageNum --;
        
        if (self.pageNum < 1) {
            self.pageNum = 1;
        }
    }
    
    self.isHaveMoreData = NO;
    
    [self finishReloadDataWithView:view pageSize:pageSize];
}


//请求数据失败

- (void)loadFail
{
    if (self.isLoadMoreData) {
        self.pageNum --;
        
        if (self.pageNum < 1) {
            self.pageNum = 1;
        }
    }
    [self finishReloadingData];
}

#pragma mark - other

/**
 *  移除没有数据视图
 */
- (void)removeNodataView
{
    if (self.tableFooterView == self.resultView) {
        [self.resultView removeFromSuperview];
        self.resultView = nil;
    }
}

-(UIView *)resultView
{
    if (_resultView) {
        return _resultView;
    }
    self.resultView = [[UIView alloc]initWithFrame:self.bounds];
    _resultView.backgroundColor = [UIColor clearColor];
    return _resultView;
}

//get 方法
-(RefreshFooterView *)refreshFooterView
{
    if (_refreshFooterView) {
        return _refreshFooterView;
    }
    _refreshFooterView = [[RefreshFooterView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.width, TABLEFOOTER_HEIGHT)];
    return _refreshFooterView;
}

/**
 *  创建headerView 需要制定父视图
 *
 *  @param superView 父视图
 */
-(void)createHeaderViewWithSuperView:(UIView *)superView
{
    if (_refreshHeaderView && _refreshHeaderView.superview) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[RefreshHeaderView alloc]initWithFrame:CGRectMake(0.0f,0.f, self.frame.size.width, self.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    [_refreshHeaderView refreshLastUpdatedDate];
    [superView addSubview:_refreshHeaderView];

}

-(void)createHeaderView
{
    if (_refreshHeaderView && _refreshHeaderView.superview) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[RefreshHeaderView alloc]initWithFrame:CGRectMake(0.0f,0.0f - self.bounds.size.height, self.frame.size.width, self.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];
}
-(void)removeHeaderView
{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = Nil;
}

#pragma mark - EGORefreshTableDelegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    [self beginToReloadData:aRefreshPos];
}

//根据刷新类型，是看是下拉还是上拉
-(void)beginToReloadData:(EGORefreshPos)aRefreshPos
{
    //  should be calling your tableviews data source model to reload
    _reloading = YES;
    if (aRefreshPos ==  EGORefreshHeader)
    {
        _isReloadData = YES;
        
        if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadNewDataForTableView:)]) {
            
            self.pageNum = 1;
            [_refreshDelegate loadNewDataForTableView:self];
        }
    }
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view
{
    return _reloading;
}
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshScrollViewDidScroll:)]) {
        [_refreshDelegate refreshScrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    // 下拉到最底部时显示更多数据
    
    if(_isHaveMoreData && scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height - 40)))
    {
        DDLOG_CURRENT_METHOD;
        if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadMoreDataForTableView:)]) {
            
            _isLoadMoreData = YES;

            [self.refreshFooterView startLoading];//开始加载数据
            
            self.pageNum ++;
            [_refreshDelegate loadMoreDataForTableView:self];
        }
    }
}

#pragma mark -
#pragma mark overide UITableViewDelegate methods
//将要显示
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshTableView:willDisplayCell:forRowAtIndexPath:)]) {
        
        [_refreshDelegate refreshTableView:(RefreshTableView *)tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}
//显示完了
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0)
{
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshTableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        
        [_refreshDelegate refreshTableView:(RefreshTableView *)tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0)
//{
//    
//    
//    return 100;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat aHeight = 0.0;
    
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(heightForRowIndexPath:tableView:)]) {
        aHeight = [_refreshDelegate heightForRowIndexPath:indexPath tableView:(RefreshTableView *)tableView];
    }
    
    return aHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(didSelectRowAtIndexPath:tableView:)]) {
        [_refreshDelegate didSelectRowAtIndexPath:indexPath tableView:(RefreshTableView *)tableView];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *aView;
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(viewForHeaderInSection:tableView:)]) {
        aView = [_refreshDelegate viewForHeaderInSection:section tableView:(RefreshTableView *)tableView];
    }
    return aView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat aHeight = 0.0;
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(heightForHeaderInSection:tableView:)]) {
        aHeight = [_refreshDelegate heightForHeaderInSection:section tableView:(RefreshTableView *)tableView];
    }
    return aHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *aView;
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(viewForFooterInSection:tableView:)]) {
        aView = [_refreshDelegate viewForFooterInSection:section tableView:(RefreshTableView *)tableView];
        return aView;
    }else{
        return [UIView new];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    CGFloat aHeight = 0.0;
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(heightForFooterInSection:tableView:)]) {
        aHeight = [_refreshDelegate heightForFooterInSection:section tableView:(RefreshTableView *)tableView];
        return aHeight;
    }else{
        return 0.5;
    }
    
    return 0.5;
}

#pragma mark -
#pragma mark overide UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == Nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

#pragma mark - 数据源监控
//监控数据源的block

-(void)setDataArrayObeserverBlock:(OBSERVERBLOCK)dataArrayObeserverBlock
{
    //监测数据源
    [self addObserver:self forKeyPath:@"_dataArrayCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    _dataArrayObeserverBlock = dataArrayObeserverBlock;
    
}

-(void)removeObserver
{
    if (_dataArrayObeserverBlock) {
        
        [self removeObserver:self forKeyPath:@"_dataArrayCount"];
    }
}

#pragma mark - NSKeyValueObserving

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.dataArrayObeserverBlock) {
        
        self.dataArrayObeserverBlock(keyPath,change);
    }
}

@end
