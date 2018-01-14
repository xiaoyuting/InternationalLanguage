//
//  XSMiOSAuthorization.m
//  国际化和手机权限
//
//  Created by 雨停 on 2018/1/14.
//  Copyright © 2018年 yuting. All rights reserved.
//

#import "XSMiOSAuthorization.h"
#import "SettingLocalizableUtil.h"

//使用相册时倒入该文件
#import <Photos/Photos.h>

//定位  导入CoreLocation.frame
#import <CoreLocation/CoreLocation.h>

//本地通知 导入UserNotifications.frame
#import <UserNotifications/UserNotifications.h>

//联网--1
#import "AFNetworkReachabilityManager.h"
//联网--2
/*下载 Reachability
 (1)导入 Reachability.h 和 Reachability.m
 (2)导入 SystemConfiguration.framework*/
#import "Reachability.h"

//通讯录
#import <ContactsUI/ContactsUI.h>

//日历 导入EventKit.frame
#import <EventKit/EventKit.h>

//蓝牙 导入CoreBluetooth.frame
#import <CoreBluetooth/CoreBluetooth.h>

//语音识别 导入Speech.frame
#import <Speech/Speech.h>

//健康 导入HealthKit.frame
#import <HealthKit/HealthKit.h>
#import <UIKit/UIDevice.h>

#define XSMDeviceVersion [[[UIDevice currentDevice] systemVersion] doubleValue]




@interface XSMiOSAuthorization ()
<CLLocationManagerDelegate,
CLLocationManagerDelegate,
UNUserNotificationCenterDelegate,
CBPeripheralDelegate,
UIAlertViewDelegate>

//CBCentralManagerDelegate
@end

//声明一个全局的静态变量 该变量存储在静态区域 生命周期为从程序开始到程序结束
static CLLocationManager  * _locationManager;
static CBCentralManager * _centralManager;

@implementation XSMiOSAuthorization

//在initialize方法里面初始化变量
+(void)initialize{
    _locationManager = [[CLLocationManager alloc] init];
    
//    _centralManager = [[CBCentralManager alloc] init];
}


//常用的iOS开发19项权限
/*
 XXXXNotDetermined,     用户尚未受权
 XXXXRestricted,        此应用程序无权访问照片数据。用户无法更改此应用程序的状态，可能是由于活动限制，例如父级控件就位。
 XXXXDenied,            用户已明确拒绝此应用访问照片数据。
 XXXXAuthorized         用户已授权此应用访问照片数据。
 */

#pragma mark -- 相机权限
+(void)judgeCameraAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        //必须写这个
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    //用户接受
                    if (success) {
                        success();
                    }
                }else{
                    //用户拒绝
                    [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"Camera" withDefault:@"Camera"] isName:YES];
                    if (fail) {
                        fail();
                    }
                }
            });
        }];
    }else if (status == AVAuthorizationStatusAuthorized) {
        if (success) {
            success();
        }
    }else{
        if (fail) {
            fail();
        }
        [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"Camera" withDefault:@"Camera"] isName:YES];
    }
}



#pragma mark -- 相册权限
//相册访问权限判断，iPhone 7 的InfoPlist文件也要加入相应键值
+(void)judgePHAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    //首次安装APP，用户还未授权 系统会请求用户授权
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    if (success) {
                        success();
                    }
                }else{
                    //点击不允许 给用户提示框
                    if (fail) {
                        fail();
                    }
                    [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"Album" withDefault:@"photo"] isName:YES];
                }
            });
        }];
    }else if (status == PHAuthorizationStatusAuthorized){
        if (success) {
            success();
        }
    }else{
        if (fail) {
            fail();
        }
        [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"Album" withDefault:@"photo"] isName:YES];
    }
}

#pragma mark -- 麦克风权限 （录音等）
+(void)judgeMicrophoneAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusNotDetermined) {
        //询问用户是否给予授权
        [[AVAudioSession sharedInstance]requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    if (success) {
                        success();
                    }
                }else{
                    if (fail) {
                        fail();
                    }
                    [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"microphone" withDefault:@"microphone"] isName:YES];
                }
            });
        }];
    }else if(status == AVAuthorizationStatusAuthorized){
        if (success) {
            success();
        }
    }else{
        if (fail) {
            fail();
        }
        [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"microphone" withDefault:@"microphone"] isName:YES];
    }
}


