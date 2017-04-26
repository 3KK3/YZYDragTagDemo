//
//  BGTagInfoEditView.m
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import "BGTagInfoEditView.h"
#import "BGTagInfoDisplayCell.h"
#import "UIView+Addition.h"

@interface BGTagInfoEditView () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>
{
    UITableView *_tableView;
    UIWindow *_strongWindow;
    BGImageEditorItem *_editorItem;
    NSMutableArray *_tagInfos;
    
    UIPickerView *_pickerView;
    UIView *_pickerToolView;
    NSArray *_pcikerInfoArray;
    BGDisplayInfoType _pickerType;
    BGImageEditorItem *_defaultInfoItem;
}
@end

@implementation BGTagInfoEditView

- (void)dealloc {
    NSLog(@"dealloc edit view");
}

- (instancetype)initWithEditorItem:(BGImageEditorItem *)editorItem defaultInfoItem:(BGImageEditorItem *)defaultInfoItem{
    
    CGRect selfRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame: selfRect];
    if (self) {
        _editorItem = editorItem;
        _defaultInfoItem = defaultInfoItem;
        _tagInfos = [NSMutableArray arrayWithArray: [_editorItem displayInfoArray]];
        [self createUI];
    }
    return self;
}

- (void)createUI {
    
    UIWindow *newWidow = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    _strongWindow = newWidow;
    newWidow.hidden = NO;
    [newWidow addSubview: self];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame: newWidow.bounds];
    [self addSubview: toolbar];
    toolbar.translucent = YES;
    toolbar.alpha = 0.9;
    
    UIView *whiteView = [[UIView alloc] initWithFrame: toolbar.frame];
    [self addSubview: whiteView];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.alpha = 0.3;
    
    _tableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 64, kScreenSize.width, 24 + [BGTagInfoDisplayCell displayCellHeight] * 6) style: UITableViewStylePlain];
    [self addSubview: _tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];

    self.y = kScreenSize.height;
    
    UIView *bottomView = [[UIView alloc] initWithFrame: CGRectMake(0, _tableView.maxY + 74, kScreenSize.width, 40)];
    [self addSubview: bottomView];
    bottomView.backgroundColor = [UIColor clearColor];
    
    if (kScreenSize.width == 320) {
        bottomView.y = _tableView.maxY + 30;
    }
    
    CGFloat btnInterval = 5;
    CGFloat btnHeight = 40;
    CGFloat btnWidth = (kScreenSize.width - 20 * 2 - btnInterval) / 2;

    {
        UIButton *saveBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [bottomView addSubview: saveBtn];
        [saveBtn setTitle: @"确认" forState: UIControlStateNormal];
        [saveBtn setTintColor: UIColorFromRGB(0xffffff, 1)];
        saveBtn.titleLabel.font = [UIFont systemFontOfSize: 16];
        saveBtn.layer.cornerRadius = 1;
        saveBtn.layer.masksToBounds = YES;
        saveBtn.layer.backgroundColor = UIColorFromRGB(0xF6A623, 1).CGColor;
        saveBtn.frame = CGRectMake(bottomView.width / 2 + btnInterval / 2,0, btnWidth, btnHeight);
        [saveBtn addTarget: self action: @selector(saveBtnClick) forControlEvents: UIControlEventTouchUpInside];
    }
    {
        UIButton *cancelBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [bottomView addSubview: cancelBtn];
        [cancelBtn setTitle: @"取消" forState: UIControlStateNormal];
        [cancelBtn setTitleColor: UIColorFromRGB(0x232323, 1) forState: UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize: 16];
        cancelBtn.frame = CGRectMake(20,0, btnWidth, btnHeight);
        cancelBtn.layer.cornerRadius = 1;
        cancelBtn.layer.borderColor = UIColorFromRGB(0x4A4A4A, 1).CGColor;
        cancelBtn.layer.masksToBounds = YES;
        cancelBtn.layer.borderWidth = 0.5f;
        [cancelBtn addTarget: self action: @selector(cancelBtnClick) forControlEvents: UIControlEventTouchUpInside];
    }
    
    [self addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapGesAction)]];
}

