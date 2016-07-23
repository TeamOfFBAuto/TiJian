//
//  GHospitalOfProvinceTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 16/7/23.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHospitalOfProvinceTableViewCell : UITableViewCell

@property(nonatomic,strong)UILabel *hospitalNameLabel;
@property(nonatomic,strong)UILabel *descLabel;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
