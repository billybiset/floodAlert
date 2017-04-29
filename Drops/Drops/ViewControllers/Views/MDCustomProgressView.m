//
//  MDCustomProgressView.m
//  Axon
//
//  Created by Guillermo Biset on 6/28/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MDCustomProgressView.h"
#import "UIColor+Medable.h"

@interface MDCustomProgressView ()

@property (nonatomic) UIView *progressView;

@end

@implementation MDCustomProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self != nil )
    {
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        [self addSubview:self.progressView];
        
        self.layer.cornerRadius = 2;
        self.clipsToBounds = YES;
    }
    
    return self;
}

+ (MDCustomProgressView *)addProgressViewToView:(UIView *)containerView
{
    MDCustomProgressView *progressView = [[MDCustomProgressView alloc] initWithFrame:containerView.bounds];
    
    containerView.backgroundColor = [UIColor clearColor];
    
    progressView = progressView;
    progressView.backgroundColor = [UIColor lightGrayColor];
    progressView.color = [UIColor secondaryColor];
    
    [containerView addSubview:progressView];
    
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[progressView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(progressView)]];
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[progressView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(progressView)]];
    
    [containerView layoutIfNeeded];
    
    return progressView;
}

-(void)setColor:(UIColor *)color
{
    self.progressView.backgroundColor = color;
    _color = color;
}

-(void)setProgress:(CGFloat)progress
{
    //Cap progress to [0,1] interval
    progress = MAX(0, MIN( 1, progress));
    
    _progress = progress;
    CGRect frame = self.progressView.frame;
    frame.size.width = self.frame.size.width * progress;
    self.progressView.frame = frame;
}

- (void)setProgress:(CGFloat)progress animatedWithDuration:(NSTimeInterval)duration
{
    if ( duration > 0 )
    {
        [UIView animateWithDuration:duration
                         animations:^
        {
            [self setProgress:progress];
        }];
    }
}


@end