- (void)tapGesAction {
    [self endEditing: YES];
}

- (void)showTagInfoEditView {
    
    [UIView animateWithDuration: 0.3f delay: 0.0f usingSpringWithDamping: 0.7f initialSpringVelocity: 0.1f options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.y = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissEditView {
    [UIView animateWithDuration: 0.3f delay: 0.0f usingSpringWithDamping: 0.7f initialSpringVelocity: 0.7f options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.y = kScreenSize.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        _strongWindow = nil;
    }];
}

#pragma mark --- tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [BGTagInfoDisplayCell displayCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kTagInfoDisplayCellIdentifier = @"TagInfoDisplayCellIdentifier";
    
    BGTagInfoDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier: kTagInfoDisplayCellIdentifier];
    
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed: @"BGTagInfoDisplayCell" owner: nil options: nil].firstObject;
    }
    
    NSInteger inputIndex = [self inputIndexWithIndexPath: indexPath];
    
    cell.canEditContent = YES;
    
    WEAKSELF
    
    cell.inputCompleion = ^(NSString *inputText, BGDisplayInfoType currentType){
       
        id newContent = inputText;
        
        if (inputText.length <= 0) {
            newContent = [NSNull null];
        }
        
        [weakSelf handleInputCompletionWithIndex: currentType content: newContent];
    };
    
    cell.showPickerBlock = ^ (BGDisplayInfoType type, NSString *tfText){
        [weakSelf shwoPickerViewWithType: type indexPath:indexPath TFText: tfText];
    };
    
    [cell setContent: _tagInfos[inputIndex] displayType: inputIndex lastContent: [_defaultInfoItem displayInfoArray][inputIndex]];
    
    return cell;
}

- (void)handleInputCompletionWithIndex:(NSInteger)index content:(id)newContent {
    [_tagInfos replaceObjectAtIndex: index withObject: newContent];
}

- (NSInteger)inputIndexWithIndexPath:(NSIndexPath *)indexPath {
    NSInteger inputIndex = indexPath.row;
    if (indexPath.section == 1) {
        inputIndex = 3 + indexPath.row;
    }
    return inputIndex;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 22;
    }
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, _tableView.width, 22)];
        return headerView;
    }
    return nil;
}

- (void)saveBtnClick {
    self.saveCompletion([self resultItem]);
    
    [self dismissEditView];
}

- (void)cancelBtnClick {
    self.cancelCompletion(_editorItem);
    
    [self dismissEditView];
}

- (BGImageEditorItem *)resultItem {
    
    for (NSInteger index = 0; index < _tagInfos.count; index ++) {
        
        id content = _tagInfos[index];
        
        if (content == [NSNull null]) {
            content = nil;
        }
        
        switch (index) {
                
            case BGDisplayInfoTypeShopAddress: {    //店铺地址
                _editorItem.shopAddress = content;
            }
                break;
                
            case BGDisplayInfoTypePhoneNum: {     //☎️
                _editorItem.phoneNum = content;
            }
                break;
                
            case BGDisplayInfoTypeShopHours: {    //营业时间
                _editorItem.shopHours = content;
            }
                break;
                
            case BGDisplayInfoTypeBrand: {    //品牌
                _editorItem.brand = content;
            }
                break;
                
            case BGDisplayInfoTypeCurrency: {    //币种
                _editorItem.currency = content;
            }
                break;
                
            case BGDisplayInfoTypePrice: {    //价格
                _editorItem.price = content;
            }
                break;
        }
    }
    
    if (_editorItem.brand || _editorItem.price) {
        _editorItem.hasTag = YES;
    } else {
        _editorItem.hasTag = NO;
    }
    
    return _editorItem;
}

