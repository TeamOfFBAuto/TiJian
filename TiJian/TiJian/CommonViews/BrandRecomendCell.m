//
//  BrandRecomendCell.m
//  TiJian
//
//  Created by lichaowei on 16/1/27.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "BrandRecomendCell.h"

@interface AddtionView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                       target:(id)target
                       action:(SEL)selector
                          tag:(int)tag;
- (void)setAdditonViewWithDic:(NSDictionary *)dic;
+ (CGFloat)heightForAddtionViewWithDic:(NSDictionary *)dic;

@end

@interface BrandRecomendCell ()
{
    UIView *_selectAllView;//底部选择全部view
}

@property(nonatomic,strong)UIImageView *logoImv;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *originalPriceLabel;
@property(nonatomic,strong)UILabel *priceLabel;

@property(nonatomic,retain)UIView *additonView;//附加项
@property(nonatomic,retain)UIView *additonInfo;//附加项
@property(nonatomic,retain)UILabel *additionTitleLabel;//拓展标题

@property(nonatomic,retain)PropertyButton *selectAllButton;//选择全部
@property(nonatomic,retain)NSMutableDictionary *additonDic;//附加view

@property(nonatomic,retain)NSDictionary *mainDic;//主套餐
@property(nonatomic,retain)NSArray *additonSetMealDic;//附加套餐


@end

@implementation BrandRecomendCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.additonDic = [NSMutableDictionary dictionary];
        
        //图片宽高比 255.0/160
        
        self.selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _selectedButton.backgroundColor = [UIColor redColor];
        _selectedButton.frame = CGRectMake(0, 0, 45, 100);
        [_selectedButton setImage:[UIImage imageNamed:@"xuanzhong"] forState:UIControlStateSelected];
        [_selectedButton setImage:[UIImage imageNamed:@"xuanzhong_no"] forState:UIControlStateNormal];
        [self.contentView addSubview:_selectedButton];
        [_selectedButton addTarget:self action:@selector(clickToSelectMain:) forControlEvents:UIControlEventTouchUpInside];//选择主套餐
        
        CGFloat imv_W = 125.f;
        CGFloat imv_H = imv_W/1.6;
        self.logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(_selectedButton.right, 10, imv_W, imv_H)];
        [self.contentView addSubview:self.logoImv];
        _logoImv.image = DEFAULT_HEADIMAGE;
//        _logoImv.backgroundColor = [UIColor orangeColor];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.logoImv.frame)+10, self.logoImv.frame.origin.y, DEVICE_WIDTH - 10 - imv_W -10 - _selectedButton.width, self.logoImv.frame.size.height*0.5)];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.numberOfLines = 2;
        [self.contentView addSubview:self.titleLabel];
//        _titleLabel.backgroundColor = [UIColor redColor];
        _titleLabel.text = @"慈铭体检关爱老人 北京、上海等";
        
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.titleLabel.frame), self.titleLabel.frame.size.width, self.titleLabel.frame.size.height/2)];
        self.priceLabel.textColor = RGBCOLOR(224, 104, 21);
        self.priceLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.priceLabel];
//        _priceLabel.backgroundColor = [UIColor greenColor];
        _priceLabel.text = @"¥599.00";
        
        self.originalPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.priceLabel.frame), self.titleLabel.frame.size.width, self.titleLabel.frame.size.height/2)];
        self.originalPriceLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
        self.originalPriceLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.originalPriceLabel];
//        _originalPriceLabel.backgroundColor = [UIColor blueColor];
        _originalPriceLabel.text = @"¥700.00";
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(10, _selectedButton.bottom + 0.5, DEVICE_WIDTH - 10, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [self.contentView addSubview:line];
        
        /**
         *  主套餐加点击事件
         */
        UIButton *cellClickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cellClickButton.frame = CGRectMake(_selectedButton.right, 0, DEVICE_WIDTH - _selectedButton.right, line.top);
        [self.contentView addSubview:cellClickButton];
//        cellClickButton.backgroundColor = [UIColor orangeColor];
        [cellClickButton addTarget:self action:@selector(clickMainSetmeal:) forControlEvents:UIControlEventTouchUpInside];
                                 
        
//        100 + 0.5
        
        //拓展套餐
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, line.bottom, DEVICE_WIDTH - 20, 30) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"购买该套餐的用户还购买了这些加项"];
        [self.contentView addSubview:label];
        label.backgroundColor = [UIColor orangeColor];
        self.additionTitleLabel = label;
        
        //+30
        
        //--------------拓展项目 start
        
        self.additonView = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom, DEVICE_WIDTH, 0)];
