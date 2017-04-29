//
//  MDProfileTableViewController.m
//  Axon
//
//  Created by Guillermo Biset on 6/1/16.
//  Copyright © 2016 Medable Inc. All rights reserved.
//

#import <Medable/Medable.h>

#import "MDRAxon.h"
#import "MDProfileViewController.h"
#import "MDProfileMainCell.h"
#import "MDProfileValueCell.h"
#import "MDProfileParticipationCell.h"
#import "MDTasksFooterView.h"
#import "MDTasksHeaderView.h"
#import "UIColor+Medable.h"
#import "MDOnboardingController.h"
#import "MDUIHelper.h"

@interface MDProfileViewController ()
    <MDProfileDelegate,
    MDProfileParticipationCellDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate>

@property (nonatomic) MDRStudy *study;
@property (nonatomic) UIImage *selectedImage;

@end

static NSString *profileMainCellId = @"profileMainCellId";
static NSString *profileValueCellId = @"profileValueCellId";
static NSString *profileParticipationCellId = @"profileParticipationCellId";
static NSString *profileFooterId = @"profileFooterId";

@implementation MDProfileViewController

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
    
    self.title = @"Profile";
    
    if ( [self study] == nil && [MDRAxon sharedInstance].userStudy != nil )
    {
        self.study = [MDRAxon sharedInstance].userStudy;
    }
    
    UINib *nib = [UINib nibWithNibName:@"MDProfileValueCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:profileValueCellId];
    
    nib = [UINib nibWithNibName:@"MDProfileMainCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:profileMainCellId];
    
    nib = [UINib nibWithNibName:@"MDProfileParticipationCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:profileParticipationCellId];
    
    nib = [UINib nibWithNibName:@"MDTaskFooterView" bundle:nil];
    [self.tableView registerNib:nib forHeaderFooterViewReuseIdentifier:profileFooterId];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ( [[self.study allPublic] boolValue] )
    {
        return 1;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 )
    {
        return 2;
    }
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 && indexPath.row == 0 )
    {
        return [MDProfileMainCell height];
    }
    else if ( indexPath.section == 0 && indexPath.row == 1 )
    {
        return [MDProfileParticipationCell height];
    }
    
    return [MDProfileValueCell height];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    if ( section == 0 )
    {
        return 0;
    }
    
    return [MDTasksHeaderView height];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( section == 0 )
    {
        return nil;
    }
    
    MDTasksHeaderView *taskHeaderView = [MDTasksHeaderView new];
    
    if ( section == 1 )
    {
        taskHeaderView.title.text = @"BASIC PROFILE";
    }
    
    return taskHeaderView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    MDAccount *user = [Medable client].currentUser;
    
    if ( indexPath.section == 0 )
    {
        if ( indexPath.row == 0 )
        {
            MDProfileMainCell *mainCell = [tableView dequeueReusableCellWithIdentifier:profileMainCellId forIndexPath:indexPath];
            mainCell.overrideAvatar = self.selectedImage;
            mainCell.profileDelegate = self;
            [mainCell configureWithProfile:user];
            
            cell = mainCell;
        }
        else
        {
            MDProfileParticipationCell *participationCell = [tableView dequeueReusableCellWithIdentifier:profileParticipationCellId forIndexPath:indexPath];
            
            participationCell.delegate = self;
            [participationCell configureWithStudy:self.study];
            
            cell = participationCell;
        }
    }
    else if ( indexPath.section == 1 )
    {
        MDProfileValueCell *valueCell = [tableView dequeueReusableCellWithIdentifier:profileValueCellId forIndexPath:indexPath];
        cell = valueCell;
        
        switch ( indexPath.row )
        {
            case 0:
                [valueCell configureWithTitle:Localized(@"Date of Birth") value:user.dob.length > 0 ? user.dob : Localized(@"N/A")];
                break;
            case 1:
            {
                NSString *gender = Localized(@"N/A");
                if ( user.gender == MDGenderMale )
                {
                    gender = Localized(@"Male");
                }
                else if ( user.gender == MDGenderFemale )
                {
                    gender = Localized(@"Female");
                }
                
                [valueCell configureWithTitle:Localized(@"Gender") value:gender];
            }
                break;
            case 2:
                [valueCell configureWithTitle:Localized(@"Phone Number") value:user.mobile];
                break;
            default:
                break;
        }
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
}

#pragma mark - Miscellaneous

- (UIBarButtonItem *)rightBarButtonItem
{
    return nil;
    /*
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                         target:self
                                                         action:@selector(editSelected:)];
}

- (void)editSelected:(id)sender
{
     */
    
}

#pragma mark - MDProfileDelegate

- (void)changeAvatar
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Upload Image"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *choosePictureAction = [UIAlertAction actionWithTitle:@"Choose Picture from Camera Roll"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action)
                                          {
                                              [self pickPhotoFrom:UIImagePickerControllerSourceTypePhotoLibrary];
                                          }];
    
    [alert addAction:choosePictureAction];
    
    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:@"Take Picture"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            [self pickPhotoFrom:UIImagePickerControllerSourceTypeCamera];
                                        }];
    
    [alert addAction:takePictureAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)pickPhotoFrom:(UIImagePickerControllerSourceType)sourcetype
{
    if ( ! [UIImagePickerController isSourceTypeAvailable:sourcetype])
    {
        [MDUIHelper  showAlertWithTitle:@"Erorr"
                                message:@"Your selected source is not available"
                      cancelButtonTitle:@"Ok"
                       inViewController:self];
        
        return;
    }
    
    UIImagePickerController *pickerController = [UIImagePickerController new];
    
    pickerController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : UIColor.blackColor } ;
    pickerController.allowsEditing = YES;
    pickerController.navigationBar.tintColor = UIColor.blackColor;
    pickerController.sourceType = sourcetype;
    
    pickerController.delegate = self;
    
    [self.participationDelegate presentViewController:pickerController];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)resetModalPresentation
{
    [self.participationDelegate dismissViewController];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self resetModalPresentation];
    
    UIImage *image = info[UIImagePickerControllerEditedImage] ? : info[UIImagePickerControllerOriginalImage];
    self.selectedImage = image;
    
    if ( image != nil )
    {
        self.selectedImage = image;
        
        MDAccount *me = [Medable client].currentUser;
       
        MDBody *bodyObject = [MDBody new];
        MDPropertyDefinition *propDef = [me.object propertyWithName:kImageKey type:nil];
        MDFileBodyProperty *imageProp = [[MDFileBodyProperty alloc] initWithPropertyDefinition:propDef];
        [imageProp addFacetAttachment:kContentKey
                                 mime:kMimeTypeImageJpeg
                                 data:UIImageJPEGRepresentation(image, 0.95)];
        [bodyObject addProperty:imageProp];
        
        [[Medable client] updateObjectWithContext:kPluralAccountContext
                                         objectId:me.Id
                                       bodyObject:bodyObject
                                         callback:^(MDObjectInstance * _Nullable object, MDFault * _Nullable fault)
         {
             if ( fault == nil )
             {
                 [self updateAvatarWithSelectedImage];
             }
             else
             {
                 self.selectedImage = nil;
             }
         }];
    }
}

- (void)updateAvatarWithSelectedImage
{
    [self.tableView reloadData];
}

- (void)logOut
{
    [Medable.client logout:^(MDFault * _Nonnull fault)
    {
        if ( fault != nil )
        {
            //Force logout
            [[NSNotificationCenter defaultCenter] postNotificationName:kForceLogoutNotification object:nil];
        }
    }];
}

#pragma mark - MDProfileParticipationCellDelegate

- (void)leaveStudy
{
    [MDOnboardingController selectedLeaveStudyFromViewController:self.participationDelegate.participationNavigationController completionBlock:^(MDFault *fault)
    {
        //ToDo: Deal with leave study failure
        /*
        if ( fault == nil )
        {
         */
            [self logOut];
        //}
    }];
}

@end
