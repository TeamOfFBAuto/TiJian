//
//  MapViewController.m
//  YiYiProject
//
//  Created by gaomeng on 14/12/27.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "MapViewController.h"
#import "BMapKit.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NSDictionary+GJson.h"
@interface MapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKAnnotation,UIAlertViewDelegate,UIActionSheetDelegate>
{
    BMKMapView* _mapView;//地图
    BMKLocationService* _locService;//定位服务
    
    //信息字典
    NSMutableDictionary *_poiAnnotationDic;
    
    //用户定位数据
    BMKUserLocation *_userLocation;
    
    BMKPointAnnotation *_targetAnnocation;
    //导航按钮
    UIButton *_button_daohang;
    
    BOOL _isFirst;//是否是第一个
}

@property(nonatomic,retain)BMKPointAnnotation *targetAnnocation;

@end

@implementation MapViewController


- (void)dealloc {
    
    if (_mapView) {
        _mapView = nil;
    }
    
    if (_locService) {
        _locService = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [_mapView viewWillAppear];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    
    //停止定位
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
    
    //代理置空
    _mapView.delegate = nil;
    _locService.delegate = nil;
}


- (void)leftButtonTap:(UIButton *)sender
{
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    //导航栏
    UIView *daohangView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
//    UIImageView *imv = [[UIImageView alloc]initWithFrame:daohangView.bounds];
//    [imv setImage:[UIImage imageNamed:IOS7DAOHANGLANBEIJING_PUSH]];
//    [daohangView addSubview:imv];
    daohangView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:daohangView];
    
    //标题
    UILabel *_myTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,20,DEVICE_WIDTH - 100,44)];
    _myTitleLabel.textAlignment = NSTextAlignmentCenter;
    _myTitleLabel.text = self.titleName;
    _myTitleLabel.textColor = DEFAULT_TEXTCOLOR;
    _myTitleLabel.font = [UIFont systemFontOfSize:17];
    [daohangView addSubview:_myTitleLabel];

    _myTitleLabel.center = CGPointMake(DEVICE_WIDTH/2.f, _myTitleLabel.center.y);
    
    //返回按钮
    UIButton *button_back=[[UIButton alloc]initWithFrame:CGRectMake(7,20,40,44)];
    [button_back addTarget:self action:@selector(leftButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [button_back setImage:BACK_DEFAULT_IMAGE forState:UIControlStateNormal];
    [button_back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [daohangView addSubview:button_back];
    
    _isFirst = YES;
    
    //初始化地图
    [self setGMap];
    //初始化定位服务
    [self setGLocationService];
    
    //开启定位
    [self startFollowHeading];
    
    //初始化分配内存
    _poiAnnotationDic  = [[NSMutableDictionary alloc]init];
    
    [self addTargatMapAnnotation];
    
}


//跳转百度地图应用
-(void)gDaohang{
    
    UIActionSheet *acs = [[UIActionSheet alloc]initWithTitle:@"提示:是否跳转到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"百度地图",@"苹果地图", nil];
    [acs showInView:self.view];
}


#pragma mark - 添加地图标注

-(BMKPointAnnotation *)targetAnnocation
{
    if (_targetAnnocation) {
        return _targetAnnocation;
    }
    _targetAnnocation = [[BMKPointAnnotation alloc]init];
    _targetAnnocation.coordinate = self.coordinate;
    _targetAnnocation.title = self.titleName;
    return _targetAnnocation;
}

-(BMKPointAnnotation *)annocationWithCoordinate:(CLLocationCoordinate2D)coordinate
                                          title:(NSString *)title
{
    BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
    item.coordinate = coordinate;
    item.title = title;
    return item;
}

/**
 *  添加目标地图标注
 */
-(void)addTargatMapAnnotation{
    
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    [_mapView addAnnotation:self.targetAnnocation];//addAnnotation方法会掉BMKMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
    [_mapView showAnnotations:_mapView.annotations animated:NO];
}

-(void)tiaozhuanAppleMap{
    
    
    //定位点
    const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    
    double bd_lon = _userLocation.location.coordinate.longitude;
    double bd_lat = _userLocation.location.coordinate.latitude;
    
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    
    double gaode_lon = z * cos(theta);//高德经度
    double gaode_lat = z * sin(theta);//高德维度
    
    //目的地
    const double x_pi1 = 3.14159265358979324 * 3000.0 / 180.0;
    
    double bd_lon1= self.coordinate.longitude;
    double bd_lat1 = self.coordinate.latitude;
    
    double x1 = bd_lon1 - 0.0065, y1 = bd_lat1 - 0.006;
    double z1 = sqrt(x1 * x1 + y1 * y1) - 0.00002 * sin(y1 * x_pi1);
    double theta1 = atan2(y1, x1) - 0.000003 * cos(x1 * x_pi1);
    
    double gaode_lon1 = z1 * cos(theta1);//高德经度
    double gaode_lat1 = z1 * sin(theta1);//高德维度
    
    
    
    CLLocationCoordinate2D from = CLLocationCoordinate2DMake(gaode_lat,gaode_lon);
    MKPlacemark * fromMark = [[MKPlacemark alloc] initWithCoordinate:from
                                                   addressDictionary:nil];
    MKMapItem * fromLocation = [[MKMapItem alloc] initWithPlacemark:fromMark];
    fromLocation.name = @"我的位置";
    
    CLLocationCoordinate2D to = CLLocationCoordinate2DMake(gaode_lat1,gaode_lon1);
    MKPlacemark * toMark = [[MKPlacemark alloc] initWithCoordinate:to
                                                 addressDictionary:nil];
    MKMapItem * toLocation = [[MKMapItem alloc] initWithPlacemark:toMark];
    toLocation.name = self.titleName;
    
    NSArray  * values = [NSArray arrayWithObjects:
                         MKLaunchOptionsDirectionsModeDriving,
                         [NSNumber numberWithBool:YES],
                         [NSNumber numberWithInt:3],
                         nil];
    NSArray * keys = [NSArray arrayWithObjects:
                      MKLaunchOptionsDirectionsModeKey,
                      MKLaunchOptionsShowsTrafficKey,
                      MKLaunchOptionsMapTypeKey,nil];
    
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:fromLocation, toLocation, nil]
                   launchOptions:[NSDictionary dictionaryWithObjects:values
                                                             forKeys:keys]];
}

-(void)tiaozhuanBiduMap{

    ///name:起始位置
    NSString * string = [NSString stringWithFormat:@"baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=driving&src=hema",_userLocation.location.coordinate.latitude,_userLocation.location.coordinate.longitude,self.coordinate.latitude,self.coordinate.longitude];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([app canOpenURL:[NSURL URLWithString:string]])
    {
        [_locService stopUserLocationService];
        [app openURL:[NSURL URLWithString:string]];
    }else
    {
        [GMAPI showAutoHiddenMBProgressWithText:@"您还没有安装百度地图" addToView:self.view];
    }
}


#pragma mark - 初始化地图
-(void)setGMap{
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64)];
    _mapView.delegate = self;
    _mapView.isSelectedAnnotationViewFront = YES;
    [self.view addSubview:_mapView];
    
    UIButton *backIBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backIBtn setFrame:CGRectMake(10, DEVICE_HEIGHT - 33 - 60, 33, 33)];
    [backIBtn setImage:[UIImage imageNamed:@"backilocation.png"] forState:UIControlStateNormal];
    backIBtn.layer.cornerRadius = 5;
    backIBtn.backgroundColor = RGBCOLOR(245, 245, 245);
    [backIBtn addTarget:self action:@selector(backILocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backIBtn];
    
    UIButton *backHospitalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backHospitalBtn setFrame:CGRectMake(10, DEVICE_HEIGHT - 33 - 60 - 10 - 33, 33, 33)];
    [backHospitalBtn setImage:[UIImage imageNamed:@"backHospital.png"] forState:UIControlStateNormal];
    backHospitalBtn.layer.cornerRadius = 5;
    backHospitalBtn.backgroundColor = RGBCOLOR(245, 245, 245);
    [backHospitalBtn addTarget:self action:@selector(backHospital) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backHospitalBtn];
}

