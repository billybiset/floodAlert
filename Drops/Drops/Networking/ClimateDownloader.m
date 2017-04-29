#import <AFNetworking.h>
#import <CoreLocation/CoreLocation.h>

#import "Callbacks.h"
#import "ClimateDownloader.h"

@interface ClimateDownloader()

@property (nonatomic) AFURLSessionManager *sessionManager;

@end

@implementation ClimateDownloader

+ (instancetype)instance
{
    static ClimateDownloader *instance = nil;
    static dispatch_once_t onceToken;
    
    if ( instance == nil )
    {
        dispatch_once(&onceToken, ^
                      {
                          instance = [ClimateDownloader new];
                      });
    }
    
    return instance;
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

- (NSString *)urlStringForLatitude:(CLLocationDegrees)latitude
                         longitude:(CLLocationDegrees)longitude
{
    NSString *apiKey = @"8bf9a10a059e8fe6575ea44ab42dfc31";
    NSString *locationString = [NSString stringWithFormat:@"%f,%f",latitude,longitude];
    
    return [NSString stringWithFormat:@"https://api.darksky.net/forecast/%@/%@",
            apiKey,
            locationString];
}

- (void)downloadLatitude:(CLLocationDegrees)latitude
               longitude:(CLLocationDegrees)longitude
                callback:(ObjectErrorCallback)callback
{
    NSString *urlString = [self urlStringForLatitude:latitude longitude:longitude];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *downloadTask =
    [self.sessionManager
     dataTaskWithRequest:request
     uploadProgress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     }
     downloadProgress:^(NSProgress * _Nonnull downloadProgress)
     {
         
     }
     completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary *_Nullable responseObject, NSError * _Nullable error)
     {
         if ( callback != nil )
         {
             callback(responseObject, error);
         }
     }];
                                                  
                                              /*
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
                                                      NSLog(@"Downloaded file %@", fileURL.lastPathComponent);
                                                      [self unzipFileAt:filePath callback:callback];
                                                  }
                                                  else
                                                  {
                                                      NSLog(@"Failed to download %@", fileURL.lastPathComponent);
                                                  }
                                              }];
    */
                                              
    [downloadTask resume];
    
}

@end
