//
//  ResourcesViewController.m
//  Drops
//
//  Created by Guillermo Biset on 4/30/17.
//  Copyright © 2017 Grafo. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "ResourcesViewController.h"
#import "UIHelper.h"
#import "WebViewController.h"

@interface ResourcesViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic) IBOutlet UIButton *feedbackButton;

@property (nonatomic) IBOutlet UIButton *adviceButton;
@property (nonatomic) IBOutlet UIButton *unrcButton;
@property (nonatomic) IBOutlet UIButton *sourceCodeButton;

@end

@implementation ResourcesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"RESOURCES", );
    
    [UIHelper configureSecondaryButton:self.sourceCodeButton];
    [UIHelper configureSecondaryButton:self.unrcButton];
    [UIHelper configureSecondaryButton:self.adviceButton];
    
    [UIHelper configureButton:self.feedbackButton];
    [self.feedbackButton setTitle:NSLocalizedString(@"FEEDBACK", ) forState:UIControlStateNormal];
}

- (IBAction)sendFeedback:(id)sender
{
    MFMailComposeViewController *mailCompose = [MFMailComposeViewController new];
    
    if ( mailCompose != nil )
    {
        NSString *title = @"Feedback";
        NSString *body = @"Feedback";
        
        mailCompose.navigationBar.tintColor = [UIColor principalColor];
        mailCompose.navigationBar.barTintColor = [UIColor principalColor];
        mailCompose.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor principalColor] };
        
        [mailCompose setToRecipients:
         @[
           @"billybiset@gmail.com",
           @"anagigena@gmail.com",
           @"carvear@gmail.com",
           @"guillermofabiangomez@gmail.com",
           @"carlitoshernandez20@gmail.com",
           @"javiermarcos0216@gmail.com"
           ]];
        mailCompose.subject = title;
        [mailCompose setMessageBody:body isHTML:NO];
        mailCompose.mailComposeDelegate = self;
        
        [self.navigationDelegate.mainNavigationController presentViewController:mailCompose animated:YES completion:nil];
    }
}

- (IBAction)sourceCodeSelected:(id)sender
{
    NSString *codeWeb = @"https://github.com/billybiset/floodAlert";
    
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.webURL = codeWeb;
    
    [self.navigationDelegate.mainNavigationController pushViewController:webVC animated:YES];
}

- (IBAction)surDeCba:(id)sender
{
    NSString *codeWeb = @"http://www.proin-unrc.com.ar/";
    
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.webURL = codeWeb;
    
    [self.navigationDelegate.mainNavigationController pushViewController:webVC animated:YES];
}

- (IBAction)adviceSelected:(id)sender
{
    NSString *codeWeb = @"https://www.ready.gov/es/inundaciones";
    
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.webURL = codeWeb;
    
    [self.navigationDelegate.mainNavigationController pushViewController:webVC animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self.navigationDelegate.mainNavigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