#pragma mark - 回到我的位置
-(void)backILocation{
    if (_userLocation.location) {
        [_mapView setCenterCoordinate:_userLocation.location.coordinate animated:YES];
    }
}

-(void)backHospital{
    [_mapView setCenterCoordinate:self.coordinate animated:YES];
}

#pragma mark - 初始化定位服务
-(void)setGLocationService{
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
}

#pragma mark - 开启定位罗盘态
// 罗盘态
-(void)startFollowHeading{
    [_locService startUserLocationService];
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    _mapView.showsUserLocation = YES;
//    [_mapView  setCenterCoordinate:self.coordinate];//目标地址作为中心
}

#pragma mark - 定位相关

//在地图View将要启动定位时，会调用此函数
- (void)willStartLocatingUser
{
    
}

/*!
 *  @brief  根据已有的标注数据计算得到刚好可以全部展示的QCoordinateRegion
 *
 *  @param list 数组元素为BMKPointAnnotation
 *
 *  @return QCoordinateRegion
 */
- (BMKMapRect)minixumMapRectForMapPoints:(NSArray *)list{
    NSAssert(list != nil && list.count > 1, @"%s: invalid arguments", __func__);
    
    BMKPointAnnotation *mapAnno = [list objectAtIndex:0];
    BMKMapPoint mapPoint = BMKMapPointForCoordinate(mapAnno.coordinate);
    
//    mapPoint
    
    CGFloat minX = mapPoint.x;
    CGFloat minY = mapPoint.y;
    CGFloat maxX = minX;
    CGFloat maxY = minY;
    
    /* Traverse and find the min, max. */
    for (int i = 1; i < list.count; i++){
        BMKPointAnnotation *mapAnno = [list objectAtIndex:i];
        BMKMapPoint point = BMKMapPointForCoordinate(mapAnno.coordinate);
        if (point.x < minX){
            minX = point.x;
        }
        
        if (point.x > maxX){
            maxX = point.x;
        }
        
        if (point.y < minY){
            minY = point.y;
        }
        
        if (point.y > maxY){
            maxY = point.y;
        }
    }
    
    /* Construct outside min rectangle. */
    BMKMapRect mapRect = BMKMapRectMake(minX, minY, fabs(maxX - minX), fabs(maxY - minY));
    
    //    QCoordinateRegion region = QMCoordinateRegionForMapRect(mapRect);
    return mapRect;
}

