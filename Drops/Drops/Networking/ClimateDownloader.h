#import <Foundation/Foundation.h>

#import "Callbacks.h"

@interface ClimateDownloader : NSObject

+ (instancetype)instance;

- (void)downloadLatitude:(CLLocationDegrees)latitude
               longitude:(CLLocationDegrees)longitude
                callback:(ObjectErrorCallback)callback;

@end
