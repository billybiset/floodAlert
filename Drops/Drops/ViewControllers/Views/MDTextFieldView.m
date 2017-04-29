//
//  MDTextFieldController.m
//  Medable
//
//  Created by Guillermo Biset on 3/19/15.
//  Copyright (c) 2015 medable. All rights reserved.
//

#import "MDTextFieldView.h"

@interface MDTextFieldView ()
    < UITextFieldDelegate >

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIImageView *textFieldBackground;

@property (nonatomic, strong) UIImage *normalBackground;
@property (nonatomic, strong) UIImage *highlightedBackground;

@property (nonatomic, assign) NSInteger warningCountdown;
@property (nonatomic, strong) NSTimer *warningTimer;
@property (nonatomic, strong) UIView *warningOverlay;

@end

MDUIWidget_Declare_Class(MDTextFieldView)

@implementation MDTextFieldView

MDUIWidget_Implement_Class(MDTextFieldView)

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
    
    NSValue *insetsValue = [self valueForAppearanceKey:kAppearanceStretchableInsetKey];
    UIEdgeInsets insets = insetsValue != nil ? [insetsValue UIEdgeInsetsValue] : UIEdgeInsetsZero;
    
    NSString *background = [self valueForAppearanceKey:kAppearanceBackgroundImageNameKey];
    if ( [background isKindOfClass:[NSString class]] )
    {
        self.normalBackground = [[UIImage imageNamed:background] resizableImageWithCapInsets:insets];
    }
    
    NSString *highlighted = [self valueForAppearanceKey:kAppearanceHighlightedBackgroundImageNameKey];
    if ( [highlighted isKindOfClass:[NSString class]] )
    {
        self.highlightedBackground = [[UIImage imageNamed:highlighted] resizableImageWithCapInsets:insets];
    }
    
    self.textFieldBackground.image = self.normalBackground;
    self.textFieldBackground.highlightedImage = self.highlightedBackground;
    
    UIFont *font = [self valueForAppearanceKey:kAppearanceFontKey];
    if ( [font isKindOfClass:[UIFont class]] )
    {
        self.textField.font = font;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textFieldBackground.highlighted = YES;

    if ( [self.textFieldDelegate respondsToSelector:_cmd] )
    {
        [self.textFieldDelegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ( [self.textFieldDelegate respondsToSelector:_cmd] )
    {
        return [self.textFieldDelegate textFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ( [self.textFieldDelegate respondsToSelector:_cmd] )
    {
        return [self.textFieldDelegate textFieldShouldEndEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ( [self.textFieldDelegate respondsToSelector:_cmd] )
    {
        [self.textFieldDelegate textFieldDidEndEditing:textField];
    }
    
    self.textFieldBackground.highlighted = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [self.textFieldDelegate respondsToSelector:_cmd] )
    {
        return [self.textFieldDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ( [self.textFieldDelegate respondsToSelector:_cmd] )
    {
        return [self.textFieldDelegate textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( [self.textFieldDelegate respondsToSelector:_cmd] )
    {
        return [self.textFieldDelegate textFieldShouldReturn:textField];
    }
    
    return YES;
}

- (void)signalWarning
{
    self.warningCountdown = 6;
    
    UIView *overlay = [[UIView alloc] initWithFrame:[self.textFieldBackground frame]];
    
    UIImageView *maskImageView = [[UIImageView alloc] initWithImage:self.normalBackground];
    [maskImageView setFrame:[overlay bounds]];
    
    [[overlay layer] setMask:[maskImageView layer]];
    CGContextClipToMask(UIGraphicsGetCurrentContext(), [overlay bounds], self.normalBackground.CGImage);
    [overlay setBackgroundColor:[UIColor redColor]];

    overlay.alpha = 0.0;
    
    [self addSubview:overlay];

    self.warningOverlay = overlay;
    
    self.warningTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(toggleHighlighted:)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)toggleHighlighted:(NSTimer *)timer
{
    [UIView animateWithDuration:1 animations:^
    {
        self.warningOverlay.alpha = 1.0 - self.warningOverlay.alpha;
    }];
    
    --self.warningCountdown;
    
    if ( self.warningCountdown == 0 )
    {
        [self.warningTimer invalidate];
        self.warningTimer = nil;
        
        self.textFieldBackground.highlighted = NO;
        
        [self.warningOverlay removeFromSuperview];
        self.warningOverlay = nil;
    }
}

@end
