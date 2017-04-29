//
//  MDCustomProgressView.h
//  Axon
//
//  Created by Guillermo Biset on 6/28/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDCustomProgressView : UIView

+ (MDCustomProgressView *)addProgressViewToView:(UIView *)containerView;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic) UIColor *color;

- (void)setProgress:(CGFloat)progress animatedWithDuration:(NSTimeInterval)duration;

@end
