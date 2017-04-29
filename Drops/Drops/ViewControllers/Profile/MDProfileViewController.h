//
//  MDProfileTableViewController.h
//  Axon
//
//  Created by Guillermo Biset on 6/1/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDParticipationDelegate.h"

@class MDRStudy;

@interface MDProfileViewController : UITableViewController

@property (nonatomic, weak) id<MDParticipationDelegate> participationDelegate;
- (instancetype)initWithStudy:(MDRStudy *)study;

@end
