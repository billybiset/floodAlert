#import "OnboardingController.h"
#import "TutorialViewController.h"
#import "MainNavigationViewController.h"

#import "UIColor+Drops.h"
#import "UIHelper.h"

static NSString *kProgress = @"kProgress";
static NSString *kHasSeenTutorial = @"kHasSeenTutorial";

typedef NS_ENUM(NSInteger, MDOnboardingStatus)
{
    MDOnboardingStatusNotStarted,
    MDOnboardingStatusStarted,
    MDOnboardingStatusCompleted
};

@interface OnboardingController()
    <TutorialViewControllerDelegate,
    UINavigationControllerDelegate
    >

@property (nonatomic) UIWindow *window;
@property (nonatomic) UINavigationController *navigationController;

@property (nonatomic, assign) BOOL isPushingParticipationController;

@end

@implementation OnboardingController

+ (instancetype)instance
{
    static OnboardingController *instance = nil;
    static dispatch_once_t onceToken;
    
    if ( instance == nil )
    {
        dispatch_once(&onceToken, ^
                      {
                          instance = [OnboardingController new];
                      });
    }
    
    return instance;
}

+ (void)clearPastOnboardingData
{
    [[OnboardingController instance] clearPastOnboardingData];
}

+ (void)startOnWindow:(UIWindow *)window
{
    [[OnboardingController instance] startOnWindow:window];
}

- (void)startOnWindow:(UIWindow *)window
{
    self.window = window;

    [[UINavigationBar appearance] setTintColor:[UIColor secondaryColor]];
    
    if ( ! [self hasSeenTutorial] )
    {
        TutorialViewController *tutorialVC = [TutorialViewController new];
        tutorialVC.delegate = self;
        
        window.rootViewController = tutorialVC;
    }
    else
    {
        [self exitTutorial];
    }
}

- (NSNumber *)progressValueForVariable:(NSString *)variable
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *onboardingProgress = [userDefaults objectForKey:kProgress];
    
    NSNumber *value = onboardingProgress[variable];
    
    return value;
}

- (BOOL)onboardingProgressForVariable:(NSString *)variable
{
    NSNumber *value = [self progressValueForVariable:variable];
    
    return [value boolValue];
}

- (BOOL)hasSeenTutorial
{
    return NO;
    //[self onboardingProgressForVariable:kHasSeenTutorial];
}

- (void)clearPastOnboardingData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kProgress];
    [userDefaults synchronize];
}

- (void)markProgressVariable:(NSString *)variable withValue:(NSNumber *)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *progress = [userDefaults objectForKey:kProgress];
    
    if ( progress == nil )
    {
        [userDefaults setObject:@{ variable: value } forKey:kProgress];
    }
    else if ( progress[variable] != value )
    {
        NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:progress];
        mutable[variable] = value;
        
        [userDefaults setObject:mutable forKey:kProgress];
        [userDefaults synchronize];
    }
}

- (void)markTutorialAsSeen:(BOOL)seen
{
    [self markProgressVariable:kHasSeenTutorial withValue:@(seen)];
}

- (void)initializeEnvironment
{
    [[UINavigationBar appearance] setTitleTextAttributes:
        @{
          NSForegroundColorAttributeName : [UIColor colorWithHex:@"595959"],
          NSFontAttributeName : [UIFont fontWithName:@"Lato-Regular" size:16.0]
          }];
}

- (void)exitTutorial
{
    [self startOnboarding];
}

- (void)startOnboarding
{
    [self markTutorialAsSeen:YES];
    [self initializeEnvironment];
    
    if ( self.navigationController == nil )
    {
        UINavigationController *navController = [UINavigationController new];
        self.navigationController = navController;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    MainNavigationViewController *mainNavigationVC = [MainNavigationViewController new];
    
    self.navigationController.viewControllers = @[ mainNavigationVC ];
    
    self.window.rootViewController = self.navigationController;
    
    self.navigationController.delegate = self;
}

#pragma mark - TutorialViewControllerDelegate

- (void)completedTutorial
{
    [self exitTutorial];
}

- (void)presentOnboardingViewController:(UIViewController *)viewController
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [self.navigationController pushViewController:viewController animated:YES];
     }];
}

- (void)continueToParticipation
{
    /*
    //This fixes a UI bug where the navigation bar is hidden, curiously you have to hide it for it show...
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //Don't listen to notifications anymore.
    [self stopListeningToTaskDownloadNotifications];
    
    if ( ! self.isPushingParticipationController )
    {
        MDParticipationViewController *participationVC = [[MDParticipationViewController alloc] initWithStudy:self.study];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [self.onboardingVC setLogoImage];
             [self.onboardingVC clearImagesFromMemory];
             
             //Need to check again because several might have been queued
             if ( ! self.isPushingParticipationController )
             {
                 self.isPushingParticipationController = YES;
                 
                 [[UITextField appearance] setTintColor:[UIColor principalColor]];
                 
                 [self.navigationController pushViewController:participationVC animated:YES];
             }
         }];
    }
     */
}

@end

