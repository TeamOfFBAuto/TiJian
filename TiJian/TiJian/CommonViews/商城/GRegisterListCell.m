//
//  GRegisterListCell.m
//  TiJian
//
//  Created by gaomeng on 16/7/26.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GRegisterListCell.h"

@implementation GRegisterListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpdataBlock:(updataBlock)updataBlock{
    _updataBlock = updataBlock;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.hospitalNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH *245.0/750, 75)];
        self.hospitalNameLabel.textAlignment = NSTextAlignmentCenter;
        self.hospitalNameLabel.font = [UIFont systemFontOfSize:12];
        self.hospitalNameLabel.textColor = [UIColor blackColor];
        self.hospitalNameLabel.numberOfLines = 5;
        [self.contentView addSubview:self.hospitalNameLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.hospitalNameLabel.right, 0, self.hospitalNameLabel.width, self.hospitalNameLabel.height)];
        self.timeLabel.numberOfLines = 5;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.timeLabel];
        
        self.stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.timeLabel.right, 0, DEVICE_WIDTH *130.0/750, 75)];
        self.stateLabel.textAlignment = NSTextAlignmentCenter;
        self.stateLabel.font = [UIFont systemFontOfSize:12];
        self.stateLabel.numberOfLines = 5;
        self.stateLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.stateLabel];
        
        
        self.dcbView = [[UIView alloc]initWithFrame:CGRectMake(self.stateLabel.right, 0, DEVICE_WIDTH*130.0/750, 75)];
        [self.contentView addSubview:self.dcbView];
        
        self.detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.detailBtn setFrame:CGRectMake(0, 0, self.dcbView.width*0.8, self.dcbView.height*0.3)];
        [self.detailBtn setTitle:@"详情" forState:UIControlStateNormal];
        [self.detailBtn setTitleColor:RGBCOLOR(89, 140, 189) forState:UIControlStateNormal];
        self.detailBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.detailBtn.center = CGPointMake(self.dcbView.width *0.5, self.dcbView.height*0.5 - self.dcbView.height*0.15 - 3);
        [self.dcbView addSubview:self.detailBtn];
        
        
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelBtn setFrame:CGRectMake(self.detailBtn.frame.origin.x, self.detailBtn.bottom + 3, self.detailBtn.width, self.detailBtn.height)];
        self.cancelBtn.backgroundColor = RGBCOLOR(36, 104, 227);
        [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        self.cancelBtn.layer.cornerRadius = 5;
        [self.dcbView addSubview:self.cancelBtn];
        
        
    }
    return self;
}

-(void)loadDataWithDic:(NSDictionary *)dic indexPath:(NSIndexPath *)theIndex{
    self.hospitalNameLabel.text = [NSString stringWithFormat:@"%@(%@)",[dic stringValueForKey:@"hospital_name"],[dic stringValueForKey:@"hospital_level_desc"]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@\n%@",[dic stringValueForKey:@"check_appoint_date"],[dic stringValueForKey:@"dept_name"]];
    self.stateLabel.text = [GMAPI orderStateStr:[dic stringValueForKey:@"status"]];
    self.detailBtn.tag = theIndex.row + 10;
    self.cancelBtn.tag = -theIndex.row  - 10;
    int status = [[dic stringValueForKey:@"status"]intValue];
    
    if (status == 1 || status == 2){//可以取消
        [self.detailBtn setFrame:CGRectMake(0, 0, self.dcbView.width*0.8, self.dcbView.height*0.3)];
        self.detailBtn.center = CGPointMake(self.dcbView.width *0.5, self.dcbView.height*0.5 - self.dcbView.height*0.15 - 3);
        [self.cancelBtn setFrame:CGRectMake(self.detailBtn.frame.origin.x, self.detailBtn.bottom + 3, self.detailBtn.width, self.detailBtn.height)];
        self.cancelBtn.hidden = NO;
    }else{//不能取消
        [self.detailBtn setFrame:CGRectMake(0, 0, self.dcbView.width*0.8, self.dcbView.height*0.3)];
        self.detailBtn.center = CGPointMake(self.dcbView.width *0.5, self.dcbView.height*0.5 );
        self.cancelBtn.hidden = YES;
    }
    
    [self.detailBtn addTarget:self action:@selector(theBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(theBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - 按钮点击
-(void)theBtnClicked:(UIButton *)sender{
    if (self.updataBlock) {
        self.updataBlock(sender.tag);
    }
}

@end
