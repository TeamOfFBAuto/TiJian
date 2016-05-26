//
//  TiJian
//
//  Created by lichaowei on 16/1/5.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "ActivityCell.h"
#import "MessageModel.h"

@interface ActivityCell()

@property (nonatomic,retain)UILabel *timeLabel;
@property (nonatomic,retain)UIView *bgView;//背景view
@property (nonatomic,retain)UIImageView *coverImageView;//活动封面
@property (nonatomic,retain)UILabel *titleLabel;//活动标题
@property (nonatomic,retain)UILabel *contentLabel;//活动摘要

//查看详情
@property (nonatomic,retain)UIView *toolView;

@end

@implementation ActivityCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        
        //时间
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH - 125)/2.f, 25, 125, 20) title:@"" font:11 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
        [self.contentView addSubview:_timeLabel];
        _timeLabel.backgroundColor = [UIColor colorWithHexString:@"cecece"];
        [_timeLabel addCornerRadius:3.f];
        
        //正文部分
        self.bgView = [[UIView alloc]initWithFrame:CGRectMake(10, _timeLabel.bottom + 15, DEVICE_WIDTH - 20, 10)];
        _bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_bgView];
        
        //活动标题
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, _bgView.width - 20, 35)  font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@""];
        [_bgView addSubview:_titleLabel];
        
        //活动封面
        CGFloat radio = 8.f/5.f;
        self.coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, _titleLabel.bottom, _titleLabel.width, _titleLabel.width / radio)];
        _coverImageView.backgroundColor = [UIColor redColor];
        [_bgView addSubview:_coverImageView];
        
        //活动摘要
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _coverImageView.bottom + 14, _bgView.width - 20, 30)  font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@""];
        _contentLabel.numberOfLines = 0.f;
        _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_bgView addSubview:_contentLabel];
        
        //查看详情
        self.toolView = [[UIView alloc]initWithFrame:CGRectMake(0, _contentLabel.bottom + 11, _bgView.width, 31)];
        [_bgView addSubview:_toolView];
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, _toolView.width - 20, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [_toolView addSubview:line];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.5, line.width, _toolView.height) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"查看详情"];
        [_toolView addSubview:label];
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(_toolView.width - 30, 0, 35, 31)];
        arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
        arrow.contentMode = UIViewContentModeCenter;
        [_toolView addSubview:arrow];
        
        
        _bgView.height = _toolView.bottom;
    }
    return self;
}

/**
 *  计算cell高度
 *
 *  @param existImage 是否存在封面
 *  @param content    摘要
 *
 *  @return
 */
+ (CGFloat)heightForCellWithImage:(BOOL)existImage
                          content:(NSString *)content
{
    CGFloat radio = 8.f/5.f;

    CGFloat width = DEVICE_WIDTH - 20 - 20;
    
    //时间top:25 bottom:15 height:20、标题 height:35
    CGFloat height = 25 + 20 + 15 + 35;
    //封面 摘要封面间距 14
    if (existImage) {
        height += width / radio;
        height += 14.;
    }
    //摘要 bottom:11
    CGFloat height_content = [LTools heightForText:content width:width font:13.f];
    height += height_content;
    //底部查看详情 高:31  与摘间距11
    height += 31;
    height += 11;
    
    NSLog(@"---%f",height);
    return height;
}


-(void)setCellWithModel:(MessageModel *)aModel
{
    
    self.timeLabel.text = [LTools showIntervalTimeWithTimestamp:aModel.send_time withFormat:@"yyyy年MM月dd日"];

    self.titleLabel.text = aModel.title;
    NSString *content = aModel.content;
    self.contentLabel.text = content;
    CGFloat width = DEVICE_WIDTH - 20 - 20;
    CGFloat height_content = [LTools heightForText:content width:width font:13.f];
    self.contentLabel.height = height_content;
    
    BOOL existImage;
    if (aModel.pic && [aModel.pic hasPrefix:@"http"]) {
        existImage = YES;
    }
    
    CGFloat radio = 8.f/5.f;
    
    //时间top:25 bottom:15 height:20、标题 height:35
    CGFloat height = 0.f;
    //封面 摘要封面间距 14
    CGFloat dis = 0.f;
    if (existImage) {
        
        height = width / radio;
        dis = 14.f;
    }
    self.coverImageView.height = height;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:aModel.pic] placeholderImage:DEFAULT_HEADIMAGE];
    self.coverImageView.contentMode = UIViewContentModeCenter;
    _coverImageView.clipsToBounds = YES;
    
    _contentLabel.top = self.coverImageView.bottom + dis;
    
    self.toolView.top = _contentLabel.bottom + 11;
    //未读
    if ([aModel.is_read intValue] == 1) {
        self.titleLabel.textColor = DEFAULT_TEXTCOLOR_TITLE;
        self.contentLabel.textColor = DEFAULT_TEXTCOLOR_TITLE;
    }else if ([aModel.is_read intValue] == 2){
        self.titleLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
        self.contentLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
    }
    
    //调整背景高度
    _bgView.height = _toolView.bottom;

}

#pragma mark - 固定宽度和 比例16:10
///**
// *  计算cell高度
// *
// *  @param existImage 是否存在封面
// *  @param content    摘要
// *
// *  @return
// */
//+ (CGFloat)heightForCellWithImage:(BOOL)existImage
//                          content:(NSString *)content
//{
//    CGFloat radio = 8.f/5.f;
//
//    CGFloat width = DEVICE_WIDTH - 20 - 20;
//
//    //时间top:25 bottom:15 height:20、标题 height:35
//    CGFloat height = 25 + 20 + 15 + 35;
//    //封面 摘要封面间距 14
//    if (existImage) {
//        height += width / radio;
//        height += 14.;
//    }
//    //摘要 bottom:11
//    CGFloat height_content = [LTools heightForText:content width:width font:13.f];
//    height += height_content;
//    //底部查看详情 高:31  与摘间距11
//    height += 31;
//    height += 11;
//
//    NSLog(@"---%f",height);
//    return height;
//}


