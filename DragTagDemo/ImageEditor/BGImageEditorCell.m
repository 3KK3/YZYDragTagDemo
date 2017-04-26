//
//  BGImageEditorCell.m
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import "BGImageEditorCell.h"
#import "BGImageTagView.h"
#import "BGTagInfoDisplayCell.h"
#import "UIView+Addition.h"

@interface BGImageEditorCell ()

@end

@implementation BGImageEditorCell{
    UIImageView *_displayImgView;
//    UITableView *_tableView;
//    NSMutableArray *_tagInfos;
    BGImageTagView *_tagView;
    UILabel * _defaultTipLabel;
    UILabel *_infoLabel;
    UIView *_addressInfoView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {

        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.clipsToBounds = YES;
        
        CGFloat fitH = kDisPlayImgViewHeight;

        _displayImgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, kDisPlayImgViewWidth, fitH)];
        [self.contentView addSubview: _displayImgView];
        _displayImgView.userInteractionEnabled = YES;
        _displayImgView.contentMode = UIViewContentModeScaleAspectFit;
        [_displayImgView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(displayImgTapAction)]];
        _displayImgView.backgroundColor = UIColorFromRGB(0x333333, 1);
        
//        _tableView = [[UITableView alloc] initWithFrame: CGRectMake(0, _displayImgView.maxY, self.contentView.width, kScreenSize.height - 64 - fitH) style: UITableViewStylePlain];
//        [self.contentView addSubview: _tableView];
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.tableFooterView = [[UIView alloc] init];
//        [_tableView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(listTapAction)]];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
        
//        _tagInfos = [NSMutableArray array];
        
        _defaultTipLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, fitH, kScreenSize.width, kScreenSize.height - fitH - 64)];
        _defaultTipLabel.font = [UIFont systemFontOfSize: 20];
        _defaultTipLabel.textColor = UIColorFromRGB(0x9B9B9B, 1);
        [self.contentView addSubview: _defaultTipLabel];
        _defaultTipLabel.textAlignment = NSTextAlignmentCenter;
        _defaultTipLabel.text = @"点击图片，添加商品信息";
        
        _infoLabel = [[UILabel alloc] initWithFrame: CGRectMake(15, fitH + 18, kScreenSize.width, kScreenSize.height - fitH - 44 - 10)];
        _infoLabel.numberOfLines = 0;
        [self.contentView addSubview: _infoLabel];
        _infoLabel.font = [UIFont systemFontOfSize: 14];
        _infoLabel.textColor = UIColorFromRGB(0x8E8E93, 1);
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        _infoLabel.hidden = YES;
        [_infoLabel addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(listTapAction)]];
        _infoLabel.userInteractionEnabled = YES;
        
        
        _addressInfoView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, kScreenSize.width, 31)];
        [_displayImgView addSubview: _addressInfoView];
        _addressInfoView.hidden = YES;
        
        UIImageView *maskIV = [[UIImageView alloc] initWithFrame: _addressInfoView.bounds];
        [_addressInfoView addSubview: maskIV];
        maskIV.image = [UIImage imageNamed: @"Gradient-bg_1"];
        
        UIImageView *locationIcon = [[UIImageView alloc] initWithFrame: CGRectMake(19, 0, 13, _addressInfoView.height)];
            locationIcon.contentMode = UIViewContentModeCenter;
            locationIcon.image = [UIImage imageNamed: @"Locatio"];
            locationIcon.tag = 10086;
            [_addressInfoView addSubview: locationIcon];

        UIImageView *telIcon = [[UIImageView alloc] initWithFrame: CGRectMake(locationIcon.maxX + 13, 0, 13, _addressInfoView.height)];
            telIcon.contentMode = UIViewContentModeCenter;
            telIcon.image = [UIImage imageNamed: @"Tel"];
            telIcon.tag = 10087;
            [_addressInfoView addSubview: telIcon];

        UIImageView *timeIcon = [[UIImageView alloc] initWithFrame: CGRectMake(telIcon.maxX + 13, 0, 13, _addressInfoView.height)];
            timeIcon.contentMode = UIViewContentModeCenter;
            timeIcon.image = [UIImage imageNamed: @"Time"];
            timeIcon.tag = 10088;
            [_addressInfoView addSubview: timeIcon];
    }
    return self;
}

- (void)setEditorItem:(BGImageEditorItem *)editorItem {
    _editorItem = editorItem;
    
    [_tagView removeFromSuperview];
    
//    [_tagInfos removeAllObjects];
    
//    [_tagInfos addObjectsFromArray: [editorItem displayInfoArray]];
    
//    [_tableView reloadData];
    
    _displayImgView.image = _editorItem.image;
    
//    if (_editorItem.image.size.height / _editorItem.image.size.width > _displayImgView.height / _displayImgView.width) {
//        
//        CGFloat actualWidth = _editorItem.image.size.width * _displayImgView.height / _editorItem.image.size.height;
//        _editorItem.backdropSize = CGSizeMake(actualWidth, _displayImgView.height);
//    } else {
//        CGFloat actualHeight = _editorItem.image.size.height * _displayImgView.width / _editorItem.image.size.width;
//        _editorItem.backdropSize = CGSizeMake(_displayImgView.width, actualHeight);
//    }
    
    _editorItem.backdropSize = [BGImageEditorCell actualDisplayImageSizeWithItem: editorItem];
    
    if (editorItem.hasTag) {
        [self showTagView];
    }
    
    if (editorItem.shopAddress || editorItem.shopHours || editorItem.phoneNum) {
        [self showAddressInfo];
        _addressInfoView.hidden = NO;
        _defaultTipLabel.hidden = YES;
        _infoLabel.hidden = NO;


    } else {
        _addressInfoView.hidden = YES;
        _defaultTipLabel.hidden = NO;
        _infoLabel.hidden = YES;
    }
}

