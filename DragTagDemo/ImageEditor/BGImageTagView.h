//
//  BGImageTagView.h
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGImageEditorItem.h"

/**
 吊牌类
 */

@interface BGImageTagView : UIView

@property (nonatomic, copy) void(^tagTapCompletion)(BGImageEditorItem *);

@property (nonatomic, copy) void(^tagDeleteCompletion)(BGImageEditorItem *);

@property (nonatomic, copy) void(^tagEditCompletion)(BGImageEditorItem *);

@property (nonatomic, assign) BOOL editEnable; //是否可以操作吊牌 默认yes； 仅展示用 可设为NO

- (instancetype)initWithLimitRect:(CGRect)limitRect
                       editorItem:(BGImageEditorItem *)editorItem;

@end
