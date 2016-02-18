//
//  GproductCommentView.m
//  TiJian
//
//  Created by gaomeng on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GproductCommentView.h"
#import "LPhotoBrowser.h"

@implementation GproductCommentView


-(CGFloat)loadCustomViewWithModel:(ProductCommentModel*)model{
    
    self.userInteractionEnabled = YES;
    
    _theModel = model;
    
    CGFloat height = 0;

    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, DEVICE_WIDTH - 30, 0)];
    tLabel.font = [UIFont systemFontOfSize:12];
    tLabel.text  = model.content;
    [tLabel setMatchedFrame4LabelWithOrigin:CGPointMake(15, 10) width:DEVICE_WIDTH-30];
    [self addSubview:tLabel];
    height += tLabel.frame.size.height+10;
    
    //图片
    CGFloat imv_j = 15;
    CGFloat imv_w = (DEVICE_WIDTH - imv_j*4)/3;
    if (model.comment_pic.count>0) {
        for (int i = 0; i<model.comment_pic.count; i++) {
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectZero];
            if ([LTools isEmpty:model.content]) {
                [imv setFrame:CGRectMake(i*(imv_w+imv_j)+imv_j, 10, imv_w, [GMAPI scaleWithHeight:0 width:imv_w theWHscale:1.6])];
            }else{
                [imv setFrame:CGRectMake(i*(imv_w+imv_j)+imv_j, CGRectGetMaxY(tLabel.frame)+10, imv_w, [GMAPI scaleWithHeight:0 width:imv_w theWHscale:1.6])];
            }
            NSDictionary *dic = model.comment_pic[i];
            [imv l_setImageWithURL:[NSURL URLWithString:[dic stringValueForKey:@"url"]] placeholderImage:nil];
            imv.userInteractionEnabled = YES;
            
            [self addSubview:imv];
            
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            btn.backgroundColor = [UIColor orangeColor];
//            [btn setFrame:CGRectMake(i*(imv_w+imv_j)+imv_j, CGRectGetMaxY(tLabel.frame)+10, imv_w, [GMAPI scaleWithHeight:0 width:imv_w theWHscale:1.6])];
//            btn.tag = 200 + i;
//            [btn addTarget:self action:@selector(tapToBrowser:) forControlEvents:UIControlEventTouchUpInside];
//            [self addSubview:btn];
            
            
            
            
        }
        
        
        
        if ([LTools isEmpty:model.content]) {
            height = [GMAPI scaleWithHeight:0 width:imv_w theWHscale:1.6]+10;
        }else{
            height += [GMAPI scaleWithHeight:0 width:imv_w theWHscale:1.6]+10;
        }
        
    }
    
    
    //评论者名称
    UILabel *replyNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, height+10, (DEVICE_WIDTH-30)*0.5, 15)];
    replyNameLabel.font = [UIFont systemFontOfSize:12];
    replyNameLabel.textColor = RGBCOLOR(80, 81, 82);
    replyNameLabel.text = model.username;
    [self addSubview:replyNameLabel];
    
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(replyNameLabel.frame), replyNameLabel.frame.origin.y, (DEVICE_WIDTH-30)*0.5, 15)];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = RGBCOLOR(80, 81, 82);
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.text = [GMAPI timechangeYMD:model.add_time];
    [self addSubview:timeLabel];
    
    height +=timeLabel.frame.size.height+10;
    
    //商家回复
    if (model.comment_reply.count > 0) {
        UILabel *replyContentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        replyContentLabel.font = [UIFont systemFontOfSize:10];
        NSDictionary *dic = model.comment_reply[0];
        replyContentLabel.text = [NSString stringWithFormat:@"商家回复：%@",[dic stringValueForKey:@"content"]];
        replyContentLabel.textColor = RGBCOLOR(80, 81, 82);
        [replyContentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(timeLabel.frame)+5) width:DEVICE_WIDTH-20];
        [self addSubview:replyContentLabel];
        height += 5+replyContentLabel.frame.size.height;
    }
    
    
    height += 10;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, height-0.5, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = RGBCOLOR(223, 224, 225);
    [self addSubview:line];
    
    return height;
}


/**
 *  手势
 *
 *  @param sender 手势
 */
- (void)tapToBrowser:(UIButton *)sender
{
    int index = (int)sender.tag - 200;
    
    NSArray *img = _theModel.comment_pic;
    
    int count = (int)[img count];
    
    NSInteger initPage = index;
    
    @WeakObj(_scrollView);
    [LPhotoBrowser showWithViewController:self.delegate initIndex:initPage photoModelBlock:^NSArray *{
        
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:7];
        
        for (int i = 0; i < count; i ++) {
            
            UIImageView *imageView = [Weak_scrollView viewWithTag:200 + i];
            LPhotoModel *photo = [[LPhotoModel alloc]init];
            photo.imageUrl = img[i][@"img"];
            imageView = imageView;
            photo.thumbImage = imageView.image;
            photo.sourceImageView = imageView;
            
            [temp addObject:photo];
        }
        
        return temp;
    }];
}


@end
