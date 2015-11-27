//
//  GuserAddressTableViewCell.h
//  TiJian
//
//  Created by gaomeng on 15/11/20.
//  Copyright © 2015年 lcw. All rights reserved.
//


//收货地址自定义cell

#import <UIKit/UIKit.h>
#import "AddressModel.h"
@class GManageAddressViewController;
@class GuserAddressViewController;

typedef enum : NSUInteger {
    ADDRESSCELL_EDIT,
    ADDRESSCELL_SELECT
} CUSTOM_ADDRESSCELL_TYPE;


@interface GuserAddressTableViewCell : UITableViewCell

@property(nonatomic,assign)GManageAddressViewController *delegate;
@property(nonatomic,assign)GuserAddressViewController *delegate1;

-(CGFloat)loadCustomViewWithModel:(AddressModel *)theModel type:(CUSTOM_ADDRESSCELL_TYPE)theType indexPath:(NSIndexPath*)index;

@end