//用户方向更新后，会调用此函数
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}

//用户位置更新后，会调用此函数
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    if (userLocation && !_button_daohang.userInteractionEnabled) {
        _button_daohang.userInteractionEnabled = YES;
        _userLocation = userLocation;
    }
    
    [_mapView updateLocationData:userLocation];
    
    CLLocationCoordinate2D user = userLocation.location.coordinate;
    
    //设置显示视野
    
//    DDLOG(@"user %f %f",user.latitude,user.longitude);
    
    if (_isFirst && user.latitude > 0) { //第一次进来
        
        _isFirst = NO;

//        NSArray *annotations = @[[self annocationWithCoordinate:user title:@"当前位置"],self.targetAnnocation];
//        BMKMapRect mapRect = [self minixumMapRectForMapPoints:annotations];
//        [_mapView setVisibleMapRect:mapRect animated:YES];
        
        [_mapView showAnnotations:@[[self annocationWithCoordinate:user title:@"当前位置"],self.targetAnnocation] animated:YES];
    }
}


//在地图View停止定位后，会调用此函数
- (void)didStopLocatingUser
{
    
}

//定位失败后，会调用此函数
- (void)didFailToLocateUserWithError:(NSError *)error
{
    
}

#pragma mark - 代理

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //0 百度地图
    //1 苹果地图
    
    if (buttonIndex == 0) {
        [self tiaozhuanBiduMap];
    }else if (buttonIndex == 1){
        [self tiaozhuanAppleMap];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self tiaozhuanBiduMap];
    }
}

