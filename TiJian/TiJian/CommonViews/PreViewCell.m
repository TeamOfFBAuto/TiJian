//
//  PreViewCell.m
//  TiJian
//
//  Created by lichaowei on 15/11/11.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PreViewCell.h"
#import "HospitalModel.h"

/**
 *  自定义体检人信息cell
 */
@interface UserInfoCell : UITableViewCell

@property(nonatomic,retain)UIView *basicView;
@property(nonatomic,retain)UILabel *titleLabel;
@property(nonatomic,retain)UILabel *userInfoLabel;
@property(nonatomic,retain)UIButton *deleteBtn;

@end

@implementation UserInfoCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //=============== 已选择体检人信息(这部分需要根据实际人数变化的)
        self.basicView = [[UIView alloc]initWithFrame:CGRectMake(15, 0, 12 + 40, 45)];
        [self.contentView addSubview:_basicView];
        //图标
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, (43-12)/2.f, 12, 12)];
        icon.image = [UIImage imageNamed:@"tijianren_duo"];
        [_basicView addSubview:icon];
        //title
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 5, 0, 40, 45) title:@"体检人" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
        [_basicView addSubview:self.titleLabel];
        
        //体检人
        self.userInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(_titleLabel.right + 10, 0, DEVICE_WIDTH - 45 - _titleLabel.right - 10, 45) title:@"1.父亲 张木木 3685*******1234" font:12 align:NSTextAlignmentRight textColor:[UIColor colorWithHexString:@"323232"]];
        [self.contentView addSubview:self.userInfoLabel];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"guanbianniu"] forState:UIControlStateNormal];
        _deleteBtn.frame = CGRectMake(_userInfoLabel.right, 0, 45, 45);
        [self.contentView addSubview:_deleteBtn];
    }
    return self;
}

- (void)setCellWithModel:(UserInfo *)aModel
{
    self.userInfoLabel.text = aModel.user_name;
}

@end


@interface PreViewCell()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataArray;
}

@property(nonatomic,retain)UIView *brandView;//品牌相关背景view
@property(nonatomic,retain)UIView *productView;//套餐相关背景view
@property(nonatomic,retain)UIView *timeView;//选择时间分院背景view
@property(nonatomic,retain)UIView *userView;//体检人相关view
@property(nonatomic,retain)UIView *preView;//去预约view

@property(nonatomic,retain)UIImageView *brandIcon;//品牌logo
@property(nonatomic,retain)UILabel *brandName;//品牌name
@property(nonatomic,retain)UIImageView *iconImageView;//套餐图
@property(nonatomic,retain)UILabel *productNameLabel;//套餐name
@property(nonatomic,retain)UILabel *priceLabel;//套餐价格
@property(nonatomic,retain)UILabel *timeAndAreaLabel;//时间和分院label

@property(nonatomic,retain)UITableView *userTable;//体检人信息tableView

@end

@implementation PreViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat left = 15.f;
        
        //===========品牌相关背景view
        self.brandView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        _brandView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_brandView];
        //logo
        self.brandIcon = [[UIImageView alloc]initWithFrame:CGRectMake(left, 12.5, 40, 25)];
        _brandIcon.backgroundColor = DEFAULT_TEXTCOLOR;
        [_brandView addSubview:_brandIcon];
        //name
        self.brandName = [[UILabel alloc]initWithFrame:CGRectMake(_brandIcon.right + 10, 0, _brandView.width - _brandIcon.right - 10 - 15, 50) title:nil font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
        _brandName.text = @"慈铭体检";
        [_brandView addSubview:_brandName];
        
        //线
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _brandView.height - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [_brandView addSubview:line];
        
        //===========套餐相关
        UIView *tc_bgView = [[UIView alloc]initWithFrame:CGRectMake(0, _brandView.bottom, DEVICE_WIDTH, 75)];
        tc_bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:tc_bgView];
        self.productView = tc_bgView;
        
        //套餐图
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, (75 - 50)/2.f, 80, 50)];
        _iconImageView.backgroundColor = DEFAULT_TEXTCOLOR;
        [tc_bgView addSubview:_iconImageView];
        //套餐name
        self.productNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_iconImageView.right + 8, 14, tc_bgView.width - _iconImageView.right - 8 - left, 30) title:@"爱康国宾粉红真爱体检套餐全国通用爱康国宾粉红真爱体检套餐全国通用" font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
        [tc_bgView addSubview:_productNameLabel];
        _productNameLabel.numberOfLines = 2;
        _productNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        //价格
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(_productNameLabel.left, _productNameLabel.bottom + 5, 150, 12) title:nil font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"eb7d24"]];
        _priceLabel.text = @"剩 1 份";
        [tc_bgView addSubview:_priceLabel];
        
        //线
        line = [[UIView alloc]initWithFrame:CGRectMake(12, tc_bgView.height - 0.5, _brandView.width - 12, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [tc_bgView addSubview:line];
        
        //================ 时间、分院 使用tableView
        
        self.userTable = [[UITableView alloc]initWithFrame:CGRectMake(0, tc_bgView.bottom, DEVICE_WIDTH, 45 + 45 * 3) style:UITableViewStylePlain];
        _userTable.delegate = self;
        _userTable.dataSource = self;
        _userTable.scrollEnabled = NO;
        [self.contentView addSubview:_userTable];
        _userTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //==========去预约=======
        UIView *selectView = [[UIView alloc]initWithFrame:CGRectMake(0, _userTable.bottom, DEVICE_WIDTH, 45)];
        selectView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:selectView];
        
        self.preView = selectView;
        
        //线
        line = [[UIView alloc]initWithFrame:CGRectMake(12, 0, selectView.width - 12, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [selectView addSubview:line];
        
        //图标
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(left, (45-12)/2.f, 12, 12)];
        icon.image = [UIImage imageNamed:@"yuyue"];
        [selectView addSubview:icon];
        //title
        UILabel *companyTitle = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 5, 0, 120, 45) title:nil font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
        [selectView addSubview:companyTitle];
        companyTitle.text = @"去预约";
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(selectView.width - 6 - 20, (45-12)/2.f, 6, 12)];
        arrow.image = [UIImage imageNamed:@"jiantou"];
        [selectView addSubview:arrow];
        
    }
    return self;
}

