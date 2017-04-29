//
//  MDTextFieldController.h
//  Medable
//
//  Created by Guillermo Biset on 3/19/15.
//  Copyright (c) 2015 medable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDUIWidget.h"

@interface MDSelectAvatarView : MDUIWidget

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, weak) id<UINavigationControllerDelegate, UIImagePickerControllerDelegate> imagePickerDelegate;

@end
