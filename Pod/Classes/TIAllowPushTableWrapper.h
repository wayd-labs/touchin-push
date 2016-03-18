//
//  TITableDataSourceWrapper.h
//  touchin-rateme
//
//  Created by Tony Larin on 09/01/15.
//
//

#import <Foundation/Foundation.h>
#import "touchin_trivia/TIEmailFeedback.h"
#import "touchin_trivia/TIAppearance.h"
#import "touchin_trivia/TITableWrapper.h"

@protocol TIAllowPushDelegate<TITableWrapperDelegate>
-(void) yesTap;
-(void) noTap;
@end

@interface TIAllowPushTableWrapper : TITableWrapper <UITableViewDataSource, UITableViewDelegate, TIAllowPushDelegate>

@property TIEmailFeedback* feedbackObject;
@property NSURL* appstoreURL;

@end
