//
//  MDMockLoginViewController.m
//  Axon
//
//  Created by Guillermo Biset on 7/13/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import "MDOnboardingLoadingViewController.h"
#import "MDUIHelper.h"
#import "MDCustomProgressView.h"

@interface MDOnboardingLoadingViewController ()

@property (nonatomic, weak) IBOutlet UIView *progressViewContainer;

@property (nonatomic) MDCustomProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *backgroundView;

@property (nonatomic, weak) IBOutlet UITextView *messageTextView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *messageTextViewHeight;

@property (nonatomic, weak) IBOutlet UIButton *retryButton;

@property (nonatomic, copy) MDNoArgumentCallback retryButtonCallback;

@property (nonatomic) UIImage *animatedLoadingImage;

@end

@implementation MDOnboardingLoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MDCustomProgressView *customProgress = [[MDCustomProgressView alloc] initWithFrame:self.progressViewContainer.bounds];
    customProgress.color = [UIColor principalColor];
    customProgress.progress = 0.05;
    customProgress.backgroundColor = [UIColor whiteColor];
    [self.progressViewContainer addSubview:customProgress];
    self.progressView = customProgress;
    
    self.backgroundView.backgroundColor = [UIColor secondaryColor];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.retryButton setTitleColor:[UIColor secondaryColor] forState:UIControlStateNormal];
    self.retryButton.backgroundColor = [UIColor whiteColor];
    [MDUIHelper applyCornerRadius:3.0 toView:self.retryButton];
    
    [self setLoadingImage];
}

- (IBAction)retryPressed:(UIButton *)button
{
    [self buttonRemoveHighlight:button];
    [self setLoadingImage];
    
    if ( self.retryButtonCallback )
    {
        [self setMessage:@"Loading..."];
        self.retryButtonCallback();
        [self hideRetryButtonAndDismissCallback];
    }
}

- (IBAction)buttonHighlight:(UIButton *)button
{
    button.backgroundColor = [UIColor principalColor];
}

- (IBAction)buttonRemoveHighlight:(UIButton *)button
{
    button.backgroundColor = [UIColor whiteColor];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setMessage:(NSString *)message
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         self.messageTextView.text = message;
         CGSize size = [self.messageTextView sizeThatFits:CGSizeMake(self.messageTextView.frame.size.width, self.view.frame.size.height)];
         self.messageTextViewHeight.constant = size.height;
         [self.view layoutIfNeeded];
     }];
}

- (void)setImage:(UIImage *)image
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         self.imageView.image = image;
     }];
}

- (UIImage *)logoImage
{
    return [UIImage imageNamed:@"logo"];
}

- (UIImage *)loadingImage
{
    if ( self.animatedLoadingImage == nil )
    {
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:38];
        
        for ( NSUInteger idx = 1; idx <= 20; idx++ )
        {
            [frames addObject:[UIImage imageNamed:[NSString stringWithFormat:@"flask-animation-frames-%ld",(unsigned long)idx]]];
        }
        
        for ( NSUInteger idx = 19; idx >= 2; idx-- )
        {
            [frames addObject:frames[idx] ];
        }
        
        self.animatedLoadingImage = [UIImage animatedImageWithImages:frames duration:2.1];
    }
    
    return self.animatedLoadingImage;
}

- (void)setLoadingImage
{
    self.imageView.image = [self loadingImage];
}

- (void)setLogoImage
{
    self.imageView.image = [self logoImage];
}

- (void)clearImagesFromMemory
{
    self.animatedLoadingImage = nil;
}

- (void)showRetryButtonWithTitle:(NSString *)title callback:(MDNoArgumentCallback)callback
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         self.retryButton.hidden = NO;
         [self.retryButton setTitle:title forState:UIControlStateNormal];
     }];
    
    self.retryButtonCallback = callback;
}

- (void)hideRetryButtonAndDismissCallback
{
    self.retryButtonCallback = nil;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         self.retryButton.hidden = YES;
     }];
}

@end
