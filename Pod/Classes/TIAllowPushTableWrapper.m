//
//  TITableDataSourceWrapper.m
//  touchin-rateme
//
//  Created by Tony Larin on 09/01/15.
//
//

#import "TIAllowPushTableWrapper.h"
#import "TIAllowPushCell.h"
#import "TIPushNotifications.h"

@implementation TIAllowPushTableWrapper

- (UITableViewCell*) createServiceCell {
    NSString *bundlePath = [[NSBundle bundleForClass:[TIAllowPushTableWrapper class]] pathForResource:@"TIPush" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSArray *topLevelObjects = [bundle loadNibNamed:@"TIAllowPushCell" owner:self options:nil];
    TIAllowPushCell* cell = [topLevelObjects objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.appearance = self.appearance? self.appearance : [TIAppearance apperanceWithBackgroundColor:[UIColor redColor] accentColor:[UIColor whiteColor]];
    [cell awakeFromNib];
    cell.delegate = self;
    
    return cell;
}

#pragma mark TIAllowPushDelegate
- (void) yesTap {
    TIPushNotifications.sharedInstance.haveOurApproval = @(YES);
//    [TIPushNotifications.sharedInstance registerPushNotification:^void (BOOL success) {
//        [self finished];
//    }];
}

- (void) noTap  {
    TIPushNotifications.sharedInstance.haveOurApproval = @(NO);
    [self finished];
}
@end
