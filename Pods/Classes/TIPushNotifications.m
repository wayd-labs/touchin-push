//
//  TINotifications.m
//  Pods
//
//  Created by Толя Ларин on 26/01/15.
//
//

#import "TIPushNotifications.h"
#import <UIKit/UIKit.h>
#import "Aspects.h"
#import "objc/runtime.h"

@implementation TIPushNotifications

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

/* Device tokens can change. Your app needs to reregister every time it is launched—in iOS by calling the registerForRemoteNotificationTypes:
 But we don't wanna to show Push permission dialog on app launch, so we call this only if user if already give as permission
 new token will be sent to server if we did register for remote push notifications */
- (void) reregisterOnStart {
    if ([self isRegistered]) {
        [self registerPushNotification:nil];
    }
}

- (void) registerPushNotification:(void (^)(bool success))result {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge                                                                                            |UIRemoteNotificationTypeSound                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    [self swizzleAppDelegateMethods];
}

- (BOOL) isRegistered
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        return [application isRegisteredForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = [application enabledRemoteNotificationTypes];
        return types != UIRemoteNotificationTypeNone;
    }
}

#pragma mark ApplicationDelegate methods
- (void) swizzleAppDelegateMethods {
    BOOL result = false;
    Class appDelegateClass = [[UIApplication sharedApplication].delegate class];
    SEL sel;
    Method m;

    sel = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
    m = class_getInstanceMethod(appDelegateClass, sel);
    result = class_addMethod(appDelegateClass, @selector(application:didFailToRegisterForRemoteNotificationsWithError:), (IMP) didFailToRegisterForRemoteNotificationsWithError, method_getTypeEncoding(m));

    sel = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
    m = class_getInstanceMethod(appDelegateClass, sel);
    result = class_addMethod(appDelegateClass, sel, (IMP) didRegisterForRemoteNotifictationsWithDeviceToken, method_getTypeEncoding(m));
}

void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, NSError* error) {
    NSLog(@"hooked didFailToRegisterForRemoteNotificationsWithError %@", error);
}

void didRegisterForRemoteNotifictationsWithDeviceToken(id self, SEL _cmd, NSData* token) {
    NSLog(@"hooked didRegisterForRemoteNotifictationsWithDeviceToken %@", token);
}
@end
