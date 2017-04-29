//
//  MDTextFieldController.h
//  Medable
//
//  Created by Guillermo Biset on 3/19/15.
//  Copyright (c) 2015 medable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDUIWidget.h"

@interface MDDateFieldView : MDUIWidget

@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, weak, readonly) UIDatePicker *datePicker;

@end
