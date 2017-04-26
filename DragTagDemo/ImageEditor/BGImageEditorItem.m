//
//  BGImageEditorItem.m
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import "BGImageEditorItem.h"
#import <objc/runtime.h>

@implementation BGImageEditorItem

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _image = nil;
        _hasTag = NO;
        _bDefault = NO;
        _tagLocation = CGPointMake(-1, -1);
        _tagDirection = BGTagDirectionNone;
        _shopAddress = nil;
        _phoneNum = nil;
//        _openTime = nil;
//        _endTime = nil;
        _brand = nil;
        _currency = nil;
        _price = nil;
        _imageUrl = nil;
    }
    return self;
}

- (NSDictionary *)properties_aps
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}

- (NSString *)description {
    
    NSDictionary *propertyDic = [self properties_aps];
    
    NSMutableString *desStr = [@"" mutableCopy];
    
    [propertyDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [desStr appendFormat: @"%@ : %@,",key, obj];
    }];
    [desStr appendFormat: @"\n"];

    return desStr;
}

- (NSString *)imgTagText {
    return [NSString stringWithFormat: @"%@ %@%@", _brand, _price, _currency];
}

//- (NSString *)shopHours {
//    return [NSString stringWithFormat: @"%@~%@", _openTime, _endTime];
//}

- (NSArray *)displayInfoArray {
    
    NSMutableArray *tagInfos = [NSMutableArray array];
    
    for (NSInteger index = 0; index <= 6; index ++) {
        
        switch (index) {
                
            case BGDisplayInfoTypeShopAddress: {    //店铺地址
                if (_shopAddress) {
                    [tagInfos addObject: _shopAddress];
                } else {
                    [tagInfos addObject: [NSNull null]];
                    
                }
            }
                break;
                
            case BGDisplayInfoTypePhoneNum: {     //☎️
                if (_phoneNum) {
                    [tagInfos addObject: _phoneNum];
                }else {
                    [tagInfos addObject: [NSNull null]];
                    
                }
            }
                break;
                
            case BGDisplayInfoTypeShopHours: {    //营业时间
                if (_shopHours) {
                    [tagInfos addObject: _shopHours];
                }else {
                    [tagInfos addObject: [NSNull null]];
                    
                }
            }
                break;
                
            case BGDisplayInfoTypeBrand: {    //品牌
                if (_brand) {
                    [tagInfos addObject: _brand];
                }else {
                    [tagInfos addObject: [NSNull null]];
                    
                }
            }
                break;
                
            case BGDisplayInfoTypeCurrency: {    //币种
                if (_currency) {
                    [tagInfos addObject: _currency];
                }else {
                    [tagInfos addObject: [NSNull null]];
                    
                }
            }
                break;
                
            case BGDisplayInfoTypePrice: {    //价格
                if (_price) {
                    [tagInfos addObject: _price];
                }else {
                    [tagInfos addObject: [NSNull null]];
                }
            }
                break;
        }
    
    }
    return [NSArray arrayWithArray: tagInfos];
}

@end
