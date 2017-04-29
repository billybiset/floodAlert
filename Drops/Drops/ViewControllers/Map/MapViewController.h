#import <UIKit/UIKit.h>

#import "MainNavigationDelegate.h"

@interface MapViewController : UIViewController

@property (nonatomic, weak) id<MainNavigationDelegate> navigationDelegate;

@end
