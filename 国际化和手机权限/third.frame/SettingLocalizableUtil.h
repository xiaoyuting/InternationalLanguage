//
//  SettingLocalizableUtil.h
//  国际化和手机权限
//
//  Created by 雨停 on 2018/1/14.
//  Copyright © 2018年 yuting. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface SettingLocalizableUtil : NSObject

+ (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString;

@end
