//
//  TINotifications.h
//  Pods
//
//  Created by Толя Ларин on 26/01/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TIPushNotifications : NSObject

+ (instancetype)sharedInstance;
- (void) registerPushNotification:(void (^)(bool success))result;
- (BOOL) isRegistered;

//sendTokenToServer(token, locale, timezone
@property (nonatomic, copy) void (^sendTokenToServer)(NSString*, NSString*, NSString*);

//do have we soft approval for notifications (our allow push screen) @(YES) @(NO) or nil (not asked yet)
@property NSNumber* haveOurApproval;
//do have we hard approval for notifications (systen alert) @(YES) @(NO) or nil (not asked yet)
- (NSNumber*) haveSystemApproval;

//you should call this in didFinishLaunchingWithOptions
- (void) initialize;

//debug method clears all data stored in NSUserDefaults
- (void) clear;

- (void) showRemoteNotificationPermissionWithTitle:(NSString *)title
                                           message:(NSString *)message
                                   denyButtonTitle:(NSString *)denyButtonTitle
                                  allowButtonTitle:(NSString *)allowButtonTitle
                                 completionHandler:(void (^)(BOOL success)) completionHandler;
@end
