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

-(instancetype)initWithQuestionId:(int)questionId
                         optionId:(int)optionId
                      optionImage:(UIImage *)optionImage;


@end
