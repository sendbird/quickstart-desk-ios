//
//  AppDelegate.m
//  QuickStart
//
//  Created by SendBird on 3/19/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "AppDelegate.h"
#import "UIViewController+Utils.h"
#import "InboxViewController.h"
#import "ChattingViewController.h"
#import "SBDSKSettingsViewController.h"
#import "SBDSKOpenSourceLicenseViewController.h"
#import "SBDSKWebViewController.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registerForRemoteNotification];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (audioSession != nil) {
        NSError *error = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        if (error != nil) {
            NSLog(@"Set Audio Session error: %@", error);
        }
    }
    
    [SBDMain initWithApplicationId:@"52292344-3DA9-47ED-8BB1-587BB0D36F4D"]; 
    
    [SBDSKMain initializeDesk];
    NSLog(@"Version: %@", [SBDSKMain getSdkVersion]);
    return YES;
}

- (void)registerForRemoteNotification {
    float osVersion = [UIDevice currentDevice].systemVersion.floatValue;
    if (osVersion >= 10.0) {
#if !(TARGET_OS_SIMULATOR) && (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0)
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"Tries to register push token, granted: %d, error: %@", granted, error);
            if (granted) {
                [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                    });
                }];
            }
        }];
        return;
#else
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNAuthorizationOptions options = UNAuthorizationOptionAlert;
        [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
#endif
    } else {
#if !(TARGET_OS_SIMULATOR)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
#pragma clang diagnostic pop
#endif
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Device token: %@", deviceToken.description);
    [SBDMain registerDevicePushToken:deviceToken unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
        if (error == nil) {
            if (status == SBDPushTokenRegistrationStatusPending) {
                NSLog(@"Push registration is pending.");
            }
            else {
                NSLog(@"APNS Token is registered.");
            }
        }
        else {
            NSLog(@"APNS registration failed with error: %@", error);
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    // iOS 10 and later for local notification.
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSString *channelUrl = nil;

    channelUrl = response.notification.request.content.userInfo[@"sendbird"][@"channel"][@"channel_url"];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbirddesk_user_id"];
    NSString *userNickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbirddesk_user_nickname"];
    
    if (channelUrl != nil) {
        UIViewController *vc = [UIViewController currentViewController];
        
        if ([vc isKindOfClass:[InboxViewController class]]) {
            InboxViewController *currentVc = (InboxViewController *)vc;
            [currentVc openChatWithChannelUrl:channelUrl];
        }
        else if ([vc isKindOfClass:[ChattingViewController class]]) {
            ChattingViewController *currentVc = (ChattingViewController *)vc;
            if (currentVc.ticket != nil && currentVc.ticket.channel != nil && [currentVc.ticket.channel.channelUrl isEqualToString:channelUrl]) {
                // Do nothing.
            }
            else {
                [currentVc openChatWithChannelUrl:channelUrl];
            }
        }
        else if ([vc isKindOfClass:[SBDSKSettingsViewController class]]) {
            SBDSKSettingsViewController *currentVc = (SBDSKSettingsViewController *)vc;
            [currentVc openChatWithChannelUrl:channelUrl];
        }
        else if ([vc isKindOfClass:[SBDSKOpenSourceLicenseViewController class]]) {
            SBDSKOpenSourceLicenseViewController *currentVc = (SBDSKOpenSourceLicenseViewController *)vc;
            [currentVc openChatWithChannelUrl:channelUrl];
        }
        else if ([vc isKindOfClass:[SBDSKWebViewController class]]) {
            SBDSKWebViewController *currentVc = (SBDSKWebViewController *)vc;
            [currentVc openChatWithChannelUrl:channelUrl];
        }
        else if ([vc isKindOfClass:[ViewController class]]) {
            if (userId != nil && userId.length > 0 && userNickname != nil && userNickname.length > 0) {
                ViewController *currentVc = (ViewController *)vc;
                [currentVc openChatWithChannelUrl:channelUrl];
            }
        }
        completionHandler();
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    if (userInfo[@"sendbird"] != nil) {
//        NSDictionary *sendBirdPayload = userInfo[@"sendbird"];
//        NSString *channel = sendBirdPayload[@"channel"][@"channel_url"];
//        NSString *channelType = sendBirdPayload[@"channel_type"];
//        if ([channelType isEqualToString:@"group_messaging"]) {
//            self.receivedPushChannelUrl = channel;
//        }
//    }
    
    NSLog(@"[Sendbird] application: %@ didReceiveRemoteNotification: %@", application, userInfo);
}

@end
