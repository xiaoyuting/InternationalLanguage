//
//  Tool.h
//  国际化和手机权限
//
//  Created by 雨停 on 2018/1/14.
//  Copyright © 2018年 yuting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tool : NSObject
/*获取手机系统的语言设置*/
+ (void)setLangueage;
/*获取本地内容设置*/
+ (NSString *)LangueageKey:(NSString *)key;
/*获取bundel里面的国际化文件*/
@end
