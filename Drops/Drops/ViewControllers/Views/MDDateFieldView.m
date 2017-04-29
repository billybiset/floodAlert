//
//  MDTextFieldController.m
//  Medable
//
//  Created by Guillermo Biset on 3/19/15.
//  Copyright (c) 2015 medable. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MDDateFieldView.h"
#import "MDUIHelper.h"

@interface MDDateFieldView ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UIView *datePickerBackground;

@end

MDUIWidget_Declare_Class(MDDateFieldView)

@implementation MDDateFieldView

MDUIWidget_Implement_Class(MDDateFieldView)

+ (instancetype)new
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                          owner:self
                                        options:nil] firstObject];
}

- (instancetype)initWithNib
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
    
    self = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    if ( self != nil )
    {
        [self configure];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self configure];
}

- (void)configure
{
    self.backgroundColor = UIColor.clearColor;

    [MDUIHelper applyCornerRadius:15 toView:self.datePickerBackground];
    
    UIFont *font = [self valueForAppearanceKey:kAppearanceFontKey];
    if ( [font isKindOfClass:[UIFont class]] )
    {
        self.titleLabel.font = font;
    }
}

@end
