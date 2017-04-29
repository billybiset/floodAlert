//
//  MDInformationSectionViewController.h
//  Axon
//
//  Created by Guillermo Biset on 6/3/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDInformationSectionViewController : UIViewController

@property (nonatomic) NSString *sectionTitle;
@property (nonatomic) NSString *content;
@property (nonatomic) NSString *webLink;
@property (nonatomic) BOOL contentIsHTML;

@end
