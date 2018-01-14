//
//  Tool.m
//  国际化和手机权限
//
//  Created by 雨停 on 2018/1/14.
//  Copyright © 2018年 yuting. All rights reserved.
//

#import "Tool.h"
static NSString *appLanguage = @"appLanguage";
@implementation Tool
+ (void)setLangueage {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:appLanguage]) {
        NSArray  *languages = [NSLocale preferredLanguages];
        NSString *language = [languages objectAtIndex:0];
        if ([language hasPrefix:@"zh-Hans"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:appLanguage];
        } else if ([language hasPrefix:@"zh-TW"] || [language hasPrefix:@"zh-HK"] || [language hasPrefix:@"zh-Hant"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hant" forKey:appLanguage];
        } else if ([language hasPrefix:@"en"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:appLanguage];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:appLanguage];
        }
    }
}

+ (NSString *)LangueageKey:(NSString *)key{
    return  [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:nil table:@"test"];
}

+ (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath  = [[NSBundle bundleForClass:[self class]] pathForResource:@"XYB" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
//        NSString *language;
//        if ([NSLocale preferredLanguages].count > 0) {
//            language = [NSLocale preferredLanguages][0];
//            NSDictionary *components = [NSLocale componentsFromLocaleIdentifier:language];
//            NSString *languageScriptStr;
//            NSString *languageDesignator = components[NSLocaleLanguageCode];
//            NSString *scriptCode = components[NSLocaleScriptCode];
//            if (scriptCode != nil && scriptCode.length > 0) {
//                languageScriptStr = [NSString stringWithFormat:@"%@-%@", languageDesignator, scriptCode];
//            }else{
//                languageScriptStr = languageDesignator;
//            }
//            language = languageScriptStr;
//        }else{
//            language = @"en";
//        }
//
//        if (![[bundle localizations] containsObject:language])
//        {
//            language = [language componentsSeparatedByString:@"-"][0];
//        }
//        if ([[bundle localizations] containsObject:language])
//        {
            bundlePath = [bundle pathForResource:[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"] ofType:@"lproj"];
     //   }
        
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:@"GMLocalized"];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:@"GMLocalized"];
}

@end
