//
//  MDProfileTableViewController.m
//  Axon
//
//  Created by Guillermo Biset on 6/1/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <Medable/Medable.h>

#import "MDRAxon.h"
#import "MDInformationViewController.h"
#import "MDInformationSectionViewController.h"

#import "MDInformationLogosCell.h"
#import "MDInformationSectionCell.h"
#import "MDTasksFooterView.h"
#import "MDTasksHeaderView.h"
#import "UIColor+Medable.h"
#import "MDFeatureToggleViewController.h"


@interface MDInformationViewController ()

@property (nonatomic) MDRStudy *study;
@property (nonatomic) NSArray< MDPropertyInstance *> *sections;

@end

static NSString *informationSectionCellId = @"informationSectionCellId";
static NSString *informationLogosCellId = @"informationLogosCellId";

@implementation MDInformationViewController

- (instancetype)initWithStudy:(MDRStudy*)study
{
    self = [super init];
    
    if (self)
    {
        _study = study;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Resources";
    
    self.sections = [self.study informationSections];
    
    UINib *nib = [UINib nibWithNibName:@"MDInformationLogosCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:informationLogosCellId];
    
    nib = [UINib nibWithNibName:@"MDInformationSectionCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:informationSectionCellId];
    
    nib = [UINib nibWithNibName:@"MDTaskFooterView" bundle:nil];
    [self.tableView registerNib:nib forHeaderFooterViewReuseIdentifier:MDTasksFooterView.footerId];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshSelected:forState:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self refreshData];
}

-(void)refreshSelected:(id)sender forState:(UIControlState)state
{
    [self refreshData];
}

- (void)refreshData
{
    [self.refreshControl beginRefreshing];
    
    [[MDRAxon sharedInstance] downloadStudyInformationWithCallback:^(MDRStudy *study, MDFault *fault)
    {
        [self.refreshControl endRefreshing];
        
        if ( study != nil )
        {
            self.study = study;
            self.sections = [self.study informationSections];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
            {
                [self.tableView reloadData];
            }];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + self.sections.count; //Include another +1 for a feature toggle page
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == 0 )
    {
        return [MDInformationLogosCell height];
    }
    
    return [MDInformationSectionCell height];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    return [MDTasksFooterView height];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    MDTasksFooterView *taskFooterView = [MDTasksFooterView new];
    
    return taskFooterView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ( indexPath.row == 0 )
    {
        MDInformationLogosCell *logosCell = [tableView dequeueReusableCellWithIdentifier:informationLogosCellId forIndexPath:indexPath];
        [logosCell configureWithStudy:self.study];
        cell = logosCell;
    }
    /*
    else if ( indexPath.row == self.sections.count + 1 )
    {
        //Feature toggle page goes last
        MDInformationSectionCell *sectionCell = [tableView dequeueReusableCellWithIdentifier:informationSectionCellId forIndexPath:indexPath];
        cell = sectionCell;
        
        [sectionCell configureWithTitle:@"Settings"];
        
        sectionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [sectionCell setMainCellColor:(indexPath.section + indexPath.row) % 2 == 0 ? [UIColor principalColor] : [UIColor secondaryColor]];
    }
     */
    else
    {
        MDInformationSectionCell *sectionCell = [tableView dequeueReusableCellWithIdentifier:informationSectionCellId forIndexPath:indexPath];
        cell = sectionCell;
        
        MDPropertyInstance *infoInstance = self.sections[ indexPath.row - 1 ];
        NSDictionary *info = [infoInstance value];
        
        MDPropertyInstance *titleProperty = info[ @"c_title" ];
        NSString *title = [titleProperty value];
        
        [sectionCell configureWithTitle:title];
        
        sectionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [sectionCell setMainCellColor:(indexPath.section + indexPath.row) % 2 == 0 ? [UIColor principalColor] : [UIColor secondaryColor]];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
    if ( indexPath.row == self.sections.count + 1 )
    {
        //Feature Toggle
        MDFeatureToggleViewController *featureToggleVC = [MDFeatureToggleViewController new];
        
        [self.participationDelegate.participationNavigationController pushViewController:featureToggleVC animated:YES];
    }
    else
        */
    if ( indexPath.row > 0 )
    {
        MDPropertyInstance *infoInstance = self.sections[ indexPath.row - 1 ];
        NSDictionary *info = [infoInstance value];
        
        MDPropertyInstance *titleProperty = info[ @"c_title" ];
        NSString *title = [titleProperty value];
        
        MDPropertyInstance *contentProperty = info[ @"c_content" ];
        NSString *content = [contentProperty value];
        
        MDPropertyInstance *webLinkProperty = info[ @"c_web_link" ];
        NSString *webLink = [webLinkProperty value];
        
        MDPropertyInstance *contentIsHTMLProperty = info[ @"c_content_is_html" ];
        NSNumber *contentIsHTML = [contentIsHTMLProperty value];
        
        MDInformationSectionViewController *informationSection = [MDInformationSectionViewController new];
        
        informationSection.sectionTitle = title;
        informationSection.content = content;
        informationSection.contentIsHTML = [contentIsHTML boolValue];
        informationSection.webLink = webLink;
        
        [self.participationDelegate.participationNavigationController pushViewController:informationSection animated:YES];
    }
}

@end
