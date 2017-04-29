#import <UIKit/UIKit.h>

#import "MainNavigationDelegate.h"

@interface ClimateViewController : UIViewController

@property (nonatomic, weak) id<MainNavigationDelegate> navigationDelegate;

@end