#pragma mark - BMKMapViewDelegate
/**
 *根据anntation生成对应的View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
    
        // 设置位置
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
        annotationView.annotation = annotation;
        // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
        annotationView.canShowCallout = YES;
        // 设置是否可以拖拽
        annotationView.draggable = NO;
        
        [annotationView setSelected:YES animated:NO];
        annotationView.enabled = YES;
        
        annotationView.rightCalloutAccessoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 1, 34, 41)];
        annotationView.rightCalloutAccessoryView.userInteractionEnabled = YES;
        annotationView.clipsToBounds = YES;
        [annotationView addTaget:self action:@selector(annotationViewClicked:) tag:0];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:@"导航" forState:UIControlStateNormal];
        [btn setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
        [btn setFrame:annotationView.rightCalloutAccessoryView.bounds];
        [btn addTarget:self action:@selector(gDaohang) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.masksToBounds = YES;
        [annotationView.rightCalloutAccessoryView addSubview:btn];
        
    }
    
    annotationView.annotation = annotation;
    
    return annotationView;
}

-(void)annotationViewClicked:(UIButton *)sender{
    DDLOG(@"%@",sender);
    
    //方法1
//    [_mapView removeAnnotation:self.targetAnnocation];
//    [_mapView addAnnotation:self.targetAnnocation];
    
    //方法2
    [_mapView selectAnnotation:self.targetAnnocation animated:YES];
}



/**
 *当取消选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 取消选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
    NSLog(@"%s",__FUNCTION__);

}



/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    NSLog(@"%s",__FUNCTION__);
}


/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    NSLog(@"%s",__FUNCTION__);
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}


- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
    //声明解析时对坐标数据的位置区域的筛选，包括经度和纬度的最小值和最大值
//    CLLocationDegrees minLat;
//    CLLocationDegrees maxLat;
//    CLLocationDegrees minLon;
//    CLLocationDegrees maxLon;
    
//    CLLocationCoordinate2D user = _mapView.
    
    //对比筛选出最小纬度，最大纬度；最小经度，最大经度
//    minLat = MIN(self.coordinate.latitude, user.latitude);
//    maxLat = MAX(self.coordinate.latitude, user.latitude);
//    minLon = MIN(self.coordinate.longitude, user.longitude);
//    maxLon = MAX(self.coordinate.longitude, user.longitude);
//    
//    //动态的根据坐标数据的区域，来确定地图的显示中心点和缩放级别
//    //        if (_carPointArray.count > 0) {
//    //计算中心点
//    CLLocationCoordinate2D centCoor;
//    centCoor.latitude = (CLLocationDegrees)((maxLat+minLat) * 0.5f);
//    centCoor.longitude = (CLLocationDegrees)((maxLon+minLon) * 0.5f);
//    BMKCoordinateSpan span;
//    //计算地理位置的跨度
//    span.latitudeDelta = maxLat - minLat;
//    span.longitudeDelta = maxLon - minLon;
//    //得出数据的坐标区域
//    BMKCoordinateRegion region = BMKCoordinateRegionMake(centCoor, span);
//    //百度地图的坐标范围转换成相对视图的位置
//    CGRect fitRect = [_mapView convertRegion:region toRectToView:_mapView];
//    //将地图视图的位置转换成地图的位置
//    BMKMapRect fitMapRect = [_mapView convertRect:fitRect toMapRectFromView:_mapView];
//    //设置地图可视范围为数据所在的地图位置
//    [_mapView setVisibleMapRect:fitMapRect animated:YES];
}


#pragma mark - 弹出框点击代理方法
// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    if (_button_daohang.userInteractionEnabled) {
        [self gDaohang];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
