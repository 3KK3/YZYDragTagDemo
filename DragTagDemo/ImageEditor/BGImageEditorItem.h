//
//  BGImageEditorItem.h
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BGTagDirection) {
    BGTagDirectionNone,
    BGTagDirectionLeft,
    BGTagDirectionRight
};

typedef NS_ENUM(NSInteger, BGDisplayInfoType) {
    BGDisplayInfoTypeShopAddress,
    BGDisplayInfoTypePhoneNum,
    BGDisplayInfoTypeShopHours,
    BGDisplayInfoTypeBrand,
    BGDisplayInfoTypeCurrency,
    BGDisplayInfoTypePrice,
};

@interface BGImageEditorItem : NSObject

@property (nonatomic, strong) UIImage *image;                 //图片

@property (nonatomic, assign) BOOL hasTag;                    //有吊牌 默认NO

@property (nonatomic, assign) CGPoint tagLocation;            //吊牌坐标

@property (nonatomic, assign) CGSize backdropSize;            //吊牌所在的背景幕的实际大小

@property (nonatomic, assign) BGTagDirection tagDirection;    //吊牌方向

@property (nonatomic, copy) NSString *shopAddress;            //店铺地址

@property (nonatomic, copy) NSString *phoneNum;               //☎️

@property (nonatomic, copy) NSString *shopHours;              //营业时间段

//@property (nonatomic, copy) NSString *openTime;               //开业时间
//
//@property (nonatomic, copy) NSString *endTime;                //打烊时间

@property (nonatomic, copy) NSString *brand;                  //品牌

@property (nonatomic, copy) NSString *currency;               //币种

@property (nonatomic, copy) NSString *price;                  //价格


@property (nonatomic, assign) BOOL bDefault;                  // 默认NO

@property (nonatomic, copy) NSString *imageUrl;               //上传的图片链接

@property (nonatomic, assign) NSInteger index;


/**
 吊牌上的文字
 */
- (NSString *)imgTagText;

- (NSArray *)displayInfoArray;



@end







