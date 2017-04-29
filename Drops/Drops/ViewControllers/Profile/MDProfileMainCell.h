//
//  MDTaskCellViewController.h
//  Axon
//
//  Created by Guillermo Biset on 5/27/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MDProfileDelegate <NSObject>

- (void)logOut;
- (void)changeAvatar;

@end



@interface MDProfileMainCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic, weak) id<MDProfileDelegate> profileDelegate;
@property (nonatomic) UIImage *overrideAvatar;

- (void)configureWithProfile:(MDAccount *)profile;

@end
