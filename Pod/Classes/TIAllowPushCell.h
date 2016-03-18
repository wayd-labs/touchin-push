//
//  TIRateMeCellTableViewCell.h
//  touchin-rateme
//
//  Created by Толя Ларин on 09/01/15.
//
//

#import <UIKit/UIKit.h>
#import "TIAllowPushTableWrapper.h"
#import "touchin_trivia/TIAppearance.h"

@interface TIAllowPushCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@property (strong, nonatomic) TIAppearance *appearance;
@property (weak) id delegate;

@end
