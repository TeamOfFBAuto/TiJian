//
//  LTextView.h
//  TiJian
//
//  Created by lichaowei on 16/7/21.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTextView : UITextView

@property (nonatomic,retain)NSString *placeHolder;
@property (nonatomic,retain)UIFont *placeHolderFont;//字体
@property (nonatomic,retain)UIColor *placeHolderColor;//颜色
@property (nonatomic,assign)CGRect placeHoderFrame;//frame

@end