- (void)shwoPickerViewWithType:(BGDisplayInfoType)type indexPath:(NSIndexPath *)indexPath TFText:(NSString *)content {
    
    id lastContent =  [_defaultInfoItem displayInfoArray][[self inputIndexWithIndexPath: indexPath]];
    
    if (content.length <= 0 && lastContent != [NSNull null]) {
        content = lastContent;
    }
    
    BGTagInfoDisplayCell * cell = [_tableView cellForRowAtIndexPath: indexPath];
    [cell setPickerViewDefaultContent: lastContent];
    
    _pickerType = type;
    _tableView.userInteractionEnabled = NO;
    _pickerView = [[UIPickerView alloc] initWithFrame: CGRectMake(0, self.height , self.width, 256)];
    [self addSubview: _pickerView];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    _pickerView.backgroundColor = [UIColor whiteColor];
    
    UIView *toolView = [[UIView alloc] initWithFrame: CGRectMake(0, _pickerView.y, _pickerView.width, 40)];
    [self addSubview: toolView];
    toolView.backgroundColor = [UIColor whiteColor];
    _pickerToolView = toolView;
    
    {
        UIButton *doneBtn = [UIButton buttonWithType: UIButtonTypeSystem];
        doneBtn.frame = CGRectMake(toolView.width - 10 - 30, 0, 30, toolView.height);
        [doneBtn setTitle: @"完成" forState: UIControlStateNormal];
        [toolView addSubview: doneBtn];
        doneBtn.titleLabel.font = [UIFont systemFontOfSize: 14];
        [doneBtn addTarget: self action: @selector(confirmPickerSelectAction) forControlEvents: UIControlEventTouchUpInside];
    }
    {
        UIButton *cancelBtnBtn = [UIButton buttonWithType: UIButtonTypeSystem];
        cancelBtnBtn.frame = CGRectMake(10 , 0, 30, toolView.height);
        [cancelBtnBtn setTitle: @"取消" forState: UIControlStateNormal];
        [toolView addSubview: cancelBtnBtn];
        cancelBtnBtn.titleLabel.font = [UIFont systemFontOfSize: 14];
        [cancelBtnBtn addTarget: self action: @selector(cancelPickerSelectAction) forControlEvents: UIControlEventTouchUpInside];
    }
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(toolView.width / 2 - 50, 0, 100, toolView.height)];
    titleLabel.font = [UIFont systemFontOfSize: 16];
    titleLabel.textColor = [UIColor blackColor];
    [toolView addSubview: titleLabel];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImageView *line = [[UIImageView alloc] initWithFrame: CGRectMake(0, toolView.height - 0.5, toolView.width, 0.5)];
    line.backgroundColor = UIColorFromRGB(0x8E8E93, 1);
    [toolView addSubview: line];
    
    switch (type) {
        case BGDisplayInfoTypeShopHours: {
            titleLabel.text = @"营业时间段";
            
            NSMutableArray *openHours = [NSMutableArray array];

            for (NSInteger i = 0; i <= 47; i ++) {
                
                NSString *half = @"0";
                if (i % 2) {
                    half = @"3";
                }
                [openHours addObject: [NSString stringWithFormat: @"%ld:%@0", i / 2,half]];
            }
            
            _pcikerInfoArray = [NSArray arrayWithArray: openHours];
        }
            break;
            
        case BGDisplayInfoTypeCurrency: {
            _pcikerInfoArray = [NSArray arrayWithObjects: @"人民币",@"美元",@"英镑",@"欧元",@"韩元",@"港币",@"日元",@"新台币", nil];
            titleLabel.text = @"币种";
        }
            break;
            
        default:
            break;
    }
    [_pickerView reloadAllComponents];
    
    switch (type) {
        case BGDisplayInfoTypeShopHours:
        {

            
            [_pickerView selectRow: [self pickerSelectIndexForContent: [self openTimeWithShopHoursStr: content]] inComponent: 0 animated: NO];
            
            [_pickerView selectRow: [self pickerSelectIndexForContent: [self endTimeWithShopHoursStr: content]] inComponent: 1 animated: NO];
        }
            break;
            
        case BGDisplayInfoTypeCurrency: {

            [_pickerView selectRow: [self pickerSelectIndexForContent: content] inComponent: 0 animated: NO];
        }
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration: 0.2 animations:^{
        _pickerView.y = self.height - _pickerView.height;
        _pickerToolView.y = _pickerView.y - 40;
    }];
}

