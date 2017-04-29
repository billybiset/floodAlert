//
//  MDTaskCellViewController.m
//  Axon
//
//  Created by Guillermo Biset on 5/27/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import "MDProfileValueCell.h"
#import "MDRTask.h"
#import "UIColor+Medable.h"

@interface MDProfileValueCell()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, weak) IBOutlet UIView *leftColorBarView;


@end

@implementation MDProfileValueCell

+ (CGFloat)height
{
    return 60.0;
}

- (void)configureWithTitle:(NSString *)title value:(NSString *)value
{
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor principalTextColor];
    self.valueLabel.text = value;
    self.valueLabel.textColor = [UIColor secondaryTextColor];
}

- (void)setMainCellColor:(UIColor *)color
{
    self.leftColorBarView.backgroundColor = color;
}

@end
