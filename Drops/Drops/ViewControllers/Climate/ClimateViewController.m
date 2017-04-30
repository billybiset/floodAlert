#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD.h>

#import "ClimateViewController.h"

#import "UIColor+Drops.h"
#import "UIHelper.h"

#import "ClimateDownloader.h"

@interface ClimateViewController () <MKMapViewDelegate>

@property (nonatomic) NSOperationQueue *processingQueue;

@property (nonatomic) IBOutlet MKMapView *map;
@property (nonatomic) IBOutlet UITextView *instructionsTextView;
@property (nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic) IBOutlet UILabel *temperatureLabel;
@property (nonatomic) IBOutlet UILabel *precipiationLabel;

@end

@implementation ClimateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.map.delegate = self;
    
    [self localizeOutlets];
}


- (void)localizeOutlets
{
    
}

- (double)fahrenheitToCelsius:(double)fahrenheit
{
    return (fahrenheit - 32) / 1.8;
}

- (void)updateBubbleWithInfo:(NSDictionary *)information
{
    NSDictionary *currently = information[@"currently"];
    
    NSString *coordinates = [NSString stringWithFormat:@"%f, %f",
                             self.map.centerCoordinate.latitude,
                             self.map.centerCoordinate.longitude];
    
    self.locationLabel.text = coordinates;

    NSString *fahrenheitStr = [currently[@"temperature"] description];
    fahrenheitStr = [fahrenheitStr substringToIndex:fahrenheitStr.length-1];
    double fahrenheit = [fahrenheitStr doubleValue];
    
    double celsius = [self fahrenheitToCelsius:fahrenheit];

    self.temperatureLabel.text = [NSString stringWithFormat:@" %.1f C  /   %.1f F",celsius, fahrenheit];
    
    self.precipiationLabel.text =
    
    self.instructionsTextView.text =  [NSString stringWithFormat:@" %.0f %%  /   %.1f mm/h",
                                        [((NSString *)currently[@"precipProbability"]) doubleValue] * 100.0,
                                        [((NSString *)currently[@"precipIntensity"]) doubleValue] * 25.4];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationDegrees latitude = self.map.centerCoordinate.latitude;
    CLLocationDegrees longitude = self.map.centerCoordinate.latitude;
    
    [[ClimateDownloader instance] downloadLatitude:latitude
                                         longitude:longitude
                                          callback:^(NSDictionary *information, NSError *error)
     {
         if ( error == nil )
         {
             [self updateBubbleWithInfo:information];
         }
     }];
}

- (IBAction)toggleMenu:(id)sender
{
}

@end
