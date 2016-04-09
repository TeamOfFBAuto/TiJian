//
//  GconfirmOrderCell.m
//  TiJian
//
//  Created by gaomeng on 15/11/18.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GconfirmOrderCell.h"
#import "ProductModel.h"
#import "HospitalModel.h"


@interface GconfirmOrderCell ()
{
    ProductModel *_theModel;//数据源
}
@property(nonatomic,retain)UIImageView *iconImageView;
@property(nonatomic,retain)UILabel *contentLabel;
@property(nonatomic,retain)UILabel *priceLabel;
@property(nonatomic,retain)UILabel *numLabel;

@end

@implementation GconfirmOrderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //图片
        CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/195];
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, [GMAPI scaleWithHeight:height - 20 width:0 theWHscale:250.0/155], height - 20)];
        [self.contentView addSubview:self.iconImageView];
        
        //内容
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+5, self.iconImageView.frame.origin.y, DEVICE_WIDTH - 5 - 15 - 5 - self.iconImageView.frame.size.width - 5 - 5, self.iconImageView.frame.size.height/3)];
        self.contentLabel.font = [UIFont systemFontOfSize:14];
        self.contentLabel.numberOfLines = 2;
        self.contentLabel.textColor = [UIColor blackColor];
        [self.contentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(self.iconImageView.frame)+5, self.iconImageView.frame.origin.y) height:self.iconImageView.frame.size.height/3 limitMaxWidth:DEVICE_WIDTH - 5 - 15 - 5 - self.iconImageView.frame.size.width - 5 - 5 - 30];
        [self.contentView addSubview:self.contentLabel];
        
        //价钱
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.contentLabel.frame.origin.x, CGRectGetMaxY(self.iconImageView.frame)-self.iconImageView.frame.size.height/3, DEVICE_WIDTH - 5 - 15 - 5 - self.iconImageView.frame.size.width - 5 - 5 - 40, self.iconImageView.frame.size.height/3)];
        self.priceLabel.font = [UIFont systemFontOfSize:13];
        self.priceLabel.textColor = RGBCOLOR(237, 108, 22);
        [self.contentView addSubview:self.priceLabel];
        
        //商品数量
        self.numLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.priceLabel.frame), self.iconImageView.frame.size.height*0.5 - 10 + self.iconImageView.frame.origin.y, 40, 20)];
        self.numLabel.font = [UIFont systemFontOfSize:17];
        self.numLabel.textAlignment = NSTextAlignmentRight;
        self.numLabel.textColor = RGBCOLOR(237, 108, 22);
        [self.contentView addSubview:self.numLabel];
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(self.iconImageView.left, height - 0.5, DEVICE_WIDTH - self.iconImageView.left, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [self.contentView addSubview:line];
        
        
        
    }
    return self;
}


-(void)loadCustomViewWithModel:(ProductModel *)model{
    
    _theModel = model;
    
    //图片
    [self.iconImageView l_setImageWithURL:[NSURL URLWithString:model.cover_pic] placeholderImage:nil];
    
    //内容
    self.contentLabel.text = model.product_name;
    [self.contentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(self.iconImageView.frame)+5, self.iconImageView.frame.origin.y) height:self.iconImageView.frame.size.height/3 limitMaxWidth:DEVICE_WIDTH - 5 - 15 - 5 - self.iconImageView.frame.size.width - 5 - 5 - 30];
    
    //价钱
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",model.current_price];
    
    //商品数量
    self.numLabel.text = [NSString stringWithFormat:@"X %@",model.product_num];
    
    [self setYuyueViewWithModel:model];
    


}

+ (CGFloat)heightForCellWithModel:(ProductModel*)theModel{
    
    CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/195];
    
    height += [self heightWithYuyueViewWithModel:theModel];
    
    return height;
}


