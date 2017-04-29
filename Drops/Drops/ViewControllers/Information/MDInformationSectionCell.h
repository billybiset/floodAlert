//
//  MDTaskCellViewController.h
//  Axon
//
//  Created by Guillermo Biset on 5/27/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDRTask;

@interface MDInformationSectionCell : UITableViewCell

+ (CGFloat)height;

- (void)setMainCellColor:(UIColor *)color;
- (void)configureWithTitle:(NSString *)title;

@end
