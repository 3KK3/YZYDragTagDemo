//
//  BGImgeEditorViewController.h
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGImageEditorItem.h"

/**
 吊牌编辑页面
 */

@interface BGImgeEditorViewController : UIViewController

@property (nonatomic, copy) void (^editCompletion)(NSArray <BGImageEditorItem *>*);

- (instancetype)initWithImages:(NSArray<BGImageEditorItem *> *)images showIndex:(NSUInteger)showIndex;

@end
