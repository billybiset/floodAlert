#import "MainNavigationViewController.h"
#import "MapViewController.h"
#import "ClimateViewController.h"
#import "RisksViewController.h"

#import "UIColor+Drops.h"

@interface MainNavigationViewController ()
    <UITabBarDelegate>

@property (nonatomic, weak) IBOutlet UITabBar *tabBar;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *separatorView;

@property (nonatomic) UIViewController *currentVC;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSArray *viewControllers;

@property (nonatomic, weak) IBOutlet UIView *uploadingView;
@property (nonatomic, weak) IBOutlet UIView *uploadingProgressContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *uploadingViewBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *containerViewTop;

@property (nonatomic) NSTimer *badgeSyncTimer;
@property (nonatomic) NSTimer *healthKitUploaderTimer;

@end

@implementation MainNavigationViewController

- (instancetype)init
{
    self = [super init];
    
    if ( self != nil )
    {
        MapViewController *mapVc = [[MapViewController alloc] init];
        mapVc.navigationDelegate = self;
        
        ClimateViewController *climateVc = [[ClimateViewController alloc] init];
        climateVc.navigationDelegate = self;
        
        RisksViewController *risksVc = [[RisksViewController alloc] init];
        risksVc.navigationDelegate = self;
        
        UIViewController *resourcesVc = [[UIViewController alloc] init];
        
        self.viewControllers = @[
                                    mapVc,
                                    climateVc,
                                    risksVc,
                                    resourcesVc
                                 ];
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationController.navigationBarHidden = NO;
    
    self.currentIndex = -1;
    [self selectItemAtIndex:0];
    
    self.tabBar.tintColor = [UIColor secondaryColor];
    
    [[UITabBarItem appearance] setTitleTextAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Lato-Light" size:12.0]} forState:UIControlStateNormal];
    
    [self localizeOutlets];
}

- (void)localizeOutlets
{
    UITabBarItem *mapItem = self.tabBar.items[0];
    UITabBarItem *climateItem = self.tabBar.items[1];
    UITabBarItem *risksItem = self.tabBar.items[2];
    UITabBarItem *resourcesItem = self.tabBar.items[3];
    
    
    [mapItem setTitle:NSLocalizedString(@"MAP", )];
    [climateItem setTitle:NSLocalizedString(@"CLIMATE", )];
    [risksItem setTitle:NSLocalizedString(@"RISK", )];
    [resourcesItem setTitle:NSLocalizedString(@"RESOURCES", )];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark - View Management

- (void)changeCurrentViewController:(UIViewController *)viewController
{
    [self.currentVC.view removeFromSuperview];
    
    self.currentVC = viewController;
    viewController.view.frame = self.containerView.bounds;
    [self.containerView insertSubview:viewController.view belowSubview:self.separatorView];
    
    self.title = viewController.title;
}

- (void)selectItemAtIndex:(NSInteger)index
{
    if ( index == self.currentIndex )
    {
        return;
    }
    
    UIViewController *vc = self.viewControllers[index];
    
    [self changeCurrentViewController:vc];
    UITabBarItem *item = self.tabBar.items[index];
    
    [self.tabBar setSelectedItem:item];
    self.currentIndex = index;

    if ( [vc respondsToSelector:@selector(rightBarButtonItem)] )
    {
        self.navigationItem.rightBarButtonItem = [vc performSelector:@selector(rightBarButtonItem)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self adjustNavigationBar];
}

- (void)adjustNavigationBar
{
    [self.navigationController setNavigationBarHidden:self.currentIndex <= 2];
    self.containerViewTop.constant = self.currentIndex <= 2 ? 0 : 42;
    [self.view layoutIfNeeded];
}

#pragma mark - Tab Bar

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger index = [tabBar.items indexOfObject:item];
    [self selectItemAtIndex:index];
}

#pragma mark - MainNavigationDelegate

- (void)presentViewController:(UIViewController *)viewControllerToPresent
{
    [self presentViewController:viewControllerToPresent animated:YES completion:nil];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UINavigationController *)mainNavigationController
{
    return self.navigationController;
}

- (void)popToMain
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void)viewController:(UIViewController *)viewController hasUpdatedBadgeCount:(NSInteger)badgeCount
{
    NSInteger position = [self.viewControllers indexOfObject:viewController];
    
    if ( position == NSNotFound )
    {
        return;
    }
    
    UITabBarItem *item = self.tabBar.items[position];
    if ( badgeCount == 0 )
    {
        item.badgeValue = nil;
    }
    else
    {
        item.badgeValue = [NSString stringWithFormat:@"%ld", (long)badgeCount];
    }
}

@end
