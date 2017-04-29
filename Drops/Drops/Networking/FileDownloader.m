#import <AFNetworking.h>
#import <SSZipArchive/SSZipArchive.h>
#import <CoreLocation/CoreLocation.h>

#import "FileDownloader.h"

@interface FileDownloader()

@property (nonatomic) AFURLSessionManager *sessionManager;

@property (nonatomic) NSDateFormatter *yearDateFormatter;
@property (nonatomic) NSDateFormatter *dayOfYearDateFormatter;

@end

@implementation FileDownloader

+ (instancetype)instance
{
    static FileDownloader *instance = nil;
    static dispatch_once_t onceToken;
    
    if ( instance == nil )
    {
        dispatch_once(&onceToken, ^
                      {
                          instance = [FileDownloader new];
                      });
    }
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if ( self != nil )
    {
        
    }
    
    return self;
}

- (AFURLSessionManager *)sessionManager
{
    if ( _sessionManager == nil )
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

        self.sessionManager = manager;
    }
    
    return _sessionManager;
}

- (NSURL *)documentsDirectoryURL
{
    return [[NSFileManager defaultManager]
            URLForDirectory:NSDocumentDirectory
            inDomain:NSUserDomainMask
            appropriateForURL:nil
            create:NO
            error:nil];
}

- (void)downloadForDate:(NSDate *)date
               latitude:(CLLocationDegrees)latitude
              longitude:(CLLocationDegrees)longitude
               callback:(ObjectErrorCallback)callback
{
    NSURL *documentsDirectoryURL = [self documentsDirectoryURL];
    
    NSString *filename = [self filenameForDate:date latitude:latitude longitude:longitude];
    
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:filename];
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:nil] )
    {
        [self unzipFileAt:fileURL callback:callback];
    }
    else
    {
        NSString *urlString = [self urlForDate:date latitude:latitude longitude:longitude];
        
        NSURL *URL = [NSURL URLWithString:urlString];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDownloadTask *downloadTask = [self.sessionManager
                                                  downloadTaskWithRequest:request
                                                  progress:^(NSProgress * _Nonnull downloadProgress)
                                                  {
                                                      
                                                  }
                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                                                  {
                                                      return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                  }
                                                  completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
                                                  {
                                                      if ( error == nil )
                                                      {
                                                          [self unzipFileAt:filePath callback:callback];
                                                      }
                                                  }];
        
        [downloadTask resume];
    }
}

- (NSString *)latitudeStringForLatitude:(CLLocationDegrees)latitude
{
    NSInteger multiple10 = (NSInteger) (floor(ABS(latitude) / 10.0) * 10.0);
    
    return [NSString stringWithFormat:@"%03lu%@",multiple10, latitude < 0 ? @"S" : @"N"];
}

- (NSString *)longitudeStringForLongitude:(CLLocationDegrees)longitude
{
    NSInteger multiple10 = (NSInteger) ((floor(ABS(longitude) / 10.0) + 1) * 10.0);
    
    return [NSString stringWithFormat:@"%03lu%@",multiple10, longitude < 0 ? @"W" : @"E"];
}

- (NSString *)waterTypeString
{
    if ( self.waterType == WaterTypeFlood )
    {
        return @"MFW";
    }
    
    return @"MSW";
}

- (NSString *)filenameForDate:(NSDate *)date latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    NSString *latitudeString = [self latitudeStringForLatitude:latitude];
    NSString *longitudeString = [self longitudeStringForLongitude:longitude];
    NSString *locationString = [NSString stringWithFormat:@"%@%@", longitudeString, latitudeString];
    
    NSString *yearString = [self yearStringForDate:date];
    NSString *dayOfYearString = [self dayOfYearStringForDate:date];
    
    NSString *dataTypeString = [self waterTypeString];
    
    return [NSString stringWithFormat:@"%@_%@%@_%@_%@_%@.kmz",
            dataTypeString,
            yearString,
            dayOfYearString,
            locationString,
            @"3D3OT",
            @"V"];
}

- (NSString *)yearStringForDate:(NSDate *)date
{
    if ( self.yearDateFormatter == nil )
    {
        self.yearDateFormatter = [NSDateFormatter new];
        self.yearDateFormatter.dateFormat = @"yyyy";
    }
    
    return [self.yearDateFormatter stringFromDate:date];
}

- (NSString *)dayOfYearStringForDate:(NSDate *)date
{
    if ( self.dayOfYearDateFormatter == nil )
    {
        self.dayOfYearDateFormatter = [NSDateFormatter new];
        self.dayOfYearDateFormatter.dateFormat = @"DDD";
    }
    
    return [self.dayOfYearDateFormatter stringFromDate:date];
}

- (NSString *)urlForDate:(NSDate *)date latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    NSString *latitudeString = [self latitudeStringForLatitude:latitude];
    NSString *longitudeString = [self longitudeStringForLongitude:longitude];
    NSString *locationString = [NSString stringWithFormat:@"%@%@", longitudeString, latitudeString];
    
    NSString *yearString = [self yearStringForDate:date];
    NSString *dayOfYearString = [self dayOfYearStringForDate:date];
    
    NSString *baseURL = @"https://floodmap.modaps.eosdis.nasa.gov/Products";
    
    NSString *dataTypeString = [self waterTypeString];
    
    NSString *filename = [NSString stringWithFormat:@"%@_%@%@_%@_%@_%@.kmz",
                          dataTypeString,
                          yearString,
                          dayOfYearString,
                          locationString,
                          @"3D3OT",
                          @"V"];
    
    return [NSString stringWithFormat:@"%@/%@/%@/%@",
            baseURL,
            locationString,
            yearString,
            filename];
}
     
- (void)unzipFileAt:(NSURL *)fileURL callback:(ObjectErrorCallback)callback
{
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager]
                                    URLForDirectory:NSDocumentDirectory
                                    inDomain:NSUserDomainMask
                                    appropriateForURL:nil
                                    create:NO
                                    error:nil];
    
    [SSZipArchive unzipFileAtPath:fileURL.path
                    toDestination:documentsDirectoryURL.path
                  progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total)
    {
        
    }
                completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error)
    {
        if ( error != nil )
        {
            if ( callback != nil )
            {
                callback(nil, error);
            }
            
            return;
        }
        
        NSURL *sourceKMLFile = [documentsDirectoryURL URLByAppendingPathComponent:@"doc.kml"];
        
        NSURL *deleteExtension = [fileURL URLByDeletingPathExtension];
        NSURL *destination = [deleteExtension URLByAppendingPathExtension:@"kml"];
        
        NSError *moveError = nil;
        if ( [[NSFileManager defaultManager] fileExistsAtPath:destination.path] )
        {
            [[NSFileManager defaultManager] removeItemAtPath:destination.path
                                                       error:nil];
        }
        
        [[NSFileManager defaultManager] moveItemAtURL:sourceKMLFile
                                                toURL:destination
                                                error:&moveError];
        
        if ( callback != nil )
        {
            callback(destination, moveError);
        }
    }];
    

}

@end