//根据productmodel设置预约相关view
-(void)setYuyueViewWithModel:(ProductModel*)theModel{
    
    //预约相关view
    self.yuyueView = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/195], DEVICE_WIDTH, 0)];
    [self.contentView addSubview:self.yuyueView];
    
    
    //productModel.hospitalArray ==> hospitalModel.userArray.count
    int num = 0;
    
    
    for (HospitalModel*model in theModel.hospitalArray) {
         num += model.usersArray.count;
    }
    
    if (num == [theModel.product_num intValue]) {//全部预约
        CGFloat height_hospital = 0;
        //几个分院
        for (int i = 0; i<theModel.hospitalArray.count; i++) {
            //此分院包含几个体检人
            HospitalModel *model_h = theModel.hospitalArray[i];
            NSInteger totlePerson_num = model_h.usersArray.count;
            //分院和体检人的view
            UIView *hospitalView = [[UIView alloc]initWithFrame:CGRectMake(0, height_hospital, DEVICE_WIDTH, 44*totlePerson_num+44)];
            hospitalView.backgroundColor = RGBCOLOR_ONE;
            height_hospital += hospitalView.frame.size.height;
            [self.yuyueView addSubview:hospitalView];
        }
        //设置高度
        [self.yuyueView setHeight:height_hospital];
        
    }else if (num < [theModel.product_num intValue]){//没有预约 & 部分预约
        if (num == 0){//没有预约
            
            [self creatYuyueView];
            //设置高度
            [self.yuyueView setHeight:44];
            
        }else{//部分预约
            //几个分院
            CGFloat height_hospital = 0;
            for (int i = 0; i<theModel.hospitalArray.count; i++) {
                //此分院包含几个体检人
                HospitalModel *model_h = theModel.hospitalArray[i];
                NSInteger totlePerson_num = model_h.usersArray.count;
                //分院和体检人的view
                UIView *hospitalView = [[UIView alloc]initWithFrame:CGRectMake(0, height_hospital, DEVICE_WIDTH, 44*totlePerson_num+44)];
                hospitalView.backgroundColor = RGBCOLOR_ONE;
                height_hospital += hospitalView.frame.size.height;
                [self.yuyueView addSubview:hospitalView];
            }
            
            //添加预约view
            [self creatYuyueView];
            
            //设置高度
            [self.yuyueView setHeight:height_hospital];
            
            
        }
    }
    
}


//创建添加预约view
-(void)creatYuyueView{
    //添加预约view
    UIView *addHospitalView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    [self.yuyueView addSubview:addHospitalView];
    //按钮
    UIImageView *addImv = [[UIImageView alloc]initWithFrame:CGRectMake(15, 44*0.5-7, 14, 14)];
    [addImv setImage:[UIImage imageNamed:@"confirmorderadd.png"]];
    [addHospitalView addSubview:addImv];
    //描述label
    UILabel *timeAndHospitalLabel = [[UILabel alloc]initWithFrame:CGRectMake(addImv.right+5, addImv.frame.origin.y, 70, addImv.frame.size.height)];
    timeAndHospitalLabel.font = [UIFont systemFontOfSize:13];
    timeAndHospitalLabel.textColor = [UIColor blackColor];
    timeAndHospitalLabel.text = @"时间、分院";
    [addHospitalView addSubview:timeAndHospitalLabel];
    //箭头
    UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 16, 44*0.5-6, 6, 12)];
    [jiantouImv setImage:[UIImage imageNamed:@"jiantou.png"]];
    [addHospitalView addSubview:jiantouImv];
    
    [addHospitalView addTapGestureTaget:self action:@selector(yuyueViewClicked) imageViewTag:0];
    
}

//创建预约infoView
-(void)creatYuyueInfoView{
    //时间分院view
    UIView *dateAndhospitalView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    dateAndhospitalView.backgroundColor = [UIColor orangeColor];
    
    //体检人view
    UIView *personView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(dateAndhospitalView.frame), DEVICE_WIDTH, 44)];
    personView.backgroundColor = [UIColor greenColor];
}




//添加预约view点击
-(void)yuyueViewClicked{
    if (self.yuyueViewClickedBlock) {
        self.yuyueViewClickedBlock(_theModel);
    }
}



//返回单元格高度
+(CGFloat)heightWithYuyueViewWithModel:(ProductModel *)theModel{
    
    CGFloat height = 0;
    
    int num = 0;
    for (HospitalModel*model in theModel.hospitalArray) {
        num += model.usersArray.count;
    }
    
    if (num == [theModel.product_num intValue]) {//全部预约
        //几个分院
        for (int i = 0; i<theModel.hospitalArray.count; i++) {
            //此分院包含几个体检人
            HospitalModel *model_h = theModel.hospitalArray[i];
            NSInteger totlePerson_num = model_h.usersArray.count;
            height += 44*totlePerson_num+44;
        }
    }else if (num < [theModel.product_num intValue]){//没有预约 & 部分预约
        if (num == 0){//没有预约
            height = 44;
        }else{//部分预约
            //几个分院
            for (int i = 0; i<theModel.hospitalArray.count; i++) {
                //此分院包含几个体检人
                HospitalModel *model_h = theModel.hospitalArray[i];
                NSInteger totlePerson_num = model_h.usersArray.count;
                height += 44*totlePerson_num+44;
            }
            
            height += 44;
        }
    }
    
    return height;
    
}










@end
