//
//  OptionModel.m
//  TiJian
//
//  Created by lichaowei on 15/10/30.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "OptionModel.h"

@implementation OptionModel

-(instancetype)initWithQuestionId:(int)questionId
                         optionId:(int)optionId
                      optionImage:(UIImage *)optionImage
{
    self = [super init];
    if (self) {
        
        self.questionId = questionId;
        self.optionId = optionId;
        self.optionImage = optionImage;
    }
    return self;
}

@end
