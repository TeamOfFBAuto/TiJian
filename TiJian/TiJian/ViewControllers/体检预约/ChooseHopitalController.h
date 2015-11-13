//
//  ChooseHopitalController.h
//  TiJian
//
//  Created by lichaowei on 15/11/12.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  选择时间和分院
 */

#import "MyViewController.h"
#import "FSCalendar.h"

@interface ChooseHopitalController : MyViewController<FSCalendarDataSource, FSCalendarDelegate>

@property(nonatomic,retain)FSCalendar *calendar;

@end
