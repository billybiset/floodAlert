//
//  MDTaskCellViewController.h
//  Axon
//
//  Created by Guillermo Biset on 5/27/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDRStudy;

@protocol MDProfileParticipationCellDelegate <NSObject>

- (void)leaveStudy;

@end

@interface MDProfileParticipationCell : UITableViewCell

@property (nonatomic, weak) id<MDProfileParticipationCellDelegate> delegate;

+ (CGFloat)height;
- (void)configureWithStudy:(MDRStudy *)study;
- (void)setMainCellColor:(UIColor *)color;

@end
