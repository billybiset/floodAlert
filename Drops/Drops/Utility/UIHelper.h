#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIColor+Drops.h"

typedef void (^NoArgumentCallback)(void);
typedef void (^ObjectCallback)(id object);
typedef void (^ObjectFaultCallback)(id object, NSError* fault);

@interface UIHelper : NSObject

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
          inViewController:(UIViewController *)viewController;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         actionButtonTitle:(NSString *)actionButtonTitle
         cancelButtonTitle:(NSString *)cancelButtonTitle
            actionCallback:(NoArgumentCallback)callback
          inViewController:(UIViewController *)viewController;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         actionButtonTitle:(NSString *)actionButtonTitle
               actionStyle:(UIAlertActionStyle)actionStyle
         cancelButtonTitle:(NSString *)cancelButtonTitle
            actionCallback:(NoArgumentCallback)callback
          inViewController:(UIViewController *)viewController;

+ (void)applyCornerRadius:(CGFloat)radiusInPoints toView:(UIView *)view;

+ (void)configureButton:(UIButton *)button;
+ (void)configureButton:(UIButton *)button withColor:(UIColor *)color;
+ (void)configureSecondaryButton:(UIButton *)button;
+ (void)configureSecondaryButton:(UIButton *)button withOutlineColor:(UIColor *)color;
+ (void)configureDestructiveButton:(UIButton *)button;

+ (CAGradientLayer *)gradientForView:(UIView *)view;
+ (void)adjustGradient:(CAGradientLayer *)gradient toView:(UIView *)view;
+ (void)animateGradient:(CAGradientLayer *)gradient;

@end