//        _additonView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_additonView];
        
        self.selectAllButton = [PropertyButton buttonWithType:UIButtonTypeCustom];
        _selectAllButton.frame = CGRectMake(0, _additonView.bottom, DEVICE_WIDTH, 40);
        [_selectAllButton addTarget:self action:@selector(clickToSelectAllAddtion:) forControlEvents:UIControlEventTouchUpInside];//选择全部附加项
        [self.contentView addSubview:_selectAllButton];
        
        UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        iconButton.frame = CGRectMake(15, 0, 30, 40);
        [iconButton setImage:[UIImage imageNamed:@"selected_small_selected"] forState:UIControlStateSelected];
        [iconButton setImage:[UIImage imageNamed:@"selected_small_normal"] forState:UIControlStateNormal];
        [_selectAllButton addSubview:iconButton];
        
        _selectAllButton.selectedButton = iconButton;
        
        
        UILabel *allLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconButton.right, iconButton.top, 50, iconButton.height) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR title:@"全选"];
        [_selectAllButton addSubview:allLabel];
    }
    return self;
}

+ (CGFloat)heightForCellWithModel:(NSDictionary *)dic
{
    CGFloat height = 100 + 0.5;
    height += 40;//底部全选

    //加强包部分高度
    //加强包
    NSArray *setmeal_package = dic[@"setmeal_package"];
    int count = (int)setmeal_package.count;
    if (count > 0) {
        height += 30;//拓展标题

        CGFloat top = 0.f;
        if ([setmeal_package isKindOfClass:[NSArray class]]) {
            
            for (int i = 0; i < count; i ++) {
                
                NSDictionary *temp = setmeal_package[i];
                CGFloat h_addtion = [AddtionView heightForAddtionViewWithDic:temp];
                
                top += h_addtion;
            }
        }
        height += top;
    }else
    {
//        height -= 30;//标题
        height -= 40;//全部按钮
    }
    
    return height;
}

