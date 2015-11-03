//
//  IgnoreConditionModel.m
//  TiJian
//
//  Created by lichaowei on 15/10/30.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "IgnoreConditionModel.h"

@implementation IgnoreConditionModel

-(instancetype)initWithGroupId:(int)groupId
                    questionId:(int)questionId
                      optionId:(int)optionId
                        answer:(int)answer
                          type:(int)type
                    affectNext:(int)affectNext
                    n1_type_id:(int)n1_type_id
{
    self = [super init];
    if (self) {
        
        self.group_id = groupId;
        self.question_id = questionId;
        self.option_id = optionId;
        self.answer = answer;
        self.type = type;
        self.affect_next = affectNext;
        self.n1_type_id = n1_type_id;
    }
    return self;
}

@end
