#import "UIHelper.h"

@interface UIHelper() <UIAlertViewDelegate>

@property (nonatomic, copy) NoArgumentCallback callback;

@end

@implementation UIHelper

- (instancetype)initWithCallback:(NoArgumentCallback)callback
{
    self = [super init];
    
    if ( self != nil )
    {
        _callback = callback;
    }
    
    return self;
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
          inViewController:(UIViewController *)viewController
{
    [self showAlertWithTitle:title
                     message:message
           actionButtonTitle:nil
                 actionStyle:UIAlertActionStyleDefault
           cancelButtonTitle:cancelButtonTitle
             actionCallback:nil
            inViewController:viewController];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         actionButtonTitle:(NSString *)actionButtonTitle
         cancelButtonTitle:(NSString *)cancelButtonTitle
            actionCallback:(NoArgumentCallback)callback
          inViewController:(UIViewController *)viewController
{
    [self showAlertWithTitle:title
                     message:message
           actionButtonTitle:actionButtonTitle
                 actionStyle:UIAlertActionStyleDefault
           cancelButtonTitle:cancelButtonTitle
              actionCallback:callback
            inViewController:viewController];

}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         actionButtonTitle:(NSString *)actionButtonTitle
               actionStyle:(UIAlertActionStyle)actionStyle
         cancelButtonTitle:(NSString *)cancelButtonTitle
            actionCallback:(NoArgumentCallback)callback
          inViewController:(UIViewController *)viewController
{
    UIAlertController *alert = [UIAlertController new];
    alert.title = title;
    alert.message = message;
    
    if ( actionButtonTitle != nil && callback != nil )
    {
        UIAlertAction *actionAction = [UIAlertAction actionWithTitle:actionButtonTitle
                                                               style:actionStyle
                                                             handler:^(UIAlertAction *action)
                                       {
                                           if ( callback != nil )
                                           {
                                               callback();
                                           }
                                       }];
        
        [alert addAction:actionAction];
    }

    if ( cancelButtonTitle != nil )
    {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
        
        [alert addAction:cancelAction];
    }
    alert.popoverPresentationController.sourceView = viewController.view;
    CGFloat navHeight = viewController.navigationController.navigationBar.frame.size.height;
    if ( navHeight == 0.0 )
    {
        navHeight = 44.0;
    }
    
    alert.popoverPresentationController.sourceRect = CGRectMake(0, 0, viewController.view.frame.size.width, navHeight);
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)applyCornerRadius:(CGFloat)radiusInPoints toView:(UIView *)view
{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = radiusInPoints;
}

+ (void)configureButton:(UIButton *)button
{
    [UIHelper configureButton:button withColor:[UIColor secondaryColor]];
}

+ (void)configureButton:(UIButton *)button withColor:(UIColor *)color
{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = color;
    [UIHelper applyCornerRadius:3.0 toView:button];
}

+ (void)configureSecondaryButton:(UIButton *)button withOutlineColor:(UIColor *)color
{
    [button setTitleColor:color forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1.0;
    
    [UIHelper applyCornerRadius:3.0 toView:button];
}

+ (void)configureSecondaryButton:(UIButton *)button
{
    [UIHelper configureSecondaryButton:button withOutlineColor:[UIColor secondaryColor]];
}

+ (void)configureDestructiveButton:(UIButton *)button
{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor destructiveActionColor];
    [UIHelper applyCornerRadius:3.0 toView:button];
}

#pragma mark - Gradient

+ (CAGradientLayer *)gradientForView:(UIView *)view
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = @[(id)[UIColor colorWithHex:@"3425a3"].CGColor, (id)[UIColor colorWithHex:@"17002c"].CGColor];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    
    [view.layer insertSublayer:gradient atIndex:0];
    
    return gradient;
}

+ (void)adjustGradient:(CAGradientLayer *)gradient toView:(UIView *)view
{
    gradient.frame = view.bounds;
}

+ (void)animateGradient:(CAGradientLayer *)gradient
{
    if ( gradient.animationKeys.count == 0 )
    {
        NSArray *oldColors = gradient.colors;
        NSArray *newColors = @[(id)[UIColor secondaryColor].CGColor, (id)[UIColor principalColor].CGColor];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"colors"];
        
        animation.fromValue = oldColors;
        animation.toValue = newColors;
        animation.duration = 10.0;
        animation.repeatDuration = HUGE_VALF;
        animation.autoreverses = YES;
        animation.fillMode = kCAFillModeForwards;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        [gradient addAnimation:animation forKey:@"animateGradientColorChange"];
    }
}

@end