- (NSString *)openTimeWithShopHoursStr:(NSString *)shopHours {
    
    if (shopHours.length <= 0) {
        return nil;
    }
    
    NSRange range = [shopHours rangeOfString: @"-"];
    
    NSString *openHour = [shopHours substringWithRange: NSMakeRange(0, range.location - 1)];
    
    return openHour;
}

- (NSString *)endTimeWithShopHoursStr:(NSString *)shopHours {
    if (shopHours.length <= 0) {
        return nil;
    }
    NSRange range = [shopHours rangeOfString: @"-"];
    
    NSString *endTime = [shopHours substringWithRange: NSMakeRange(range.location + 2,shopHours.length - 2 - range.location)];
    
    return endTime;
}

- (NSInteger)pickerSelectIndexForContent:(NSString *)content {
    NSInteger index = 0;
    
    for (NSInteger i = 0; i < _pcikerInfoArray.count; i++) {
        
        if ([content isEqualToString: _pcikerInfoArray[i]]) {
            
            index = i;
            break;
        }
    }
    return index;
}

- (void)cancelPickerSelectAction {
    [self dismissPickerViewAnim];
    [_tableView reloadData];
}

- (void)dismissPickerViewAnim {
    [UIView animateWithDuration: 0.2f animations:^{
        _pickerView.y = self.height - 40;
        _pickerToolView.y = _pickerView.y;
    }completion:^(BOOL finished) {
        [_pickerView removeFromSuperview];
        _pickerView = nil;
        [_pickerToolView removeFromSuperview];
        _pickerToolView = nil;
        _tableView.userInteractionEnabled = YES;
    }];
}

- (void)confirmPickerSelectAction {

    [self dismissPickerViewAnim];

    switch (_pickerType) {
        case BGDisplayInfoTypeShopHours:{
            
            NSInteger openRow = [_pickerView selectedRowInComponent: 0];
            NSInteger endRow = [_pickerView selectedRowInComponent: 1];

            [_tagInfos replaceObjectAtIndex: _pickerType withObject: [NSString stringWithFormat: @"%@ - %@",_pcikerInfoArray[openRow] , _pcikerInfoArray[endRow]]];
            [_tableView reloadData];
        }
            break;
            
        case BGDisplayInfoTypeCurrency:{
            NSInteger selectRow = [_pickerView selectedRowInComponent: 0];
            [_tagInfos replaceObjectAtIndex: _pickerType withObject: _pcikerInfoArray[selectRow]];
            [_tableView reloadData];
        }
            break;
        default:
            break;
    }
}

#pragma mark --- pciker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (_pickerType) {
        case BGDisplayInfoTypeShopHours:{
            return 2;
        }
            break;
            
        case BGDisplayInfoTypeCurrency:{
            return 1;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    switch (_pickerType) {
        case BGDisplayInfoTypeShopHours:{
            return _pcikerInfoArray.count;
        }
            break;
            
        case BGDisplayInfoTypeCurrency:{
            return _pcikerInfoArray.count;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (_pickerType) {
        case BGDisplayInfoTypeShopHours:{

            NSString *title = _pcikerInfoArray[row];
            
            return [[NSAttributedString alloc] initWithString: title];
        }
            break;
            
        case BGDisplayInfoTypeCurrency:{
            
            NSString *title = _pcikerInfoArray[row];
            
            return [[NSAttributedString alloc] initWithString: title];
        }
            break;
        default:
            break;
    }
    return nil;
}


@end






