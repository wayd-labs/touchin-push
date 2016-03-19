//
//  TIRateMeCellTableViewCell.m
//  touchin-rateme
//
//  Created by Толя Ларин on 09/01/15.
//
//
#import "TIAllowPushCell.h"
#import "TIAnalytics.h"

@implementation TIAllowPushCell

- (void) makeRoundCorneredFrame: (CALayer*) layer {
    layer.cornerRadius = 5;
    layer.borderWidth = 1;
    layer.borderColor = self.appearance.accentColor.CGColor;
}

- (void) setUpButton: (UIButton*) button {
    [self makeRoundCorneredFrame:button.layer];
//    [button setTintColor:[UIColor whiteColor]];
    [button setTitleColor:self.appearance.accentColor forState:UIControlStateNormal];
    [button setTitleColor:self.appearance.backgroundColor forState:UIControlStateHighlighted];
    [button setTitleColor:self.appearance.backgroundColor forState:UIControlStateSelected];
    
    //for background change
    [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) buttonTouchDown:(id)sender
{
    UIButton* button = sender;
    [button setBackgroundColor:self.appearance.accentColor];
}

- (void) buttonTouchUp:(id)sender
{
    UIButton* button = sender;
    [button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
}

- (void)awakeFromNib {
    [self.yesButton addTarget:self action:@selector(yesButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self.noButton addTarget:self action:@selector(noButtonTap) forControlEvents:UIControlEventTouchUpInside];

    //todo move colors to properties sometime
    [self setBackgroundColor:self.appearance.backgroundColor];
    self.questionLabel.textColor = self.appearance.accentColor;
    
    [self setUpButton:self.yesButton];
    [self setUpButton:self.noButton];
    
    NSString *bundlePath = [[NSBundle bundleForClass:[TIAllowPushCell class]] pathForResource:@"TIPush" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    [self.yesButton setTitle:[bundle localizedStringForKey:@"AllowPush-Yes" value:@"" table:nil] forState:UIControlStateNormal];
    [self.noButton setTitle:[bundle localizedStringForKey:@"AllowPush-No" value:@"" table:nil] forState:UIControlStateNormal];
    self.questionLabel.text = [bundle localizedStringForKey:@"AllowPush-Question" value:@"" table:nil];

    [TIAnalytics.shared trackEvent:@"ALLOWPUSH-CELL_SHOWN"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) yesButtonTap {
    [TIAnalytics.shared trackEvent:@"ALLOWPUSH-CELL_YES"];
    [self.delegate yesTap];
}

- (void) noButtonTap {
    [TIAnalytics.shared trackEvent:@"ALLOWPUSH-CELL_NO"];
    [self.delegate noTap];
}

@end
