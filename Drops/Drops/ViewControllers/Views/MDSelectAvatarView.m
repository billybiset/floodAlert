//
//  MDTextFieldController.m
//  Medable
//
//  Created by Guillermo Biset on 3/19/15.
//  Copyright (c) 2015 medable. All rights reserved.
//

#import "MDSelectAvatarView.h"
#import "MDUIHelper.h"

@interface MDSelectAvatarView ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *takePictureImage;
@property (nonatomic, weak) IBOutlet UIImageView *choosePictureImage;

@end

MDUIWidget_Declare_Class(MDSelectAvatarView)

@implementation MDSelectAvatarView

MDUIWidget_Implement_Class(MDSelectAvatarView)

+ (instancetype)new
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                          owner:self
                                        options:nil] firstObject];
}

- (instancetype)initWithNib
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
    
    self = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    if ( self != nil )
    {
        [self configure];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self configure];
}

- (void)configure
{
    self.backgroundColor = UIColor.clearColor;
}

- (void)setAvatarImage:(UIImage *)avatarImage
{
    if ( avatarImage != nil )
    {
        _avatarImage = avatarImage;
        
        self.avatarImageView.image = avatarImage;
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.avatarImageView.layer.cornerRadius = 15.0;
        self.avatarImageView.layer.masksToBounds = YES;
    }
}

#pragma mark - Actions

- (IBAction)takePictureTapDown:(id)sender
{
    self.takePictureImage.image = [UIImage imageNamed:@"takepicture-high"];
}

- (IBAction)takePictureTapEnd:(id)sender
{
    self.takePictureImage.image = [UIImage imageNamed:@"takepicture"];    
}

- (IBAction)choosePictureTapDown:(id)sender
{
    self.choosePictureImage.image = [UIImage imageNamed:@"choosepicture-high"];
}

- (IBAction)choosePictureTapEnd:(id)sender
{
    self.choosePictureImage.image = [UIImage imageNamed:@"choosepicture"];
}

- (void)pickPhotoFrom:(UIImagePickerControllerSourceType)sourcetype
{
    if ( ! [UIImagePickerController isSourceTypeAvailable:sourcetype] )
    {
        [MDUIHelper  showAlertWithTitle:@"Erorr"
                                message:@"Your selected source is not available"
                      cancelButtonTitle:@"Ok"
                       inViewController:self.parentViewController];
        
        return;
    }
    
    UIImagePickerController *pickerController = [UIImagePickerController new];
    
    pickerController.allowsEditing = YES;
    
    pickerController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : UIColor.blackColor } ;
    pickerController.navigationBar.tintColor = UIColor.blackColor;
    pickerController.sourceType = sourcetype;
    
    pickerController.delegate = self.imagePickerDelegate;
    
    [self.parentViewController presentViewController:pickerController
                                            animated:YES
                                          completion:nil];
}

- (IBAction)takePicture:(id)sender
{
    [self takePictureTapEnd:sender];
    
    [self pickPhotoFrom:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)choosePicture:(id)sender
{
    [self choosePictureTapEnd:sender];
    
    [self pickPhotoFrom:UIImagePickerControllerSourceTypePhotoLibrary];
}

@end
