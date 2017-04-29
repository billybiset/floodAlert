#import <UIKit/UIKit.h>

@interface UIColor(Drops)

+ (UIColor *)principalColor;
+ (UIColor *)secondaryColor;
+ (UIColor *)destructiveActionColor;
+ (UIColor *)principalTextColor;
+ (UIColor *)secondaryTextColor;

+ (UIColor *)colorWithHex:(NSString *)hex;

@end