#pragma mark -- 定位权限
/*
 kCLAuthorizationStatusNotDetermined                  //用户尚未该应用程序作选择
 kCLAuthorizationStatusRestricted                     //应用程序定位权限限制
 kCLAuthorizationStatusAuthorizedAlways               //直允许获取定位
 kCLAuthorizationStatusAuthorizedWhenInUse            //使用允许获取定位
 kCLAuthorizationStatusAuthorized                     //已废弃相于直允许获取定位
 kCLAuthorizationStatusDenied                         //拒绝获取定位
 */
+(void)judgeLocationAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail {
    //先判断定位服务是否可用
    BOOL locationEnable = [CLLocationManager locationServicesEnabled];
    int status = [CLLocationManager authorizationStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!locationEnable || (status < 3 && status > 0)) {
            if (fail) {
                fail();
            }
            [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"positioning service" withDefault:@"positioning service"] isName:YES];
        }else if(status == 0){
            //获取授权认证
            //[_locationManager requestAlwaysAuthorization]; //一直开启定位
            [_locationManager requestWhenInUseAuthorization]; //使用时开启定位

        }else{
         if (success) {
                success();
            }
        }
    });
}

#pragma mark -- 推送通知权限
/*
ios8 之后使用本地通知需要导入框架 UserNotifications.Framework
 UNAuthorizationOptionBadge    //允许更新app上的通知数字
 UNAuthorizationOptionSound    //允许通知声音
 UNAuthorizationOptionAlert    //允许通知弹出警告,
 UNAuthorizationOptionCarPlay  //允许车载设备接收通知
 */
+(void)judgeNotificationStatusWithSuccess:(void(^)())success fail:(void(^)())fail {
    [[UNUserNotificationCenter currentNotificationCenter]requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if (success) {
                    success();
                }
            }else{
                if (fail) {
                    fail();
                }
                [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"You disabled access, please go to Settings->Notifications  to set up access" withDefault:@"You have set up not allowing to send notifications. Please turn to stings->notifications and allow our app to receive notification."] isName:NO];
            }
        });
    }];
}

#pragma mark -- 联网权限
/*-------------------------利用AFNetworking 判断--------------------------*/
+(void)judge_AFNetworking_NetworkConnectionStatusWithSuccess:(void(^)())success fail:(void(^)())fail{
    AFNetworkReachabilityManager *networkJudge = [AFNetworkReachabilityManager sharedManager];
    [networkJudge startMonitoring];
    [networkJudge setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status<=0){
            if (fail) {
                fail();
            }
            [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"DK_dialog_title_net_error" withDefault:@"No network connection is detected, please check and retry later"]  isName:NO];
        }else {
            if (success) {
                success();
            }
        }
    }];    
}

/*-------------------------利用Reachability 判断--------------------------
+(BOOL)judgeNetworkConnectionStatus_Reachability{
    __block BOOL networkConnection = nil;
    Reachability * reachability = [[Reachability alloc]init];
    NetworkStatus  status = [reachability currentReachabilityStatus];
    if (status != NotReachable) {
        networkConnection = YES;
    }else{
        networkConnection = NO;
    }
    return networkConnection;
}
*/

#pragma mark -- 通讯录权限
+(void)judgeContactStoreAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail{
    CNContactStore * contactStore = [[CNContactStore alloc]init];
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] ;
    if (status== CNAuthorizationStatusNotDetermined) {
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
             dispatch_async(dispatch_get_main_queue(), ^{
            if (error) return;
            if (granted) {
                if (success) {
                    success();
                }
            }else{
                if (fail) {
                    fail();
                }
                [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"Contacts" withDefault:@"Contacts"] isName:YES];
            }
             });
        }];
    }else  if (status== CNAuthorizationStatusAuthorized){
        if (success) {
            success();
        }
    }else{
        if (fail) {
            fail();
        }
        [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"Contacts" withDefault:@"Contacts"] isName:YES];
    }
}

#pragma mark -- 日历权限
+(void)judgeCalenderAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail{
    EKEventStore * xsmStore = [[EKEventStore alloc] init];
    [xsmStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if (success) {
                    success();
                }
            }else{
                if (fail) {
                    fail();
                }
                [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"Calendar" withDefault:@"Calendar"] isName:YES];
            }
        });
    }];
}


