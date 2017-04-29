//
//  MDAppearance.m
//  Medable
//
//  Created by Guillermo Biset on 3/20/15.
//  Copyright (c) 2015 medable. All rights reserved.
//

#import "MDUIWidget.h"

NSString *const kAppearanceFontKey = @"kAppearanceFontKey";
NSString *const kAppearanceBackgroundImageNameKey = @"kAppearanceBackgroundImageNameKey";
NSString *const kAppearanceHighlightedBackgroundImageNameKey = @"kAppearanceHighlightedBackgroundImageNameKey";
NSString *const kAppearanceStretchableInsetKey = @"kAppearanceStretchableInsetKey";

static NSMutableDictionary *_classAppearance = nil;

MDUIWidget_Declare_Class(MDUIWidget)

@implementation MDUIWidget

+ (NSDictionary *)defaultClassAppearance
{
    return @{};
}

MDUIWidget_Implement_Class(MDUIWidget)

- (NSMutableDictionary *)instanceOverrideAppearance
{
    if ( _instanceOverrideAppearance == nil )
    {
        _instanceOverrideAppearance = [NSMutableDictionary new];
    }
    
    return _instanceOverrideAppearance;
}

- (id)valueForAppearanceKey:(NSString *)appearanceKey
{
    id value = _instanceOverrideAppearance[appearanceKey];
    
    if ( value != nil )
    {
        return value;
    }
    
    value = [[self class] classAppearance][appearanceKey];
    
    return value;
}

@end
