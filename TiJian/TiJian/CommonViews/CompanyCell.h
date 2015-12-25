//
//  CompanyCell.h
//  TiJian
//
//  Created by lichaowei on 15/11/11.
//  Copyright © 2015年 lcw. All rights reserved.
//
/**
 *  预约 -- 公司
 */
#import <UIKit/UIKit.h>

typedef enum {
    COMPANYPRETYPE_TAOCAN = 0,//默认套餐形式
    COMPANYPRETYPE_MONEY = 1 //代金券形式
}COMPANYPRETYPE; //公司预约形式

@interface CompanyCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
              companyPreType:(COMPANYPRETYPE)preType;

@end
