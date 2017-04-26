//
//  BGTagInfoDisplayCell.m
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import "BGTagInfoDisplayCell.h"
#import "UIView+Addition.h"

@interface BGTagInfoDisplayCell () <UITextFieldDelegate>

@end

@implementation BGTagInfoDisplayCell
{
    __weak IBOutlet UIButton *_pickerBtn;
    __weak IBOutlet UIImageView *_iconImgView;
    __weak IBOutlet UITextField *_contentTF;
    __weak IBOutlet UILabel *_headerTipLabel;
//    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UILabel *_wordsTipLabel;
    NSInteger _limitedNum;
    BGDisplayInfoType _currentType;
    __weak IBOutlet UIImageView *_cutlineImgView;
    
    __weak IBOutlet UIButton *_delTextBtn;
    id _lastContent;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.canEditContent = NO;
    _contentTF.tintColor = UIColorFromRGB(0xF6A623, 1);
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object: _contentTF];
    self.backgroundColor = [UIColor clearColor];
    
    UIButton *clearButton = [_contentTF valueForKey:@"_clearButton"];
    [clearButton setImage:[UIImage imageNamed:@"btn_del-1"] forState:UIControlStateNormal];
    [clearButton setImage:[UIImage imageNamed:@"btn_del-1"] forState:UIControlStateHighlighted];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        return;
    }
    
    switch (_currentType) {
        case BGDisplayInfoTypePrice: {
            return;
        }
            break;
            
        default:
            break;
    }
    
    if (_lastContent == [NSNull null]) {
        return;
    }

    textField.text = _lastContent;
    if (self.inputCompleion) {
        self.inputCompleion(textField.text, _currentType);
    }
}

- (void)setPickerViewDefaultContent:(id)content {
    if (content == [NSNull null]) {

        return;
    }
    
    if (_contentTF.text.length > 0) {
        return;
    }
    
    _contentTF.text = content;
}

- (void)textFiledEditChanged:(NSNotification *)obj {
    UITextField *textField = (UITextField *) obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    // 简体中文输入
    if ([lang isEqualToString:@"zh-Hans"]) {
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > _limitedNum) {
                textField.text = [toBeString substringToIndex:_limitedNum];
            }
        }
        
    } else { // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        
        if (toBeString.length > _limitedNum) {
            
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:_limitedNum];
            if (rangeIndex.length == 1) {
                textField.text = [toBeString substringToIndex:_limitedNum];
            } else {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, _limitedNum)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    
    if (self.inputCompleion) {
        self.inputCompleion(textField.text, _currentType);
    }
}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    
//
//}

- (void)setCanEditContent:(BOOL)canEditContent {
    _canEditContent = canEditContent;
    _contentTF.userInteractionEnabled = canEditContent;
}
- (IBAction)delTextBtnAction:(id)sender {
    _contentTF.text = nil;
    _delTextBtn.hidden = YES;
    self.inputCompleion(nil,_currentType);
}

- (void)setContent:(id)content displayType:(BGDisplayInfoType)displayType lastContent:(id)lastContent {
    if (content != [NSNull null]) {
        _contentTF.text = content;
    }
    
    _lastContent = lastContent;
    _delTextBtn.hidden = YES;
    _currentType = displayType;
    _contentTF.userInteractionEnabled = YES;
    _limitedNum = 100;
    _contentTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    _headerTipLabel.hidden = YES;
    _wordsTipLabel.hidden = YES;
    _pickerBtn.hidden = YES;
    
    UIImage * iconImg = nil;
    
    switch (displayType) {
        
        case BGDisplayInfoTypeShopAddress: {    //店铺地址
            iconImg = [UIImage imageNamed: @"Location-img"];
            _headerTipLabel.hidden = NO;
            _headerTipLabel.text = @"基本信息";
            _contentTF.placeholder = @"地址";
//            _contentTF.width = _cutlineImgView.maxX - _contentTF.x;
        }
            break;
            
        case BGDisplayInfoTypePhoneNum: {    //☎️
            iconImg = [UIImage imageNamed: @"Tel-img"];
            _contentTF.placeholder = @"电话";
            _limitedNum = 20;
//            _wordsTipLabel.hidden = NO;
            _wordsTipLabel.text = @"20";
            _contentTF.keyboardType = UIKeyboardTypePhonePad;
        }
            break;
            
        case BGDisplayInfoTypeShopHours: {    //营业时间
            iconImg = [UIImage imageNamed: @"Open-img"];
            _contentTF.placeholder = @"营业时间";
            _contentTF.userInteractionEnabled = NO;
            _pickerBtn.hidden = NO;
            _delTextBtn.hidden = _contentTF.text.length <= 0;

        }
            break;
            
        case BGDisplayInfoTypeBrand: {    //品牌
            iconImg = [UIImage imageNamed: @"Tag-img"];
            _headerTipLabel.hidden = NO;
            _headerTipLabel.text = @"吊牌信息";
            _contentTF.placeholder = @"品牌/名称";
            _limitedNum = 10;
//            _wordsTipLabel.hidden = NO;
            _wordsTipLabel.text = @"10";
        }
            break;
            
        case BGDisplayInfoTypeCurrency: {    //币种
            iconImg = [UIImage imageNamed: @"currency-img"];
            _contentTF.placeholder = @"币种";
            _contentTF.userInteractionEnabled = NO;
            _pickerBtn.hidden = NO;
            _delTextBtn.hidden = _contentTF.text.length <= 0;
        }
            break;
            
        case BGDisplayInfoTypePrice: {    //价格
            iconImg = [UIImage imageNamed: @"monney-img"];
            _contentTF.placeholder = @"价格";
            _limitedNum = 8;
//            _wordsTipLabel.hidden = NO;
            _wordsTipLabel.text = @"8";
//            _contentTF.width = _cutlineImgView.maxX - _contentTF.x - 10;
            _contentTF.keyboardType = UIKeyboardTypeNumberPad;
        }
            break;
    }
    
//    [_titleLabel sizeToFit];
//    _contentTF.frame = CGRectMake(_titleLabel.maxX + 5, _contentTF.y, _wordsTipLabel.maxX - _titleLabel.maxX, _contentTF.height);
    _pickerBtn.frame = _contentTF.frame;
//    _contentTF.centerY = _titleLabel.centerY;
//    _iconImgView.centerY = _titleLabel.centerY;
    _iconImgView.image = iconImg;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        [[UIApplication sharedApplication].keyWindow endEditing: YES];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

- (IBAction)showPickerView:(id)sender {
    self.showPickerBlock(_currentType,_contentTF.text);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
+ (CGFloat)displayCellHeight {
    return 64;
}

@end