- (void)setCellWithModel:(NSDictionary *)dic
{
    NSDictionary *setmeal_info = dic[@"setmeal_info"];
    if ([setmeal_info isKindOfClass:[NSDictionary class]]) {
        
        self.mainDic = setmeal_info;
        
        NSString *cover_pic = setmeal_info[@"cover_pic"];
        [self.logoImv l_setImageWithURL:[NSURL URLWithString:cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
        NSString *setmeal_name = setmeal_info[@"setmeal_name"];
        self.titleLabel.text = setmeal_name;
        NSString *setmeal_original_price = setmeal_info[@"setmeal_original_price"];
        setmeal_original_price =  [NSString stringWithFormat:@"¥%.2f",[setmeal_original_price floatValue]];

        [self.originalPriceLabel setAttributedText:[LTools attributedString:setmeal_original_price underlineKeyword:setmeal_original_price color:DEFAULT_TEXTCOLOR_TITLE_SUB keywordFontSize:12]];
        
        NSString *setmeal_price = setmeal_info[@"setmeal_price"];
        self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",[setmeal_price floatValue]];
    }
    
    //加强包
    NSArray *setmeal_package = dic[@"setmeal_package"];
    
    if ([setmeal_package isKindOfClass:[NSArray class]]) {
        
        self.additonSetMealDic = setmeal_package;
        
        CGFloat top = 0.f;
        int count = (int)setmeal_package.count;
        
        if (count == 0) {
            
            self.additionTitleLabel.hidden = YES;
            _selectAllButton.hidden = YES;
        }else
        {
            self.additionTitleLabel.hidden = NO;
            _selectAllButton.hidden = NO;
        }
        
        for (int i = 0; i < count; i ++) {
            
            NSString *key = [NSString stringWithFormat:@"additionView%d",i];
            AddtionView *additon = self.additonDic[key];
            if (!additon) { //不存在创建
                additon = [[AddtionView alloc]initWithFrame:CGRectMake(15, top, DEVICE_WIDTH - 30, 0) target:self action:@selector(clickToSelectOneAddition:) tag:100 + i];
                [_additonView addSubview:additon];
                [self.additonDic setValue:additon forKey:key];
                DDLOG(@"hahahhahhah");

            }
            
            NSDictionary *temp = setmeal_package[i];
            CGFloat height = [AddtionView heightForAddtionViewWithDic:temp];
            additon.height = height;
//            addtion.backgroundColor = [UIColor blueColor];
            [additon setAdditonViewWithDic:temp];
            
            top = additon.bottom;
            
        }
        
        _additonView.height = top;
    }
    
    self.selectAllButton.top = _additonView.bottom;
}

#pragma mark - 事件处理

/**
 *  点击主套餐
 *
 *  @param
 */
- (void)clickMainSetmeal:(UIButton *)btn
{
    if (_MainSetMealClickBlcok) {
        if (self.mainDic) {
            _MainSetMealClickBlcok(self.mainDic);
        }
    }
}

-(void)setAdditonSelectBlock:(void (^)(int index,BOOL add,NSDictionary *dic))AdditonSelectBlock
{
    _AdditonSelectBlock = AdditonSelectBlock;
}

//block数据回调
- (void)rebackSetmeal:(NSDictionary *)setmeal
{
    if (_AdditonSelectBlock) {
        _AdditonSelectBlock(self.selectIndex,YES,setmeal);
    }
}

/**
 *  选择全部附加项
 *
 *  @param btn
 */
- (void)clickToSelectAllAddtion:(PropertyButton *)btn
{
    if (![btn isKindOfClass:[PropertyButton class]]) {
        return;
    }
    btn.selectedState = !btn.selectedState;
    for (int i = 0; i < self.additonSetMealDic.count; i ++) {
        [self buttonWithTag:100 + i].selectedState = btn.selectedState;
    }
    //只要有一个点中,主套餐必须被选中
    if (btn.selectedState) {
        _selectedButton.selected = YES;
    }
    //添加或者删除全部
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safeSetValue:self.mainDic forKey:Select_main];
    if (btn.selectedState) {
        
        [dic safeSetValue:self.additonSetMealDic forKey:Select_additon];

    }
    [self rebackSetmeal:dic];
}

/**
 *  选择主套餐
 *
 *  @param btn
 */
- (void)clickToSelectMain:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (!btn.selected) { //主套餐未被选择
        for (int i = 0; i < self.additonSetMealDic.count; i ++) {
            [self buttonWithTag:100 + i].selectedState = NO;//附属套餐取消
        }
        _selectAllButton.selectedState = NO;
    }
    //添加或者删除全部
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (btn.selected) { //选择主套餐
        [dic safeSetValue:self.mainDic forKey:Select_main];
    }
    [self rebackSetmeal:dic];
}

/**
 *  选择单个附加项
 *
 *  @param btn
 */
