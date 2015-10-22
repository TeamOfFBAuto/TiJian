//
//  LQuestionView.h
//  TiJian
//
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

/**
 *  个人定制，问题view
 */
#import <UIKit/UIKit.h>

typedef void(^RESULTBLOCK)(QUESTIONTYPE type,id object, NSDictionary *result);
@interface LQuestionView : UIView

/**
 *  创建年龄view
 *  @param gender 性别
 *  @param selectAge 上次选择的年龄
 *  @return
 */
-(instancetype)initAgeViewWithFrame:(CGRect)frame
                             gender:(Gender)gender
                            initNum:(int)initNum
                        resultBlock:(RESULTBLOCK)aBlock;



@end
