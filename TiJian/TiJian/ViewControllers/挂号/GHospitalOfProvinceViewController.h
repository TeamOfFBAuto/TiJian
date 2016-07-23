//
//  GHospitalOfProvinceViewController.h
//  TiJian
//
//  Created by gaomeng on 16/7/21.
//  Copyright © 2016年 lcw. All rights reserved.
//


/**
 *  选择医院
 */
#import "MyViewController.h"

typedef enum
{
    HospitalType_selectNormal = 0,//选择主医院
    HospitalType_search, //通过搜索窗口进入
    HospitalType_selectAlternative //选择备选医院
}HospitalType;

@interface GHospitalOfProvinceViewController : MyViewController

@property (nonatomic,assign)HospitalType hospitalType;

//@property(nonatomic,strong)NSString *ProvinceId;//省份id

@end
