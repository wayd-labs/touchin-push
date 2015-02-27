//
//  TINotifications.m
//  Pods
//
//  Created by Толя Ларин on 26/01/15.
//
//

#import "TIPushNotifications.h"
#import <UIKit/UIKit.h>
#import "objc/runtime.h"
#import <TITrivia.h>

@implementation TIPushNotifications

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

NSString* UD_OUR_APPROVAL = @"TIPushOurApproval";
NSString* UD_SYSTEM_APPROVAL = @"TIPushSystemApproval";
NSString* UD_ASKED_SYSTEM_APPROVAL = @"TIPushAskedSystemApproval";

- (instancetype) init {
    self = [super init];
    [self swizzleAppDelegateMethods];
    return self;
}

- (void) initialize {
  [self reregisterOnStart];
  [TITrivia.sharedInstance initTrackActiveVC];
}

- (void) clear {
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_ASKED_SYSTEM_APPROVAL];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_OUR_APPROVAL];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_SYSTEM_APPROVAL];
}

//static IMP __original_didFinishLaunchingWithOptions;

/* Device tokens can change. Your app needs to reregister every time it is launched—in iOS by calling the registerForRemoteNotificationTypes:
 */
- (void) reregisterOnStart {
    if ([self isRegistered]) {
        [self registerPushNotification:nil];
    }
}

void (^activeCallback)(BOOL success) = nil;

- (void) registerPushNotification:(void (^)(BOOL success))result {
  if (result) {
    activeCallback = result;
  }
  UIApplication *application = [UIApplication sharedApplication];
  if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
      UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge                                                                                            |UIRemoteNotificationTypeSound                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
      [application registerUserNotificationSettings:settings];
  } else {
      [application registerForRemoteNotificationTypes:
       (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
  }
  [self setAskedSystemApproval:@(YES)];
}

- (BOOL) isRegistered {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        return [application isRegisteredForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = [application enabledRemoteNotificationTypes];
        return types != UIRemoteNotificationTypeNone;
    }
}

//do have we soft approval for notifications (our allow push screen) @(YES) @(NO) or nil (not asked yet)
- (NSNumber*) haveOurApproval {
    return [[NSUserDefaults standardUserDefaults] objectForKey:UD_OUR_APPROVAL];
}

- (void) setHaveOurApproval:(NSNumber *)haveOurApproval {
    [[NSUserDefaults standardUserDefaults] setObject:haveOurApproval forKey:UD_OUR_APPROVAL];
}

//do have we hard approval for notifications (systen alert) @(YES) @(NO) or nil (not asked yet)
- (NSNumber*) haveSystemApproval {
    NSNumber* asked = [[NSUserDefaults standardUserDefaults] objectForKey:UD_ASKED_SYSTEM_APPROVAL];
    
    if (!asked.boolValue) {
        return nil;
    } else {
        if ([self isRegistered]) {
            return @(YES);
        } else {
            return @(NO);
        }
    }
}

- (NSNumber*) askedSystemAppproval {
    return [[NSUserDefaults standardUserDefaults] objectForKey:UD_ASKED_SYSTEM_APPROVAL];
}

- (void) setAskedSystemApproval:(BOOL) asked {
    [[NSUserDefaults standardUserDefaults] setObject:@(asked) forKey:UD_ASKED_SYSTEM_APPROVAL];
}

#pragma mark ApplicationDelegate methods
- (void) swizzleAppDelegateMethods {

#pragma warning USE this
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
    
    BOOL result = false;
    Class appDelegateClass = [[UIApplication sharedApplication].delegate class];
    SEL sel;
    Method m;

//    sel = @selector(application:didFinishLaunchingWithOptions:);
//    m = class_getInstanceMethod(appDelegateClass, sel);
//    result = class_addMethod(appDelegateClass, sel, (IMP) didFinishLaunchingWithOptions, method_getTypeEncoding(m));
//    __original_didFinishLaunchingWithOptions = method_setImplementation(m, (IMP) didFinishLaunchingWithOptions);
    
    sel = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
    m = class_getInstanceMethod(appDelegateClass, sel);
    result = class_addMethod(appDelegateClass, @selector(application:didFailToRegisterForRemoteNotificationsWithError:), (IMP) didFailToRegisterForRemoteNotificationsWithError, method_getTypeEncoding(m));

    sel = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
    m = class_getInstanceMethod(appDelegateClass, sel);
    result = class_addMethod(appDelegateClass, sel, (IMP) didRegisterForRemoteNotifictationsWithDeviceToken, method_getTypeEncoding(m));

  sel = @selector(application:didRegisterUserNotificationSettings:);
  m = class_getInstanceMethod(appDelegateClass, sel);
  result = class_addMethod(appDelegateClass, sel, (IMP) didRegisterUserNotificationSettings, method_getTypeEncoding(m));
}

//void didFinishLaunchingWithOptions(id self, SEL _cmd, UIApplication* app, NSDictionary* options) {
//    NSLog(@"hooked didFinishLaunchingWithOptions %@", options);
//    ((void(*)(id,SEL,UIApplication*,NSDictionary*))__original_didFinishLaunchingWithOptions)(self, _cmd, app, options);
//    [TIPushNotifications.sharedInstance reregisterOnStart];
//}

void didRegisterUserNotificationSettings(id self, SEL _cmd, UIApplication* app, UIUserNotificationSettings *notificationSettings) {
  bool alertAllowed = notificationSettings.types & UIUserNotificationTypeAlert;
  [[NSUserDefaults standardUserDefaults] setObject:@(alertAllowed) forKey:UD_SYSTEM_APPROVAL];
  if (alertAllowed) {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  }
  if (activeCallback) {
    activeCallback(alertAllowed); //this one is freaking me out
  }
}

void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication* app, NSError* error) {
  NSLog(@"hooked didFailToRegisterForRemoteNotificationsWithError %@", error);
  [TITrivia.sharedInstance showSimpleMessageWithTitle:@"Notification Registration Failed" message:error.localizedDescription];
//  if (activeCallback) {
//    activeCallback(NO); //kind a tricky part here, we still have the alert on simulator
//  }
}

void didRegisterForRemoteNotifictationsWithDeviceToken(id self, SEL _cmd, UIApplication* app, NSData* token) {
    NSLog(@"hooked didRegisterForRemoteNotifictationsWithDeviceToken %@", token);
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:UD_SYSTEM_APPROVAL];

    NSString *deviceToken = [[token description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSString *locale = [[NSLocale currentLocale]localeIdentifier];
    NSString *timeZone = [NSTimeZone localTimeZone].name;
    
    TIPushNotifications.sharedInstance.sendTokenToServer(deviceToken, locale, timeZone);
  
  if (activeCallback) {
    activeCallback(YES);
  }
}

- (void) showRemoteNotificationPermissionWithTitle:(NSString *)title
                                           message:(NSString *)message
                                   denyButtonTitle:(NSString *)denyButtonTitle
                                  allowButtonTitle:(NSString *)allowButtonTitle
                                 completionHandler:(void (^)(BOOL success)) completionHandler {
  if ([self haveSystemApproval] != nil) {
    if (completionHandler) {
      completionHandler([self haveSystemApproval]);
    }
    return;
  }
  
  [TITrivia.sharedInstance showYesNoAlertWithTitle:title message:message denyButtonTitle:denyButtonTitle allowButtonTitle:allowButtonTitle completion:^(BOOL allowTapped) {
    if (allowTapped) {
      [self registerPushNotification:^(bool success) {
        completionHandler(success);
      }];
    } else {
      if (completionHandler) {
        completionHandler(NO);
      }
    }
  }];
}
@end
