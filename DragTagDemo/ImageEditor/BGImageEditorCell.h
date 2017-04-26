//
//  BGImageEditorCell.h
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGImageEditorItem.h"

#define kDisPlayImgViewWidth kScreenSize.width

#define kDisPlayImgViewHeight (kScreenSize.width * 450 / 375)

@interface BGImageEditorCell : UICollectionViewCell

@property (nonatomic, copy) void(^tagTapCompletion)(BGImageEditorItem *);

@property (nonatomic, copy) void(^tagDeleteCompletion)(BGImageEditorItem *);

@property (nonatomic, copy) void (^listTapCompletion)(BGImageEditorItem *);

@property (nonatomic, copy) void (^tagEditCompletion)(BGImageEditorItem *); // 特指对吊牌的操作

@property (nonatomic, strong) BGImageEditorItem *editorItem;

+ (CGSize)actualDisplayImageSizeWithItem:(BGImageEditorItem *)item;

@end
