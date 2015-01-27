//
//  TINotifications.h
//  Pods
//
//  Created by Толя Ларин on 26/01/15.
//
//

#import <Foundation/Foundation.h>

@interface TIPushNotifications : NSObject

+ (instancetype)sharedInstance;
- (void) registerPushNotification:(void (^)(bool success))result;
- (BOOL) isRegistered;

@end
