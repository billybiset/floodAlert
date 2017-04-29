//
//  MDEmptyStateCellTableViewCell.m
//  Axon
//
//  Created by Guillermo Biset on 6/30/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import "MDEmptyStateCell.h"
#import "MDUIHelper.h"

static UIImage *animatedLoadingImage = nil;

@interface MDEmptyStateCell()

@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, copy) MDNoArgumentCallback callback;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@end

@implementation MDEmptyStateCell

+ (NSString *)cellId
{
    return @"kEmptyStateCellId";
}

+ (UIImage *)loadingImage
{
    if ( animatedLoadingImage == nil )
    {
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:38];
        
        for ( NSUInteger idx = 1; idx <= 20; idx++ )
        {
            [frames addObject:[UIImage imageNamed:[NSString stringWithFormat:@"flask-animation-color-%ld",(unsigned long)idx]]];
        }
        
        for ( NSUInteger idx = 19; idx >= 2; idx-- )
        {
            [frames addObject:frames[idx] ];
        }
        
        animatedLoadingImage = [UIImage animatedImageWithImages:frames duration:2.1];
    }

    
    return animatedLoadingImage;
}

+ (void)clearLoadingImageFromMemory
{
    animatedLoadingImage = nil;
}

- (void)configureWithImage:(nullable UIImage *)image
               imageHeight:(CGFloat)imageHeight
                      text:(NSString *)text
                buttonText:(nullable NSString *)buttonText
                  callback:(nullable MDNoArgumentCallback)callback
{
    self.image.image = image;
    self.imageHeightConstraint.constant = imageHeight;
    self.textView.text = text;
    self.button.hidden = buttonText == nil;
    [self.button setTitle:buttonText forState:UIControlStateNormal];
    self.callback = callback;
    
    CGSize sizeThatFits = [self.textView sizeThatFits:self.textView.frame.size];
    
    if (self.textViewHeight.constant != sizeThatFits.height)
    {
        self.textViewHeight.constant = sizeThatFits.height;
    }
    [self layoutSubviews];
    
    self.button.backgroundColor = [UIColor secondaryColor];
    [MDUIHelper applyCornerRadius:3.0 toView:self.button];
}

- (IBAction)buttonSelected:(id)sender
{
    if ( self.callback != nil )
    {
        self.callback();
    }
}

@end
