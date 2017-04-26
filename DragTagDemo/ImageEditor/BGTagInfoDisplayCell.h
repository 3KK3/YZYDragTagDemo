//
//  BGTagInfoDisplayCell.h
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGImageEditorItem.h"

@interface BGTagInfoDisplayCell : UITableViewCell

@property (nonatomic, assign) BOOL canEditContent;

@property (nonatomic, copy) void(^inputCompleion)(NSString * , BGDisplayInfoType);

@property (nonatomic, copy) void(^showPickerBlock)(BGDisplayInfoType, NSString *textFieldText);

- (void)setContent:(id)content displayType:(BGDisplayInfoType)displayType lastContent:(id)lastContent;

- (void)setPickerViewDefaultContent:(id)content;

+ (CGFloat)displayCellHeight;

@end
