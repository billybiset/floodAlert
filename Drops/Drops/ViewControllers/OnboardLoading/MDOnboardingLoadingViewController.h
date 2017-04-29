//
//  MDMockLoginViewController.h
//  Axon
//
//  Created by Guillermo Biset on 7/13/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDOnboardingLoadingViewController : UIViewController

- (void)setMessage:(NSString *)message;
- (void)setImage:(UIImage *)image;
- (void)setLogoImage;
- (void)setLoadingImage;
- (void)clearImagesFromMemory;
- (void)showRetryButtonWithTitle:(NSString *)title callback:(MDNoArgumentCallback)callback;
- (void)hideRetryButtonAndDismissCallback;

@end
