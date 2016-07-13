//
//  GoProductCell.m
//  TiJian
//
//  Created by lichaowei on 16/7/13.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GoProductCell.h"

@implementation GoProductCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        //取消选中效果
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        CGFloat cellHeight = DEVICE_WIDTH / 1.6f;
        CGFloat kWidth = DEVICE_WIDTH;
        
        //裁剪看不到的
        self.clipsToBounds = YES;
        
        //pictureView的Y往上加一半cellHeight 高度为2 * cellHeight，这样上下多出一半的cellHeight
        _pictureView = ({
            
//            828px宽 x 974px高
            
//            CGFloat imgHeight = kWidth * 974.f / 828.f;
//            CGFloat dis = imgHeight - cellHeight;
            
            UIImageView * picture = [[UIImageView alloc]initWithFrame:CGRectMake(0, -cellHeight/2, kWidth, cellHeight * 2)];
//            UIImageView * picture = [[UIImageView alloc]initWithFrame:CGRectMake(0, -dis/2, kWidth, imgHeight)];

            picture.contentMode = UIViewContentModeScaleAspectFit;
            picture.backgroundColor = [UIColor greenColor];
            
            picture;
        });
        [self.contentView  addSubview:_pictureView];
        
        
        //底部
        CGFloat height = [LTools fitWithIPhone6:50];
        UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, cellHeight - height + 1, DEVICE_WIDTH, height)];
        footView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.9];
        [self.contentView addSubview:footView];
        
        _titleLabel = ({
            UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, DEVICE_WIDTH - 90, footView.height)];
            
            titleLabel.font = [UIFont systemFontOfSize:16];
            
            titleLabel.textAlignment = NSTextAlignmentLeft;
            
            titleLabel.textColor = DEFAULT_TEXTCOLOR_TITLE;
            
            titleLabel.text = @"标题";
            
            titleLabel;

        });
        [footView addSubview:_titleLabel];
        
        _littleLabel = ({
            UILabel * littleLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 12 - 76, 10, 76, footView.height - 20)];
            
            littleLabel.font = [UIFont systemFontOfSize:14];
            
            littleLabel.textAlignment = NSTextAlignmentCenter;
            
            littleLabel.textColor = [UIColor whiteColor];
            
            littleLabel.backgroundColor = DEFAULT_TEXTCOLOR_ORANGE;
            
            [littleLabel addCornerRadius:3.f];
            
            littleLabel;
            
        });
        [footView addSubview:_littleLabel];
    }
    return self;
    
}

- (CGFloat)cellOffset
{
    /*
     - (CGRect)convertRect:(CGRect)rect toView:(nullable UIView *)view;
     将rect由rect所在视图转换到目标视图view中，返回在目标视图view中的rect
     这里用来获取self在window上的位置
     */
    CGRect toWindow = [self convertRect:self.bounds toView:self.window];
    
    //获取父视图的中心
    CGPoint windowCenter = self.superview.center;
    
    //cell在y轴上的位移  CGRectGetMidY之前讲过,获取中心Y值
    CGFloat cellOffsetY = CGRectGetMidY(toWindow) - windowCenter.y;
    
    //位移比例
    CGFloat offsetDig = 2 * cellOffsetY / self.superview.frame.size.height;
    
    CGFloat cellHeight = DEVICE_WIDTH / 1.6f;
    //要补偿的位移
    CGFloat offset =  - offsetDig * cellHeight / 2;
    
    //让pictureViewY轴方向位移offset
//    self.pictureView.transform = CGAffineTransformIdentity;
    CGAffineTransform transY = CGAffineTransformMakeTranslation(0,offset);
    self.pictureView.transform = transY;
    
    return offset;
}

@end
