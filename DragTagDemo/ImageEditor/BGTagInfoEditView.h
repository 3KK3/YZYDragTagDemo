//
//  BGTagInfoEditView.h
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGImageEditorItem.h"

@interface BGTagInfoEditView : UIView

@property (nonatomic, copy) void (^saveCompletion)(BGImageEditorItem *);

@property (nonatomic, copy) void (^cancelCompletion)(BGImageEditorItem *);

- (instancetype)initWithEditorItem:(BGImageEditorItem *)editorItem defaultInfoItem:(BGImageEditorItem *)defaultInfoItem;

- (void)showTagInfoEditView;

@end
