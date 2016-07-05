//
//  ThirdApiConstants.h
//  TiJian
//
//  Created by lichaowei on 16/6/7.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  第三方对接相关宏定义
 */

#ifndef ThirdApiConstants_h
#define ThirdApiConstants_h

//Go健康

//测试环境
//#define GoHealthServerUrl @"http://121.40.167.147:3005" //测试接口
//#define GoHealthAppId @"gjk001061"
//#define GoHealthAppSecret @"3b3f2a13cc7b59830ca819c38e7f294897b3978465d38a8b675b6a2a9474d50e"

//正式环境
#define GoHealthServerUrl @"http://open.gjk365.com" //正式发布接口
#define GoHealthAppId @"gjk001306"
#define GoHealthAppSecret @"20b79f7beddb0453e7799ee74296fa520d6592aca0b9dc547da017dacd072fd1"

#define GoHealth_productionsList @"/v1/productions" //产品列表
#define GoHealth_productionsDetail @"/v1/productions/%@" //产品详情
#define GoHealth_citylist @"/v1/geos" //可用服务城市列表
#define GoHealth_book_dates @"/v1/book_dates"//可预约时间
#define GoHealth_serviceDetail @"/v1/services/%@" //服务详情
#define GoHealth_serviceCancel @"/v1/services/%@/cancel" //取消服务非RestFull

#define GoHealth_makeReportTesting @"/tests/make_report_testing"//把服务状态改为送检中
#define GoHealth_makeReport @"/tests/make_report"//模拟生成报告

#endif /* ThirdApiConstants_h */
