#import <Foundation/Foundation.h>

typedef void (^NoArgumentCallback)(void);
typedef void (^ObjectCallback)(id object);
typedef void (^ObjectErrorCallback)(id object, NSError* error);

typedef enum
{
    WaterTypeSurface = 1,
    WaterTypeFlood
} WaterType;

@interface FileDownloader : NSObject

+ (instancetype)instance;

@property (nonatomic, readwrite) WaterType waterType;

- (NSString *)filenameForDate:(NSDate *)date
                     latitude:(CLLocationDegrees)latitude
                    longitude:(CLLocationDegrees)longitude
                       zipped:(BOOL)zipped;

- (void)downloadForDate:(NSDate *)date
               latitude:(CLLocationDegrees)latitude
              longitude:(CLLocationDegrees)longitude
               callback:(ObjectErrorCallback)callback;

@end
