//
//  MDTaskCellViewController.m
//  Axon
//
//  Created by Guillermo Biset on 5/27/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import "MDInformationLogosCell.h"
#import "MDRTask.h"
#import "UIColor+Medable.h"
#import "MDRStudy.h"

@interface MDInformationLogosCell()

@property (nonatomic, weak) IBOutlet UIImageView *logo1;
@property (nonatomic, weak) IBOutlet UIImageView *logo2;
@property (nonatomic, weak) IBOutlet UIImageView *logo3;
@property (nonatomic, weak) IBOutlet UILabel *studyNameLabel;

@end

@implementation MDInformationLogosCell

+ (CGFloat)height
{
    return 120.0;
}

- (void)configureWithStudy:(MDRStudy *)study
{
    self.studyNameLabel.text = study.name;
    self.studyNameLabel.textColor = [UIColor principalTextColor];
}

@end
