//
//  XSMiOSAuthorization.h
//  国际化和手机权限
//
//  Created by 雨停 on 2018/1/14.
//  Copyright © 2018年 yuting. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface XSMiOSAuthorization : NSObject


/**
 相册权限
 */
+(void)judgePHAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 相机权限
 */
+(void)judgeCameraAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 麦克风权限
 */
+(void)judgeMicrophoneAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 定位权限
 */
+(void)judgeLocationAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 本地通知权限
 */
+(void)judgeNotificationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 网络权限 -- AFNetworking
 */
+(void)judge_AFNetworking_NetworkConnectionStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 网络权限 -- Reachability
 */
//+(void)judge_Reachability_NetworkConnectionStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 通讯录权限
 */
+(void)judgeContactStoreAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;


/**
 日历权限
 */
+(void)judgeCalenderAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 备忘录权限
 */
+(void)judgeReminderAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 语音识别权限
 */
+(void)judgeSFSpeechRecognizerAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;

/**
 健康权限
 */
//+(void)judgeHeathAuthorizationStatusWithSuccess:(void(^)())Success fail:(void(^)(NSError * ))Fail;

/**
 蓝牙权限
 */
//+(void)judgeBluetoothAuthoribzationStatusWithSuccess:(void(^)())success fail:(void(^)())fail;







@end