+ (CGSize)actualDisplayImageSizeWithItem:(BGImageEditorItem *)item {
    
    CGFloat actualWidth = kDisPlayImgViewWidth;
    CGFloat actualHeight = kDisPlayImgViewHeight;
    
    if (item.image.size.height / item.image.size.width > kDisPlayImgViewHeight / kDisPlayImgViewWidth) {
        
        actualWidth = item.image.size.width * kDisPlayImgViewHeight / item.image.size.height;
    } else {
        actualHeight = item.image.size.height * kDisPlayImgViewWidth / item.image.size.width;
    }
    
    return CGSizeMake(actualWidth, actualHeight);
}

- (void)showTagView {
    
    _tagView = [[BGImageTagView alloc] initWithLimitRect: CGRectMake(_displayImgView.width / 2 - _editorItem.backdropSize.width / 2, _displayImgView.height / 2 - _editorItem.backdropSize.height / 2, _editorItem.backdropSize.width, _editorItem.backdropSize.height) editorItem: _editorItem];
    [self.contentView addSubview: _tagView];
    _tagView.tagDeleteCompletion = self.tagDeleteCompletion;
    WEAKSELF
    _tagView.tagEditCompletion = ^(BGImageEditorItem *item){
        weakSelf.tagEditCompletion(item);
    };
    
    _tagView.tagTapCompletion = ^(BGImageEditorItem *item){
        weakSelf.tagTapCompletion(item);
    };
}

- (void)showAddressInfo {
    
    NSMutableString *addresInfoStr = [[self checkString: _editorItem.shopHours] mutableCopy];
    
    if ([self checkString: _editorItem.phoneNum].length > 0) {
        
        [addresInfoStr insertString: [NSString stringWithFormat: @"%@\n",[self checkString: _editorItem.phoneNum]] atIndex: 0];
    }
    
    if ([self checkString: _editorItem.shopAddress].length > 0) {
        
        [addresInfoStr insertString: [NSString stringWithFormat: @"%@\n" ,[self checkString: _editorItem.shopAddress]] atIndex: 0];
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString: addresInfoStr];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = 0;
    
    [attrString addAttributes:@{NSParagraphStyleAttributeName : paragraphStyle} range: NSMakeRange(0, addresInfoStr.length)];
    
    _infoLabel.attributedText  = attrString;
    _infoLabel.width = kScreenSize.width - _infoLabel.x * 2;
    [_infoLabel sizeToFit];
    
    _addressInfoView.frame = CGRectMake(0,_displayImgView.height / 2 - _editorItem.backdropSize.height / 2 + _editorItem.backdropSize.height - _addressInfoView.height, _addressInfoView.width, _addressInfoView.height);
    
    UIView *locationView = [_addressInfoView viewWithTag: 10086];
    UIView *telView = [_addressInfoView viewWithTag: 10087];
    UIView *timeView = [_addressInfoView viewWithTag: 10088];

    
    if (_editorItem.shopAddress) {
        locationView.frame = CGRectMake(19, 0, 13, _addressInfoView.height);
        locationView.hidden = NO;
    } else {
        locationView.hidden = YES;
        locationView.frame = CGRectZero;
    }
    
    if (_editorItem.phoneNum) {
        telView.frame = CGRectMake(locationView.maxX + 13, 0, 13, _addressInfoView.height);
        telView.hidden = NO;
    } else {
        telView.hidden = YES;
        telView.frame = locationView.frame;

    }
    
    if (_editorItem.shopHours) {
        timeView.hidden = NO;
        timeView.frame = CGRectMake(telView.maxX + 13, 0, 13, _addressInfoView.height);

    } else {
        timeView.hidden = YES;
    }
}

- (NSString *)checkString:(NSString *)str {
    if (str.length > 0) {
        return str;
    } else {
        return @"";
    }
}

- (void)displayImgTapAction {
    
    self.listTapCompletion(_editorItem);
}

- (void)listTapAction {
    
    self.listTapCompletion(_editorItem);
}

//#pragma mark --- table view datasource and delegate
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return _tagInfos.count;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    id content = _tagInfos[indexPath.row];
//    
//    if (content == [NSNull null]) {
//        return 0.001;
//    }
//    return 50;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    static NSString *const kTagInfoDisplayCellIdentifier = @"TagInfoDisplayCellIdentifier";
//    
//    BGTagInfoDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier: kTagInfoDisplayCellIdentifier];
//    
//    if (!cell) {
//        cell = [[NSBundle mainBundle] loadNibNamed: @"BGTagInfoDisplayCell" owner: nil options: nil].firstObject;
//    }
//    
//    [cell setContent: _tagInfos[indexPath.row] displayType: indexPath.row];
//    
//    return cell;
//}


@end