/**
 *  计算cell高度
 *
 *  @param userCount 体检人信息个数
 *  @param lastNum   套餐剩余份数
 *
 *  @return
 */
+ (CGFloat)heightForCellWithUsersCount:(int)userCount
                               lastNum:(int)lastNum
{
    CGFloat pre_height = 0.f;
    //套餐剩余大于0时加45 (去预约部分)
    if (lastNum > 0) {
        
        pre_height = 45.f;
    }
    return 50 + 75 + 45 + 45 * userCount + 5 + pre_height;// 5为底部多出5
}

/**
 *  计算cell高度
 *
 *  @param userCount 体检人信息个数
 *  @param lastNum   套餐剩余份数
 *  @param hospitalArray   分院个数
 *
 *  @return
 */
+ (CGFloat)heightForCellWithUsersCount:(int)userCount
                               lastNum:(int)lastNum
                             hospitalArray:(NSArray *)hospitalArray
{
    CGFloat pre_height = 0.f;
    //套餐剩余大于0时加45 (去预约部分)
    if (lastNum > 0) {
        
        pre_height = 45.f;
    }
    
    
    return 50 + 75 + [self tableHeightWithHospitalArray:hospitalArray] + 5 + pre_height;// 5为底部多出5
}

/**
 *  计算table高度
 *
 *  @param hospitalArray 分院数组
 *
 *  @return
 */
+ (CGFloat)tableHeightWithHospitalArray:(NSArray *)hospitalArray
{
    CGFloat h_height = 0.f;//分院title高度
    CGFloat u_height = 0.f;//体检人信息高度
    int sum = (int)hospitalArray.count;
    if (sum > 0) {
        h_height = 45 * sum;
        
        for (int i = 0; i < sum; i ++) {
            HospitalModel *h_model = hospitalArray[i];
            u_height += h_model.usersArray.count * 45;
        }
    }
    return h_height + u_height;
}

- (void)setCellWithModel:(NSArray *)hospitalArray
{
    _dataArray = [NSMutableArray arrayWithArray:hospitalArray];
    _userTable.height = [PreViewCell tableHeightWithHospitalArray:hospitalArray];
    [_userTable reloadData];
    self.preView.top = _userTable.bottom;
}

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    HospitalModel *aModel = _dataArray[section];
    return aModel.usersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identify = @"UserInfoCell";
    UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UserInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    if (indexPath.row != 0) {
        cell.basicView.hidden = YES;
    }else
    {
        cell.basicView.hidden = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HospitalModel *h_model = _dataArray[indexPath.section];
//    UserInfo *u_model = h_model.usersArray[indexPath.row];
//    [cell setCellWithModel:u_model];
    
    cell.userInfoLabel.text = h_model.usersArray[indexPath.row];
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *head = [tableView viewWithTag:100 +section];
    if (head) {
        return head;
    }
    
    UIView *companyBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 ,DEVICE_WIDTH, 45)];
    companyBgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:companyBgView];
    companyBgView.tag = 100 + section;
    //图标
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(15, (45-12)/2.f, 12, 12)];
    icon.image = [UIImage imageNamed:@"fenyuan"];
    [companyBgView addSubview:icon];
    
    
    HospitalModel *aModel = _dataArray[section];
    NSString *timeAndName = [NSString stringWithFormat:@"%@  %@",aModel.time,aModel.name];
    
    //title
    UILabel *companyTitle = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 5, 0, 100, 45) title:@"时间、分院" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
    [companyBgView addSubview:companyTitle];
    
    //选中时间、分院
    self.timeAndAreaLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 150 - 22.5, 0, 150, companyBgView.height) title:nil font:12 align:NSTextAlignmentRight textColor:[UIColor colorWithHexString:@"323232"]];
    _timeAndAreaLabel.text = timeAndName;
    [companyBgView addSubview:_timeAndAreaLabel];
    
    //线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(12, companyTitle.bottom - 0.5, companyBgView.width - 12, 0.5)];
    line.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"yuyue_xuxian"]];
    [companyBgView addSubview:line];
    return companyBgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

@end
