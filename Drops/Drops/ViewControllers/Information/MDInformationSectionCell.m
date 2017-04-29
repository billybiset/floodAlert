//
//  MDTaskCellViewController.m
//  Axon
//
//  Created by Guillermo Biset on 5/27/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import "MDInformationSectionCell.h"
#import "MDRTask.h"
#import "UIColor+Medable.h"

@interface MDInformationSectionCell()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *leftColorBarView;

@property (nonatomic, weak) IBOutlet UIImageView *resourceTypeIcon;

@end

@implementation MDInformationSectionCell

+ (CGFloat)height
{
    return 80.0;
}

- (void)configureWithTitle:(NSString *)title
{
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor principalTextColor];
}

- (void)setMainCellColor:(UIColor *)color
{
    self.leftColorBarView.backgroundColor = color;
    UIImage *img = [self.resourceTypeIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.resourceTypeIcon.image = img;
    self.resourceTypeIcon.tintColor = [UIColor secondaryColor];
}

@end
