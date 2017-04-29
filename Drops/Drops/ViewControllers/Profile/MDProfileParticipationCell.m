//
//  MDTaskCellViewController.m
//  Axon
//
//  Created by Guillermo Biset on 5/27/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import "MDProfileParticipationCell.h"
#import "MDRTask.h"
#import "UIColor+Medable.h"
#import "MDRStudy.h"

@interface MDProfileParticipationCell()

@property (nonatomic, weak) IBOutlet UILabel *participationLabel;
@property (nonatomic, weak) IBOutlet UILabel *studyNameLabel;
@property (nonatomic, weak) IBOutlet UIView *leftColorBarView;

@end

@implementation MDProfileParticipationCell

+ (CGFloat)height
{
    return 75.0;
}

- (void)configureWithStudy:(MDRStudy *)study
{
    self.studyNameLabel.text = study.name;
    self.studyNameLabel.textColor = [UIColor principalTextColor];
    self.participationLabel.textColor = [UIColor secondaryTextColor];
}

- (void)setMainCellColor:(UIColor *)color
{
    self.leftColorBarView.backgroundColor = color;
}

- (IBAction)leaveStudy:(id)sender
{
    [self.delegate leaveStudy];
}

@end
