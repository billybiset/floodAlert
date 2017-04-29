//
//  MDButtonView.m
//  Axon
//
//  Created by Guillermo Biset on 3/24/15.
//  Copyright (c) 2015 Guillermo Biset. All rights reserved.
//

#import "MDButtonView.h"

MDUIWidget_Declare_Class(MDButtonView)

@implementation MDButtonView

MDUIWidget_Implement_Class(MDButtonView)

+ (instancetype)new
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                          owner:self
                                        options:nil] firstObject];
}

+ (NSDictionary *)defaultClassAppearance
{
    return @{ kAppearanceFontKey : [UIFont fontWithName:@"Lato-Regular" size:15.0],
              kAppearanceBackgroundImageNameKey : @"",
              kAppearanceHighlightedBackgroundImageNameKey : @"",
              kAppearanceStretchableInsetKey : [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero]
              };
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
    
    NSValue *insetsValue = [self valueForAppearanceKey:kAppearanceStretchableInsetKey];
    UIEdgeInsets insets = insetsValue != nil ? [insetsValue UIEdgeInsetsValue] : UIEdgeInsetsZero;
    
    NSString *background = [self valueForAppearanceKey:kAppearanceBackgroundImageNameKey];
    if ( [background isKindOfClass:[NSString class]] && [background length] > 0 )
    {
        UIImage *image = [[UIImage imageNamed:background] resizableImageWithCapInsets:insets];
        [self.button setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    NSString *highlighted = [self valueForAppearanceKey:kAppearanceHighlightedBackgroundImageNameKey];
    if ( [highlighted isKindOfClass:[NSString class]] && [highlighted length] > 0 )
    {
        self.button.adjustsImageWhenHighlighted = NO;
        UIImage *image = [[UIImage imageNamed:highlighted] resizableImageWithCapInsets:insets];
        [self.button setBackgroundImage:image forState:UIControlStateHighlighted];
    }
    
    UIFont *font = [self valueForAppearanceKey:kAppearanceFontKey];
    if ( [font isKindOfClass:[UIFont class]] )
    {
        self.button.titleLabel.font = font;
    }
}


@end