- (void)clickToSelectOneAddition:(PropertyButton *)btn
{
    if (![btn isKindOfClass:[PropertyButton class]]) {
        return;
    }
    btn.selectedState = !btn.selectedState;
    
    //只要有一个点中,主套餐必须被选中
    if (btn.selectedState) {
        _selectedButton.selected = YES;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //添加或者删除全部
    [dic safeSetValue:self.mainDic forKey:Select_main];
    
    if ([self isAllSelected]) {
        
        _selectAllButton.selectedState = YES;
        
    }else
    {
        _selectAllButton.selectedState = NO;
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < self.additonSetMealDic.count; i ++) {
        if ([self buttonWithTag:100 + i].selectedState) {
            
            [temp addObject:_additonSetMealDic[i]];
        }
    }
    [dic safeSetValue:temp forKey:Select_additon];

    [self rebackSetmeal:dic];
}

/**
 *  判断是否全部选中
 *
 *  @return
 */
- (BOOL)isAllSelected
{
    for (int i = 0; i < self.additonSetMealDic.count ; i ++) {
        if ([self buttonWithTag:100 + i].selectedState == NO) {
            
            return NO;
        }
    }
    return YES;
}


- (PropertyButton *)buttonWithTag:(int)tag
{
    return [_additonView viewWithTag:tag];
}

/**
 *  重置选择状态
 */
- (void)resetSelectState
{
    for (int i = 0; i < self.additonSetMealDic.count; i ++) {
        [self buttonWithTag:100 + i].selectedState = NO;//附属套餐取消
    }
    _selectAllButton.selectedState = NO;
}

@end

#pragma mark - 自定义附加项view

/**
 *  附加项自定义view
 */

@interface AddtionView ()

@property(nonatomic,retain)UILabel *nameLabel;
@property(nonatomic,retain)UILabel *priceLabel;
@property(nonatomic,retain)UIButton *selectAllButton;
@property(nonatomic,retain)PropertyButton *projectBtn;

@end

@implementation AddtionView


- (instancetype)initWithFrame:(CGRect)frame
                       target:(id)target
                       action:(SEL)selector
                          tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        
        PropertyButton *projectBtn = [PropertyButton buttonWithType:UIButtonTypeCustom];
        projectBtn.frame = CGRectMake(0, 0, frame.size.width , frame.size.height);
//        projectBtn.backgroundColor = [UIColor blueColor];
        [projectBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];//选择单个附加项
        [self addSubview:projectBtn];
        self.projectBtn = projectBtn;
        
        projectBtn.tag = tag;

        UIButton *selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        selectAllButton.backgroundColor = [UIColor greenColor];
        selectAllButton.frame = CGRectMake(0, 0, 30, 14);
        [selectAllButton setImage:[UIImage imageNamed:@"selected_small_selected"] forState:UIControlStateSelected];
        [selectAllButton setImage:[UIImage imageNamed:@"selected_small_normal"] forState:UIControlStateNormal];
        [projectBtn addSubview:selectAllButton];
        projectBtn.selectedButton = selectAllButton;
        
        self.selectAllButton = selectAllButton;

        
        NSString *keyword = @"";
        NSString *text = [NSString stringWithFormat:@"%@",keyword];
        
        CGFloat width = DEVICE_WIDTH - 30 - 10 - 30;
        //name
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(selectAllButton.right, selectAllButton.top, width, 50) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:nil];
        name.numberOfLines = 0;
        name.lineBreakMode = NSLineBreakByCharWrapping;
        [projectBtn addSubview:name];
//        name.backgroundColor = [UIColor purpleColor];
        [name setAttributedText:[LTools attributedString:text keyword:keyword color:DEFAULT_TEXTCOLOR_TITLE_THIRD]];
        self.nameLabel = name;
        
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(name.left, name.bottom + 8, 160, 12) font:11 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_ORANGE title:@"¥788.00"];
        [projectBtn addSubview:priceLabel];
//        priceLabel.backgroundColor = [UIColor orangeColor];
        self.priceLabel = priceLabel;
        
    }
    return self;
}

- (void)setAdditonViewWithDic:(NSDictionary *)dic
{
    NSArray *package_project = dic[@"package_project"];
    NSString *package_name = dic[@"package_name"];
    NSString *keyword = [package_project componentsJoinedByString:@"、"];
    keyword = [NSString stringWithFormat:@"(%@)",keyword];
    NSString *text = [NSString stringWithFormat:@"%@%@",package_name,keyword];
    
    [self.nameLabel setAttributedText:[LTools attributedString:text keyword:keyword color:DEFAULT_TEXTCOLOR_TITLE_THIRD]];
    
    self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",[dic[@"package_price"]floatValue]];

    //调整UI
    CGFloat width = DEVICE_WIDTH - 30 - 10 - 30;
    
    CGFloat height = [LTools heightForText:text width:width font:13];
    self.nameLabel.height = height;
    self.nameLabel.top = 0;
    self.priceLabel.top = _nameLabel.bottom + 8;
    self.projectBtn.height = self.priceLabel.bottom + 5;
}

+ (CGFloat)heightForAddtionViewWithDic:(NSDictionary *)dic
{
    //调整UI
    CGFloat width = DEVICE_WIDTH - 30 - 10 - 30;
    
    NSArray *package_project = dic[@"package_project"];
    NSString *package_name = dic[@"package_name"];
    NSString *keyword = [package_project componentsJoinedByString:@"、"];
    keyword = [NSString stringWithFormat:@"(%@)",keyword];
    NSString *text = [NSString stringWithFormat:@"%@%@",package_name,keyword];
    
    CGFloat height = [LTools heightForText:text width:width font:13];

    height += 8;
    height += 12;
    height += 5;
    return height;
}

@end
