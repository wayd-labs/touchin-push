#import "TIPushAppDelegateProxy.h"

#import "TITrivia.h"
#import "TIPushNotifications.h"
#import "TIAnalytics.h"

@implementation TIPushAppDelegateProxy

- (instancetype)initReplacingAppDelegate {
    _object = [UIApplication sharedApplication].delegate;
    NSLog(@"#tipush AppDelegate replaced with proxy");
    [UIApplication sharedApplication].delegate = self;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.object methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.object];
}

- (BOOL)respondsToSelector:(SEL)sel {
    //seems like I'm not getting something, it's really complicated method, should be simplier
    if (sel == @selector(application:didRegisterUserNotificationSettings:)
        || sel == @selector(application:didFailToRegisterForRemoteNotificationsWithError:)
        || sel == @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)
        || sel == @selector(application:didReceiveRemoteNotification:)
        || sel == @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:))
     {
        return @YES;
    }
    return [super respondsToSelector:sel];
}

//void didFinishLaunchingWithOptions(id self, SEL _cmd, UIApplication* app, NSDictionary* options) {
//    NSLog(@"hooked didFinishLaunchingWithOptions %@", options);
//    ((void(*)(id,SEL,UIApplication*,NSDictionary*))__original_didFinishLaunchingWithOptions)(self, _cmd, app, options);
//    [TIPushNotifications.sharedInstance reregisterOnStart];
//}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"#tipush hooked didRegisterUserNotificationSettings %@", notificationSettings);
    bool alertAllowed = notificationSettings.types & UIUserNotificationTypeAlert;
    [[NSUserDefaults standardUserDefaults] setObject:@(alertAllowed) forKey:UD_SYSTEM_APPROVAL];
    if (alertAllowed) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    [[TIPushNotifications sharedInstance] callActiveCallback:alertAllowed];
    
    [_object application:application didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"#tipush hooked didFailToRegisterForRemoteNotificationsWithError %@", error);
    [TITrivia.sharedInstance showSimpleMessageWithTitle:@"Notification Registration Failed" message:error.localizedDescription];
    //  if (activeCallback) {
    //    activeCallback(NO); //kind a tricky part here, we still have the alert on simulator
    //  }
    [_object application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) token {
    NSLog(@"#tipush hooked didRegisterForRemoteNotifictationsWithDeviceToken %@", token);
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:UD_SYSTEM_APPROVAL];
    [TIAnalytics.shared trackEvent:@"ALLOWPUSH-SYSTEM_YES"];
    
    NSString *deviceToken = [[token description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *locale = [TITrivia currentLanguageKey];
    NSString *timeZone = [NSTimeZone localTimeZone].name;
    
    TIPushNotifications.sharedInstance.sendTokenToServer(deviceToken, locale, timeZone);
    
    [[TIPushNotifications sharedInstance] callActiveCallback:@YES];
    
    [_object application:application didRegisterForRemoteNotificationsWithDeviceToken:token];
}

//- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    NSLog(@"#tipush hooked didReceiveRemoteNotification %@", userInfo);
//    [_object application:app didReceiveRemoteNotification:userInfo];
//}

- (id) recursiveValueForKey:(id)object key:(NSString*) key{
    if([object isKindOfClass:[NSDictionary class]]){
        if ([object objectForKey:key]) {
            return [object objectForKey:key];
        }
        for (NSString *k in [object allKeys]){
            id child = [object objectForKey:k];
            id val = [self recursiveValueForKey:child key:key];
            if (val) {
                return val;
            }
        }
    }
    return nil;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLog(@"#tipush hooked didReceiveRemoteNotification:fetchCompletionHandler %@", userInfo);
    
    NSString *type = [self recursiveValueForKey:userInfo key:@"type"];
    NSDictionary *prop = nil;
    if (type == nil) {
        NSLog(@"#tipush WARNING: key 'type' not found in userInfo %@", userInfo);
    } else {
        prop = @{@"type":type};
    }
    
    if (application.applicationState == UIApplicationStateInactive) {
        [TIAnalytics.shared trackEvent:@"PUSH_APP_OPEN" properties:prop];
    }
    else if (application.applicationState == UIApplicationStateActive) {
        [TIAnalytics.shared trackEvent:@"PUSH_INSIDE_APP" properties:prop];
    }
    [_object application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}


@end
