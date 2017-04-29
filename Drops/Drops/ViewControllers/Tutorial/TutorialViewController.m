#import "TutorialViewController.h"
#import "UIColor+Drops.h"
#import "UIHelper.h"
#import "OnboardingController.h"

@interface TutorialViewController () <UIScrollViewDelegate,  UITextFieldDelegate>

@property (nonatomic) IBOutletCollection(UIView) NSArray *pageViews;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic) IBOutlet UIButton *skipButton;
@property (nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) BOOL animatingScrollView;

@property (nonatomic) IBOutletCollection(UIView) NSArray *specificPageViews;

@property (nonatomic) IBOutlet UILabel *screen1BuiltByLabel;
@property (nonatomic) IBOutlet NSLayoutConstraint *screen1BuiltByConstraint;
@property (nonatomic) IBOutlet UIImageView *screen1TeamImage;

@property (nonatomic) IBOutlet NSLayoutConstraint *screen2ImageLeft;
@property (nonatomic) IBOutlet NSLayoutConstraint *screen2ImageRight;
@property (nonatomic) IBOutlet UITextView *screen2TextView;

@property (nonatomic) IBOutlet NSLayoutConstraint *screen3ImageTop;
@property (nonatomic) IBOutlet UITextView *screen3TextView;

@property (nonatomic) IBOutlet NSLayoutConstraint *screen4ImageBottom;
@property (nonatomic) IBOutlet UITextView *screen4TextView;

@property (nonatomic) CAGradientLayer *gradient;

@end

@implementation TutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor secondaryColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.delegate = self;
    
    self.skipButton.alpha = 0.0;
    
    [UIHelper applyCornerRadius:3.0 toView:self.skipButton];
    [UIHelper applyCornerRadius:3.0 toView:self.doneButton];
    
    for ( UIView *view in self.pageViews )
    {
        view.backgroundColor = [UIColor clearColor];
    }
    for ( UIView *view in self.specificPageViews )
    {
        view.backgroundColor = [UIColor clearColor];
    }
    
    [self configureGradient];
}

- (void)configureGradient
{
    if ( self.gradient == nil )
    {
        self.gradient = [UIHelper gradientForView:self.view];
    }
    else
    {
        [UIHelper adjustGradient:self.gradient toView:self.view];
        [UIHelper animateGradient:self.gradient];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self configureGradient];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSInteger numberOfPages = self.pageViews.count;
    CGFloat contentWidth = self.view.frame.size.width * numberOfPages;
    
    self.scrollView.contentSize = CGSizeMake(contentWidth, 0);
    
    NSInteger index = 0;
    for ( UIView *view in self.specificPageViews )
    {
        UIView *containerView = self.pageViews[index];
        view.frame = containerView.bounds;
        [containerView addSubview:view];
        
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
        
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
        
        ++index;
    }
    
    [self.view layoutSubviews];
    
    [self startFirstScreenAnimation];
}

- (void)startFirstScreenAnimation
{
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:1.0 animations:^
    {
        self.screen1BuiltByConstraint.constant = 12.0;
        self.screen1BuiltByLabel.alpha = 1.0;
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished)
    {
        [self performSelector:@selector(animateSecondStep) withObject:nil afterDelay:1.5];
    }];
}

- (void)animateSecondStep
{
    [UIView animateWithDuration:0.5 animations:^
     {
         self.screen1TeamImage.alpha = 1.0;
         self.screen1BuiltByLabel.text = @"&";
     }
        completion:^(BOOL finished)
     {
         [self animateToSecondPage];
     }];
}

- (void)animateToSecondPage
{
    if ( self.scrollView.contentOffset.x == 0 )
    {
        self.pageControl.currentPage = 1;
        [self pageControlChangedPage:self.pageControl];
    }
    
    [UIView animateWithDuration:0.5 animations:^
    {
        self.skipButton.alpha = 1.0;
        self.screen1BuiltByLabel.alpha = 0.0;
    }];
}

- (IBAction)moveOn:(id)sender
{
    [self.delegate completedTutorial];
}

#pragma mark - UIScrollViewDelegate

- (void)fixTextViewFontSize:(UITextView *)textView
{
    CGSize desiredSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, self.view.frame.size.height)];
    UIFont *font = textView.font;
    
    while ( desiredSize.height > textView.frame.size.height && font.pointSize >= 10.0)
    {
        textView.font = [font fontWithSize:font.pointSize - 0.5];
        font = textView.font;
        desiredSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, self.view.frame.size.height)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (offsetX + (width / 2.0)) / width;
    
    if ( offsetX >= width && offsetX <= width * 2.0 )
    {
        self.screen2ImageLeft.constant =  8 + (( width - offsetX  ) / width) * 392 * 2;
        self.screen2ImageRight.constant = 400 - (( width * 2 - offsetX ) / width) * 392 * 2;
        self.screen2TextView.alpha = 1.0 - ( (offsetX - width )  / width ) * 2;
        
        [self fixTextViewFontSize:self.screen2TextView];
    }
    
    if ( offsetX >= width && offsetX <= width * 3.0 )
    {
        self.screen3ImageTop.constant =  48 + (( width * 2 - offsetX ) / width) * 120;
        
        [self fixTextViewFontSize:self.screen3TextView];
    }
    
    if ( offsetX >= width * 2 )
    {
        self.screen4ImageBottom.constant = 75 + ( (offsetX - width * 2) / width ) * 100.0;
        self.screen4TextView.alpha = ( (offsetX - width * 2)  / width );
        
        [self fixTextViewFontSize:self.screen4TextView];
    }
    
    [self.view layoutIfNeeded];
    
    //Avoid jitteryness when page is selected manually
    if ( self.animatingScrollView )
    {
        return;
    }
    
    self.pageControl.currentPage = page;
    [self updateSkipAndDoneButtons];
}

- (void)updateSkipAndDoneButtons
{
    BOOL goingToLastPage = self.pageControl.currentPage == self.pageViews.count - 1;
    self.skipButton.hidden = goingToLastPage;
    self.doneButton.hidden = !goingToLastPage;
}

#pragma mark - UIPageControl Handling

- (IBAction)pageControlChangedPage:(UIPageControl *)pageControl
{
    NSInteger page = self.pageControl.currentPage;
    self.animatingScrollView = YES;
    
    [UIView animateWithDuration:0.25
                     animations:^
    {
        [self.scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width, 0)];
        [self updateSkipAndDoneButtons];
    }
                     completion:^(BOOL finished)
    {
        self.animatingScrollView = NO;
    }];
}

@end
