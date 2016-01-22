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
#import <TIAnalytics.h>
#import "TIPushAppDelegateProxy.h"

@interface TIPushNotifications()

@property (nonatomic) NSInteger presentingCounter;

@end

@implementation TIPushNotifications

NSString* UD_OUR_APPROVAL = @"TIPushOurApproval";
NSString* UD_SYSTEM_APPROVAL = @"TIPushSystemApproval";
NSString* UD_ASKED_SYSTEM_APPROVAL = @"TIPushAskedSystemApproval";

TIPushAppDelegateProxy* appdelegateProxy;

+ (instancetype)sharedInstance {
  static id sharedInstance = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}

- (instancetype) init {
  self = [super init];
  appdelegateProxy = [[TIPushAppDelegateProxy alloc] initReplacingAppDelegate];
  return self;
}

- (void) initialize {
  self.limitPerLaunch = 0;
  self.presentingCounter = 0;
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

- (void) callActiveCallback:(BOOL) success {
  if (activeCallback) {
    activeCallback(success);
  }
}

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
  
  if (self.limitPerLaunch == 0 || (self.limitPerLaunch > 0 && self.presentingCounter < self.limitPerLaunch)) {
    if (self.limitPerLaunch > 0) {
      self.presentingCounter++;
    }
    [TIAnalytics.shared trackEvent:@"ALLOWPUSH-ALERT_SHOWN"];
    [TITrivia.sharedInstance showYesNoAlertWithTitle:title message:message denyButtonTitle:denyButtonTitle allowButtonTitle:allowButtonTitle completion:^(BOOL allowTapped) {
      if (allowTapped) {
        [self registerPushNotification:^(bool success) {
          completionHandler(success);
        }];
        [TIAnalytics.shared trackEvent:@"ALLOWPUSH-ALERT_YES"];
      } else {
        if (completionHandler) {
          completionHandler(NO);
        }
        [TIAnalytics.shared trackEvent:@"ALLOWPUSH-ALERT_NO"];
      }
    }];
  } else {
      if (completionHandler) {
        completionHandler(NO);
      }
  }
}
@end
