//
//  MDTaskCellViewController.h
//  Axon
//
//  Created by Guillermo Biset on 5/27/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDRStudy;

@interface MDInformationLogosCell : UITableViewCell

+ (CGFloat)height;
- (void)configureWithStudy:(MDRStudy *)study;

@end
