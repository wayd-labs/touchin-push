//
//  TIPushAppDelegateProxy.h
//  Pods
//
//  Created by Толя Ларин on 19/08/15.
//
//

#import <Foundation/Foundation.h>


@interface TIPushAppDelegateProxy : NSProxy<UIApplicationDelegate>

@property (nonatomic, strong, readonly) NSObject<UIApplicationDelegate> *object;

- (instancetype)initReplacingAppDelegate;

//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) token;
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

@end
