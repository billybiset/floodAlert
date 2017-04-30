#import <UIKit/UIKit.h>

@protocol MainNavigationDelegate <NSObject>

- (void)presentViewController:(UIViewController *)viewControllerToPresent;
- (void)dismissViewController;
- (UINavigationController *)mainNavigationController;
- (void)popToMain;
- (void)viewController:(UIViewController *)viewController hasUpdatedBadgeCount:(NSInteger)badgeCount;

@end
