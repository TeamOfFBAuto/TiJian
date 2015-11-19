//
//  MapViewController.h
//  YiYiProject
//
//  Created by gaomeng on 14/12/27.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : MyViewController

@property(nonatomic,strong)NSString *titleName;
@property(nonatomic,assign)CLLocationCoordinate2D coordinate;


@end