//-(void)setCellWithModel:(MessageModel *)aModel
//{
//
//    self.timeLabel.text = [LTools showIntervalTimeWithTimestamp:aModel.send_time withFormat:@"yyyy年MM月dd日"];
//
//    self.titleLabel.text = aModel.title;
//    NSString *content = aModel.content;
//    self.contentLabel.text = content;
//    CGFloat width = DEVICE_WIDTH - 20 - 20;
//    CGFloat height_content = [LTools heightForText:content width:width font:13.f];
//    self.contentLabel.height = height_content;
//
//    BOOL existImage;
//    if (aModel.pic && [aModel.pic hasPrefix:@"http"]) {
//        existImage = YES;
//    }
//
//    CGFloat radio = 8.f/5.f;
//
//    //时间top:25 bottom:15 height:20、标题 height:35
//    CGFloat height = 0.f;
//    //封面 摘要封面间距 14
//    CGFloat dis = 0.f;
//    if (existImage) {
//
//        height = width / radio;
//        dis = 14.f;
//    }
//    self.coverImageView.height = height;
//    [self.coverImageView l_setImageWithURL:[NSURL URLWithString:aModel.pic] placeholderImage:DEFAULT_HEADIMAGE];
//
//    _contentLabel.top = self.coverImageView.bottom + dis;
//
//    self.toolView.top = _contentLabel.bottom + 11;
//    //未读
//    if ([aModel.is_read intValue] == 1) {
//        self.titleLabel.textColor = DEFAULT_TEXTCOLOR_TITLE;
//        self.contentLabel.textColor = DEFAULT_TEXTCOLOR_TITLE;
//    }else if ([aModel.is_read intValue] == 2){
//        self.titleLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
//        self.contentLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
//    }
//
//    //调整背景高度
//    _bgView.height = _toolView.bottom;
//
//}

#pragma mark - 固定高度方式
/**
 *  图片固定高度 适应宽度
 *
 *  @param aModel
 */
//-(void)setCellWithModel:(MessageModel *)aModel
//{
//
//    self.timeLabel.text = [LTools showIntervalTimeWithTimestamp:aModel.send_time withFormat:@"yyyy年MM月dd日"];
//
//    self.titleLabel.text = aModel.title;
//    NSString *content = aModel.content;
//
//    self.contentLabel.text = content;
//    CGFloat width = DEVICE_WIDTH - 20 - 20;
//    CGFloat radio = 8.f/5.f;
//    CGFloat height_const = width / radio;//固定高度
//    self.coverImageView.height = height_const;
//
//    CGFloat height_content = [LTools heightForText:content width:width font:13.f];
//    self.contentLabel.height = height_content;
//
//    BOOL existImage;
//    if (aModel.pic && [aModel.pic hasPrefix:@"http"]) {
//        existImage = YES;
//    }
//
//    //时间top:25 bottom:15 height:20、标题 height:35
//    //封面 摘要封面间距 14
//
//    radio = [aModel.pic_width floatValue] / [aModel.pic_height floatValue];
//    CGFloat needWidth = 0.f;
//    CGFloat dis = 0.f;
//    if (existImage) {
//
//        needWidth = radio * height_const;
//        dis = 14.f;
//    }
//
//    self.coverImageView.width = needWidth;
//    self.coverImageView.centerX = width/2.f;
//
//    [self.coverImageView l_setImageWithURL:[NSURL URLWithString:aModel.pic] placeholderImage:DEFAULT_HEADIMAGE];
//
//    _contentLabel.top = self.coverImageView.bottom + dis;
//
//    self.toolView.top = _contentLabel.bottom + 11;
//    //未读
//    if ([aModel.is_read intValue] == 1) {
//        self.titleLabel.textColor = DEFAULT_TEXTCOLOR_TITLE;
//        self.contentLabel.textColor = DEFAULT_TEXTCOLOR_TITLE;
//    }else if ([aModel.is_read intValue] == 2){
//        self.titleLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
//        self.contentLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
//    }
//
//    //调整背景高度
//    _bgView.height = _toolView.bottom;
//
//}

/**
 *  计算cell高度 图片固定高度 适应宽度
 *
 *  @param existImage 是否存在封面
 *  @param content    摘要
 *
 *  @return
 */
//+ (CGFloat)heightForCellWithImage:(BOOL)existImage
//                          content:(NSString *)content
//{
//    CGFloat radio = 8.f/5.f;
//
//    CGFloat width = DEVICE_WIDTH - 20 - 20;
//
//    //时间top:25 bottom:15 height:20、标题 height:35
//    CGFloat height = 25 + 20 + 15 + 35;
//    //封面 摘要封面间距 14
//    if (existImage) {
//
//        CGFloat height_const = width / radio;//固定高度
//
//        height += height_const;
//        height += 14.;
//    }
//    //摘要 bottom:11
//    CGFloat height_content = [LTools heightForText:content width:width font:13.f];
//    height += height_content;
//    //底部查看详情 高:31  与摘间距11
//    height += 31;
//    height += 11;
//
//    NSLog(@"---%f",height);
//    return height;
//}

@end
