#import <UIKit/UIKit.h>

#import "MainNavigationDelegate.h"

@interface RisksViewController : UIViewController

@property (nonatomic, weak) id<MainNavigationDelegate> navigationDelegate;

@end