#pragma mark -- 备忘录权限
+(void)judgeReminderAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail{
    EKEventStore * xsmStore = [[EKEventStore alloc] init];
    [xsmStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if (success) {
                    success();
                }
            }else{
                if (fail) {
                    fail();
                }
                [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"Memo" withDefault:@"memorandum"] isName:YES];
            }
        });
   }];
}

#pragma mark -- 语音识别
+(void)judgeSFSpeechRecognizerAuthorizationStatusWithSuccess:(void(^)())success fail:(void(^)())fail{
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                if (success) {
                    success();
                }
            }else{
                if (fail) {
                    fail();
                }
                [self createAlertWithMessage:[SettingLocalizableUtil localizedStringForKey:@"Speech Recognition" withDefault:@" Speech Recognition"] isName:YES];
            }
        });
    }];
}

//+(BOOL)judgeSFSpeechRecognizerAuthorizationStatus{
//    //创建一个全局队列
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//    //创建一个信号量（值为0）
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    __block BOOL isAuthorization = nil;
//    dispatch_async(queue, ^{
//        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
//            if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
//                isAuthorization = YES;
//            }else{
//                isAuthorization = NO;
//            }
//            //信号量加1
//            dispatch_semaphore_signal(semaphore);
//        }];
//    });
//    //信号量减1，如果>0，则向下执行，否则等待
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    return isAuthorization;
//}



/*
#pragma mark -- 蓝牙权限
+(void)judgeBluetoothAuthoribzationStatusWithSuccess:(void(^)())success fail:(void(^)())fail{
    if(_centralManager.state == CBManagerStatePoweredOn)
    {
        if (success) {
            success();
        }
    }else{
        if (fail) {
            fail();
        }
        [self createAlertWithMessage:@"您设置了不允许访问蓝牙，请到设置->隐私->蓝牙里设置打开程序的访问权限" isName:YES];
    }
}
*/

#pragma mark -- 健康分享
#pragma mark -- 健康更新
/*

+(void)judgeHeathAuthorizationStatusWithSuccess:(void(^)())Success fail:(void(^)(NSError * ))Fail{
    if (XSMDeviceVersion >= 8.0 && [HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        HKHealthStore * xsmStore = [HKHealthStore new];
        [xsmStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    
                    if (Success) {
                        Success();
                    }
                }
                if (error) {
                    if (Fail) {
                        Fail(error);
                        [self createAlertWithMessage:@"您设置了不允许访问健康，请到设置->隐私->健康里设置打开程序的访问权限" isName:YES];
                    }
                }
            });
        }];

    }else{
        [self createAlertWithMessage:@"设备不支持健康模块" isName:YES];
    }
}
//设置读取数据的权限和写入数据的权限
//设置写入权限
+ (NSSet *)dataTypesToWrite {
    //行走步数
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //行走距离
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    return [NSSet setWithObjects:stepType,distanceType, nil];
}

//设置读取权限
+ (NSSet *)dataTypesToRead {
   // 以下为设置的权限类型：
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    return [NSSet setWithObjects:stepType,distanceType, nil];
}
*/


#pragma mark -- 智能家居

#pragma mark -- 音乐权限

#pragma mark -- 音乐视频权限

#pragma mark -- 运动传感器权限

#pragma mark -- Siri权限

#pragma mark -- 电视提供商权限


+(void)createAlertWithMessage:(NSString * )message isName:(BOOL)isName{
    NSString * authName = [NSString stringWithFormat:[SettingLocalizableUtil localizedStringForKey:@"model" withDefault:@"Go to the Settings -> Privacy -> %@ option to allow App to access your %@"],message,message];
    NSString * messages  = isName == YES?authName:message;
    NSString * GO = isName == YES?@"GO":nil;
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[SettingLocalizableUtil localizedStringForKey:@"XM_.FriendlyReminder_lu" withDefault:@"Friendly Reminder"] message:messages delegate:self cancelButtonTitle:@"OK" otherButtonTitles:GO , nil];
    [alert show];
}
#pragma mark -- UIAlertView协议方法
+(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self jumpPrivacySetting];
    }
}
//跳转到隐私设置界面
+ (void)jumpPrivacySetting{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


@end
