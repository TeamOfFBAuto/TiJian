//
//  OptionModel.h
//  TiJian
//
//  Created by lichaowei on 15/10/30.
//  Copyright © 2015年 lcw. All rights reserved.
//
/**
 *  问题对应选项model
 */
#import "BaseModel.h"

@interface OptionModel : BaseModel

@property(nonatomic,assign)int questionId;
@property(nonatomic,assign)int optionId;
@property(nonatomic,retain)UIImage *optionImage;
@property(nonatomic,assign)BOOL isSepecial;//是否是特殊的选项,问题来决定

-(instancetype)initWithQuestionId:(int)questionId
                         optionId:(int)optionId
                      optionImage:(UIImage *)optionImage;


@end
