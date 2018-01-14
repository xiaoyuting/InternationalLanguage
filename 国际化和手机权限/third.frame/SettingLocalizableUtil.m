//
//  SettingLocalizableUtil.m
//  国际化和手机权限
//
//  Created by 雨停 on 2018/1/14.
//  Copyright © 2018年 yuting. All rights reserved.
//


#import "SettingLocalizableUtil.h"

@implementation SettingLocalizableUtil

+ (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath  = [[NSBundle bundleForClass:[self class]] pathForResource:@"Language" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *language;
        if ([NSLocale preferredLanguages].count > 0) {
            language = [NSLocale preferredLanguages][0];
            NSDictionary *components = [NSLocale componentsFromLocaleIdentifier:language];
            NSString *languageScriptStr;
            NSString *languageDesignator = components[NSLocaleLanguageCode];
            NSString *scriptCode = components[NSLocaleScriptCode];
            if (scriptCode != nil && scriptCode.length > 0) {
                languageScriptStr = [NSString stringWithFormat:@"%@-%@", languageDesignator, scriptCode];
            }else{
                languageScriptStr = languageDesignator;
            }
            language = languageScriptStr;
        }else{
            language = @"en";
        }
        
        if (![[bundle localizations] containsObject:language])
        {
            language = [language componentsSeparatedByString:@"-"][0];
        }
        if ([[bundle localizations] containsObject:language])
        {
            bundlePath = [bundle pathForResource:language ofType:@"lproj"];
        }
        
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}




@end
