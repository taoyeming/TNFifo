//
//  TNFIFOAppDelegate.h
//  TNFifo
//
//  Created by 11702701 on 01/07/2022.
//  Copyright (c) 2022 11702701. All rights reserved.
//

@import UIKit;

@interface TNFIFOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;

@end
