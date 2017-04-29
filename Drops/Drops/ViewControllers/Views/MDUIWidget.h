//
//  MDAppearance.h
//  Medable
//
//  Created by Guillermo Biset on 3/20/15.
//  Copyright (c) 2015 medable. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kAppearanceFontKey;
extern NSString *const kAppearanceBackgroundImageNameKey;
extern NSString *const kAppearanceHighlightedBackgroundImageNameKey;
extern NSString *const kAppearanceStretchableInsetKey;

#define MDUIWidget_Declare_Class(CLASS) static NSMutableDictionary *_CLASS ## _Appearance = nil;

#define MDUIWidget_Implement_Class(CLASS) \
+ (NSMutableDictionary *)classAppearance \
{ \
    if ( _CLASS ## _Appearance == nil ) \
    { \
        _CLASS ## _Appearance = [NSMutableDictionary dictionaryWithDictionary:[self defaultClassAppearance]]; \
    } \
    \
    return _CLASS ## _Appearance; \
} \
\
+ (void)setClassAppearance:(NSDictionary *)classAppearance \
{ \
    _CLASS ## _Appearance = [NSMutableDictionary dictionaryWithDictionary:classAppearance]; \
} \

@interface MDUIWidget : UIView

+ (NSDictionary *)defaultClassAppearance;

+ (NSMutableDictionary *)classAppearance;
+ (void)setClassAppearance:(NSDictionary *)classAppearance;

@property (nonatomic, strong) NSMutableDictionary *instanceOverrideAppearance;

- (id)valueForAppearanceKey:(NSString *)appearanceKey;

@end
