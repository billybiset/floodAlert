//
//  MDTextFieldController.h
//  Medable
//
//  Created by Guillermo Biset on 3/19/15.
//  Copyright (c) 2015 medable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDUIWidget.h"

@interface MDTextFieldView : MDUIWidget

@property (nonatomic, weak, readonly) UITextField *textField;
@property (nonatomic, weak, readonly) UIImageView *textFieldBackground;

@property (nonatomic, weak) id<UITextFieldDelegate> textFieldDelegate;

- (void)signalWarning;

@end
