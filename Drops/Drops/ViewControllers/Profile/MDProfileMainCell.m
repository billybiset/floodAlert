//
//  MDTaskCellViewController.m
//  Axon
//
//  Created by Guillermo Biset on 5/27/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <Medable/Medable.h>

#import "MDRAxon.h"
#import "MDProfileMainCell.h"
#import "UIColor+Medable.h"
#import "MDUIHelper.h"

@interface MDProfileMainCell()

@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UIButton *logoutButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nameLabelCenterToAvatarConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *avatarToLeftMarginConstraint;

@end

@implementation MDProfileMainCell

+ (CGFloat)height
{
    return 120.0;
}

- (void)configureWithProfile:(MDAccount *)profile
{
    if ( profile == nil )
    {
        [self configureAsPublicUser];
    }
    else
    {
        self.nameLabel.text = profile.fullName;
        self.nameLabel.textColor = [UIColor principalTextColor];
        self.emailLabel.text = profile.email;
        self.emailLabel.textColor = [UIColor secondaryTextColor];
        
        if ( self.overrideAvatar != nil )
        {
            self.avatar.image = self.overrideAvatar;
            [MDUIHelper applyCornerRadius:self.avatar.frame.size.width / 2.0 toView:self.avatar];
        }
        else
        {
            [profile.image imageWithCallback:^(UIImage *image, MDDataSource source, MDFault *fault)
             {
                 if ( fault == nil && image != nil )
                 {
                     [[NSOperationQueue mainQueue] addOperationWithBlock:^
                      {
                          self.avatar.image = image;
                          [MDUIHelper applyCornerRadius:self.avatar.frame.size.width / 2.0 toView:self.avatar];
                      }];
                 }
             }];
        }
    }
}

- (void)configureAsPublicUser
{
    self.logoutButton.hidden = YES;
    
    self.nameLabel.text = @"ANONYMOUS USER";
    self.nameLabel.textColor = [UIColor principalTextColor];
    self.emailLabel.hidden = YES;
    
    self.nameLabelCenterToAvatarConstraint.constant = 0;
    CGFloat avatarWidth = self.avatar.frame.size.width;
    CGFloat windowWidth = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    CGFloat anonLabelWidth = [self.nameLabel sizeThatFits:self.nameLabel.bounds.size].width;
    CGFloat distanceAvatarToLabel = self.nameLabel.frame.origin.x - (self.avatar.frame.origin.x + self.avatar.frame.size.width );
    
    CGFloat desiredWidth = (windowWidth - avatarWidth - anonLabelWidth - distanceAvatarToLabel) / 2.0 ;
    self.avatarToLeftMarginConstraint.constant = - MAX(8.0, desiredWidth );
    [self.contentView layoutIfNeeded];
}

- (IBAction)logOut:(id)sender
{
    [self.profileDelegate logOut];
}

- (IBAction)changeAvatar:(id)sender
{
    [self.profileDelegate changeAvatar];
}

@end
