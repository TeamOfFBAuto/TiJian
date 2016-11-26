//
//  GuserAddressTableViewCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/20.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GuserAddressTableViewCell.h"
#import "GManageAddressViewController.h"
#import "GuserAddressViewController.h"

@implementation GuserAddressTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CGFloat)loadCustomViewWithModel:(AddressModel *)theModel type:(CUSTOM_ADDRESSCELL_TYPE)theType indexPath:(NSIndexPath*)index{
    CGFloat height = 0;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
    line.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.contentView addSubview:line];
    height += line.frame.size.height;
    
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(line.frame)+10, 60, 15)];
    nameLabel.font = [UIFont systemFontOfSize:13];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text = theModel.receiver_username;
    [self.contentView addSubview:nameLabel];
    [nameLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, 10) height:15 limitMaxWidth:100];
    height += nameLabel.frame.size.height+10;
    
    UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+15, nameLabel.frame.origin.y, 100, nameLabel.frame.size.height)];
    phoneLabel.textColor = [UIColor blackColor];
    phoneLabel.font = [UIFont systemFontOfSize:13];
    phoneLabel.text = theModel.mobile;
    [self.contentView addSubview:phoneLabel];
    
    
    if ([theModel.default_address intValue] == 1 && theType == ADDRESSCELL_SELECT) {//默认收货地址
        UILabel *ll = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, CGRectGetMaxY(nameLabel.frame)+10, 35, 15)];
        ll.text = @"默认";
        ll.textAlignment = NSTextAlignmentCenter;
        ll.font = [UIFont systemFontOfSize:13];
        ll.textColor = [UIColor whiteColor];
        ll.backgroundColor = RGBCOLOR(237, 108, 22);
        ll.layer.cornerRadius = 4;
        ll.layer.masksToBounds = YES;
        [self.contentView addSubview:ll];
        
        UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(ll.frame)+8, CGRectGetMaxY(nameLabel.frame)+10, DEVICE_WIDTH - 100, 15)];
        addressLabel.font = [UIFont systemFontOfSize:13];
        addressLabel.textColor = RGBCOLOR(140, 140, 140);
        addressLabel.text = theModel.address;
        [self.contentView addSubview:addressLabel];
        [addressLabel setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(ll.frame)+8, CGRectGetMaxY(nameLabel.frame)+10) width:DEVICE_WIDTH - 100];
        height += addressLabel.frame.size.height+10;
    }else{
        UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, CGRectGetMaxY(nameLabel.frame)+10, DEVICE_WIDTH - 60, 15)];
        addressLabel.font = [UIFont systemFontOfSize:13];
        addressLabel.textColor = RGBCOLOR(140, 140, 140);
        addressLabel.text = theModel.address;
        [self.contentView addSubview:addressLabel];
        [addressLabel setMatchedFrame4LabelWithOrigin:CGPointMake(nameLabel.frame.origin.x, CGRectGetMaxY(nameLabel.frame)+10) width:DEVICE_WIDTH - 60];
        height += addressLabel.frame.size.height+10;
    }
    
    
    
    
    if (theType == ADDRESSCELL_SELECT) {
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [editBtn setFrame:CGRectMake(DEVICE_WIDTH - 40, (height-5)*0.5-20+5, 40, 40)];
        [editBtn setImage:[UIImage imageNamed:@"personalxiugai.png"] forState:UIControlStateNormal];
        editBtn.tag = index.row +1000;
        [editBtn addTarget:self action:@selector(editBtnClickedWithIndex1:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:editBtn];
        
    }else if (theType == ADDRESSCELL_EDIT){
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(10, height+5, DEVICE_WIDTH-10, 0.5)];
        line.backgroundColor = RGBCOLOR(220, 221, 223);
        [self.contentView addSubview:line];
        
        UIButton *defaultAddressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        defaultAddressBtn.tag = index.row +100;
        [defaultAddressBtn setFrame:CGRectMake(0, CGRectGetMaxY(line.frame)+10, 110, 30)];
        [defaultAddressBtn setTitle:@"设为默认地址" forState:UIControlStateNormal];
        defaultAddressBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [defaultAddressBtn setTitleColor:RGBCOLOR(81, 82, 83) forState:UIControlStateNormal];
        [defaultAddressBtn setImage:[UIImage imageNamed:@"xuanzhong_no.png"] forState:UIControlStateNormal];
        [defaultAddressBtn setImage:[UIImage imageNamed:@"shoppingcart_selected.png"] forState:UIControlStateSelected];
        [defaultAddressBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [defaultAddressBtn addTarget:self action:@selector(defaultAddressBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        if ([theModel.default_address intValue] == 1) {
            defaultAddressBtn.selected = YES;
        }
        [self.contentView addSubview:defaultAddressBtn];
        height += 5+0.5+10+defaultAddressBtn.frame.size.height+10;
        
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [editBtn setFrame:CGRectMake(DEVICE_WIDTH - 100, CGRectGetMaxY(line.frame)+((height - CGRectGetMaxY(line.frame))*0.5-20), 40, 40)];
        editBtn.tag = index.row +1000;
        [editBtn setImage:[UIImage imageNamed:@"personalxiugai.png"] forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(editBtnClickedWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:editBtn];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setFrame:CGRectMake(DEVICE_WIDTH - 50, editBtn.frame.origin.y, 40, 40)];
        deleteBtn.tag = index.row+2000;
        [deleteBtn setImage:[UIImage imageNamed:@"personal_jiaren_shanchu.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:deleteBtn];
        
    }
    
    

    return height;
}


//编辑按钮点击
-(void)editBtnClickedWithIndex:(UIButton*)sender{
    AddressModel *model = self.delegate.rtab.dataArray[sender.tag - 1000];
    [self.delegate oneCellEditBtnClicked:model];
}

-(void)editBtnClickedWithIndex1:(UIButton*)sender{
    AddressModel *model = self.delegate1.tab.dataArray[sender.tag - 1000];
    [self.delegate1 oneCellEditBtnClicked:model];
}


//默认按钮点击
-(void)defaultAddressBtnClicked:(UIButton*)sender{
    
    [MBProgressHUD showHUDAddedTo:self.delegate.view animated:YES];
    
    AddressModel *model = self.delegate.rtab.dataArray[sender.tag - 100];
    
    YJYRequstManager *request = [YJYRequstManager shareInstance];
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"address_id":model.address_id
                          };

    __weak typeof (self)bself = self;
    
    [request requestWithMethod:YJYRequstMethodPost api:USER_ADDRESS_SETDEFAULT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.delegate.view animated:YES];
        [bself setDataSourceWithIndex:sender.tag - 100];

    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.delegate.view animated:YES];
        
    }];
}


-(void)setDataSourceWithIndex:(NSInteger)index{
    for (AddressModel *model in self.delegate.rtab.dataArray) {
        model.default_address = @"0";
    }
    AddressModel *theModel = self.delegate.rtab.dataArray[index];
    theModel.default_address = @"1";
    [self.delegate.rtab reloadData];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_DEFAULTADDRESS object:nil];
    
    
    
}


@end
