//
//  UIImage+SizeScale.m
//  Bugoo
//
//  Created by 杨志勇 on 2016/12/1.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import "UIImage+SizeScale.h"

@implementation UIImage (SizeScale)

+ (UIImage *) resizableBackAreaImage:(NSString *)imageName
{
    UIImage *normal = [UIImage imageNamed:imageName];
    CGFloat w = normal.size.width * 0.75;
    CGFloat h = normal.size.height * 0.75;
    return [normal resizableImageWithCapInsets:UIEdgeInsetsMake(h, w, h , w )];
}

@end
