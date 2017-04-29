#import "UIColor+Drops.h"

@implementation UIColor(Drops)

+ (UIColor *)principalColor
{
    return [UIColor colorWithHex:@"1772ff"];
}

+ (UIColor *)secondaryColor
{
    return [UIColor colorWithHex:@"001473"];
}

+ (UIColor *)destructiveActionColor
{
    return [UIColor colorWithHex:@"e31f16"];
}
+ (UIColor *)principalTextColor
{
    return [UIColor colorWithHex:@"222222"];
}

+ (UIColor *)secondaryTextColor
{
    return [UIColor colorWithHex:@"666666"];
}

+ (UIColor *)colorWithHex:(NSString *)hex
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
