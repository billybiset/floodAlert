#import <UIKit/UIKit.h>

@protocol TutorialViewControllerDelegate

- (void)completedTutorial;

@end

@interface TutorialViewController : UIViewController

@property (nonatomic, weak) id<TutorialViewControllerDelegate> delegate;

@end
