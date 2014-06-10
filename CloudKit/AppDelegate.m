//
//  AppDelegate.m
//  CloudKit
//
//  Created by sonson on 2014/06/05.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "AppDelegate.h"

#import <CloudKit/CloudKit.h>
#import "helper.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[application registerForRemoteNotifications];
	return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	DNSLog(@"Registered for Push notifications with token: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	DNSLog(@"Push subscription failed");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)info {
	DNSLog(@"Push received");
	CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:info];
	NSString *alertBody = cloudKitNotification.alertBody;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Subscription", nil)
														message:alertBody
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alertView show];
}

@end
