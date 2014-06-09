//
//  AppDelegate.m
//  CloudKit
//
//  Created by sonson on 2014/06/05.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
            

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	[application registerForRemoteNotifications];
	return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"Registered for Push notifications with token: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Push subscription failed");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)info {
	NSLog(@"Push received");
}

@end
