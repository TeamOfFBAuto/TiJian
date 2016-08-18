//
//  GDeptOfHospitalViewController.h
//  TiJian
//
//  Created by gaomeng on 16/7/23.
//  Copyright © 2016年 lcw. All rights reserved.
//

/**
 *  医院科室
 */

#import "MyViewController.h"

typedef enum {
    FromType_hospital = 0,//来自医院
    FromType_dept //直接选择科室
}FromType;
@interface GDeptOfHospitalViewController : MyViewController

@property (nonatomic,assign)FromType fromType;//区分是否直接选择科室
@property(nonatomic,strong)NSString *hospital_id;
@property(nonatomic,strong)NSString *hospital_name;

@end
