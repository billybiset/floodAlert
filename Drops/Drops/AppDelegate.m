#import "AppDelegate.h"
#import "OnboardingController.h"

@interface AppDelegate ()

@property (nonatomic, readwrite) UINavigationController* navController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [OnboardingController startOnWindow:self.window];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"Memory warning.");
}

@end
