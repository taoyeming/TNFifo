//
//  TNFIFOViewController.m
//  TNFifo
//
//  Created by 11702701 on 01/07/2022.
//  Copyright (c) 2022 11702701. All rights reserved.
//

#import "TNFIFOViewController.h"
#import <TNFifo/TNFifoManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import <UserNotifications/UserNotifications.h>

@interface TNFIFOViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *location;

@end

@implementation TNFIFOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self auth];
    });
}

static NSString *_notificationRequestId = nil;
static NSString *_locationRequestId = nil;

- (void)auth {
    // 获取通知权限
    if (@available(iOS 10, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [TNFifoManager exec:^(NSString * _Nonnull uuid) {
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                [TNFifoManager completeWithUUID:uuid];
            }];
        }];
    } else {
        [TNFifoManager exec:^(NSString * _Nonnull uuid) {
            _notificationRequestId = uuid;
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        }];
    }
    
    // 获取idfa权限
    if (@available(iOS 14, *)) {
        // iOS获取idfa权限的系统实现是有一定问题的
        // idfa权限在一些特殊情况下会出现无法弹出的问题，例如（app刚刚启动、其他权限弹窗未消失、或者其他什么我不知道的情况），已知iOS14、iOS15一样
        // idfa权限申请的时候尽量延迟0.5秒之后申请，这样可以避免大部分问题
        
        // 问题复现方法，delay设置为0.0，使用模拟器，开启slow animations，idfa权限在其他权限申请之后申请
        [TNFifoManager exec:^(NSString * _Nonnull uuid) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                [TNFifoManager completeWithUUID:uuid];
            }];
        } queue:dispatch_get_main_queue() delay:0.5];
    }

    // 获取相册权限
    [TNFifoManager exec:^(NSString * _Nonnull uuid) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [TNFifoManager completeWithUUID:uuid];
        }];
    }];

    // 获取定位权限
    _location = [CLLocationManager new];
    _location.delegate = self;
    [TNFifoManager exec:^(NSString * _Nonnull uuid) {
        // 因为didChangeAuthorizationStatus会被调用多次
        //（例如第一次启动，用户允许定位，didChangeAuthorizationStatus会先回调一次未授权，后回调一次同意）
        // 所以使用一个bool值来标记，（如果使用RN开发，考虑一下多线程下是否要加锁，或者重复调用的问题）
        _locationRequestId = uuid;
        [_location requestAlwaysAuthorization];
    }];
    
    // 获取相机权限
    [TNFifoManager exec:^(NSString * _Nonnull uuid) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [TNFifoManager completeWithUUID:uuid];
        }];
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(_locationRequestId) {
        [TNFifoManager completeWithUUID:_locationRequestId];
        _locationRequestId = nil;
    }
}

#pragma mark - application

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if(_notificationRequestId) {
        [TNFifoManager completeWithUUID:_notificationRequestId];
        _notificationRequestId = nil;
    }
}

@end
