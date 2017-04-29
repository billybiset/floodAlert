//
//  MDEmptyStateCellTableViewCell.h
//  Axon
//
//  Created by Guillermo Biset on 6/30/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDEmptyStateCell : UITableViewCell

+ (nonnull NSString *)cellId;

+ (nullable UIImage *)loadingImage;
+ (void)clearLoadingImageFromMemory;

- (void)configureWithImage:(nullable UIImage *)image
               imageHeight:(CGFloat)imageHeight
                      text:(nonnull NSString *)text
                buttonText:(nullable NSString *)buttonText
                  callback:(nullable MDNoArgumentCallback)callback;


@end
