//
//  GRegisterListCell.h
//  TiJian
//
//  Created by gaomeng on 16/7/26.
//  Copyright © 2016年 lcw. All rights reserved.
//


/**
 *  挂号转诊自定义cell
 */
#import <UIKit/UIKit.h>

typedef void(^updataBlock)(NSInteger index);

@interface GRegisterListCell : UITableViewCell

@property(nonatomic,strong)UILabel *hospitalNameLabel;//医院名
@property(nonatomic,strong)UILabel *timeLabel;//申请时间及班次
@property(nonatomic,strong)UILabel *stateLabel;//状态
@property(nonatomic,strong)UIButton *detailBtn;//详情
@property(nonatomic,strong)UIButton *cancelBtn;//取消
@property(nonatomic,strong)UIView *dcbView;

@property(nonatomic,copy)updataBlock updataBlock;

-(void)setUpdataBlock:(updataBlock)updataBlock;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)loadDataWithDic:(NSDictionary *)dic indexPath:(NSIndexPath *)theIndex;

@end
