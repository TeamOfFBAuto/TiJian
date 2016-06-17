//
//  LPickerView.h
//  TiJian
//
//  Created by lichaowei on 16/5/16.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LPickerBlock)(ACTIONTYPE type, int row ,int component);

@interface LPickerView : UIView
{
    LPickerBlock _pickerBlock;
}

@property(nonatomic,readonly) UIPickerView *pickerView;


-(instancetype)initWithDelegate:(id<UIPickerViewDataSource>)dataSource
                       delegate:(id<UIPickerViewDelegate>)delegate
                    pickerBlock:(LPickerBlock)pickerBlock;
//控制显示或者隐藏
-(void)pickerViewShow:(BOOL)show;

/**
 *  刷新数据
 */
- (void)reloadAllComponents;
/**
 *  加载数据为空或者失败
 *
 *  @param msg 显示内容
 */
- (void)loadFailWithMsg:(NSString *)msg;

/**
 *  设置显示row component
 */
- (void)selectrow:(int)row component:(int)component animated:(BOOL)animated;

@end
