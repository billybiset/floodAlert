//
//  MDInformationSectionViewController.m
//  Axon
//
//  Created by Guillermo Biset on 6/3/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import "MDInformationSectionViewController.h"

@interface MDInformationSectionViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation MDInformationSectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.delegate = self;
    
    self.title = self.sectionTitle;

    BOOL shouldLoadRegularContent = YES;
    
    if ( self.webLink != nil && self.webLink.length > 0 )
    {
        NSURL *url = [NSURL URLWithString:self.webLink];
        
        if ( url != nil )
        {
            shouldLoadRegularContent = NO;
            
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            [self.webView loadRequest:requestObj];
        }
    }
    
    if ( shouldLoadRegularContent )
    {
        NSString *htmlContent = self.content;
        
        if ( self.content != nil && ! self.contentIsHTML )
        {
            htmlContent = [NSString stringWithFormat:
                           @"<html>"\
                           @"<body>"\
                           @"%@"\
                           @"</body>"\
                           @"</html>",
                           self.content
                           ];
        }
        
        [self.webView loadHTMLString:htmlContent baseURL:nil];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back1"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backSelected:)];
}

- (void)backSelected:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}


@end
